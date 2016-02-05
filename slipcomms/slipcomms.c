/**
* slipcomms: communication interface to debug cc2530 slip-radio
* Copyright: WigWag Inc.
* Author: Yash
**/

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h> // Symbolic constants: optarg, optind
#include <string.h>
#include <fcntl.h>
#include <errno.h>
#include <termios.h>
#include <sys/ioctl.h>
#include <sys/types.h>
#include <inttypes.h>
#include <sys/time.h>
#include <signal.h>

#include "slipcomms.h"

unsigned int verbose = 0;
const char *slip_siodev = NULL;
speed_t slip_baudrate = BAUDRATE;
int slip_flowcontrol = 0;
int slipTestBytes[4];
int factoryTestBytes[3]; //player, num, delay
char *factoryPlayer;


static int usermode = 0;
static int txmode = 0;
static int pingpongmode = 0;
static int channelstudymode = 0;
static int znpmode = 0;
static int zwavemode = 0;
static int zwave_readflash_mode = 0;

int slipfd = 0;
int slip_end = 0, slip_begin = 0, slip_packet_end = 0, slip_packet_count = 0, slip_sent = 0;
unsigned char slip_buf[MAX_SLIP_BUF];
unsigned char input_packet[MAX_SLIP_BUF];
int input_packet_len = 0;
int byteIndex = 0;
int slipTestMode = 0;
int factoryTestMode = 0;

#if RX_STATS
int last_seq = -1;
int num_lost = 0;
int dup_pack = 0;
int lost_seqnos[100] = {0};
int s = 0, n = 0;
#endif //RX_STATS

#if RELAY_1
static unsigned char ext_addr[8] = {0x00, 0xA5, 0x09, 0x00, 0x00, 0x39, 0xBB, 0x01};
static unsigned char dstaddr[8] = {0x00, 0xA5, 0x09, 0x00, 0x00, 0x08, 0xBB, 0x02}; 
#else 
static unsigned char dstaddr[8] = {0x00, 0xA5, 0x09, 0x00, 0x00, 0x39, 0xBB, 0x01}; //BB - RL
static unsigned char ext_addr[8] = {0x00, 0xA5, 0x09, 0x00, 0x00, 0x08, 0xBB, 0x02}; //EA - EM
#endif //RELAY

uint8_t src_mac_addr[8];
uint8_t dest_mac_addr[8];

uint8_t possible_mac_addrs[2][8] = { {0x00, 0xA5, 0x09, 0x00, 0x00, 0x39, 0xBB, 0x01}, {0x00, 0xA5, 0x09, 0x00, 0x00, 0x08, 0xBB, 0x02} };


#define ZWAVE_COMMAND_RESP_ENABLE_INTERFACE1   0xAA
#define ZWAVE_COMMAND_RESP_ENABLE_INTERFACE2   0x55
#define ZWAVE_COMMAND_RESP_READ_FLASH          0x10
#define ZWAVE_COMMAND_RESP_READ_SRAM           0x06
#define ZWAVE_COMMAND_RESP_CONTINUE_READ       0xA0
#define ZWAVE_COMMAND_RESP_WRITE_SRAM          0x04
#define ZWAVE_COMMAND_RESP_CONTINUE_WRITE      0x80
#define ZWAVE_COMMAND_RESP_ERASE_CHIP          0x0A
#define ZWAVE_COMMAND_RESP_ERASE_SECTOR        0x0B
#define ZWAVE_COMMAND_RESP_WRITE_FLASH_SECTOR  0x20
#define ZWAVE_COMMAND_RESP_CHECK_STATE         0x7F
#define ZWAVE_COMMAND_RESP_READ_SIGNATURE      0x30
#define ZWAVE_COMMAND_RESP_DISABLE_EOOS_MODE   0xD0
#define ZWAVE_COMMAND_RESP_ENABLE_EOOS_MODE    0xC0
#define ZWAVE_COMMAND_RESP_SET_LOCK_BITS       0xF0
#define ZWAVE_COMMAND_RESP_READ_LOCK_BITS      0xF1
#define ZWAVE_COMMAND_RESP_SET_NVR             0xFE
#define ZWAVE_COMMAND_RESP_READ_NVR            0xF2
#define ZWAVE_COMMAND_RESP_RUN_CRC_CHECK       0xC3
#define ZWAVE_COMMAND_RESP_RESET_CHIP          0xFF

enum {
  CRC_BUSY = 1,
  CRC_DONE = 2,
  CRC_FAILED = 4,
  FLASH_FSM_BUSY = 8,
  CONN_REFUSED = 32,
  EXEC_SRAM_MODE = 128
};

unsigned char frame802154[PACKETBUF_SIZE];
int seqno = 0;
//---------------------------------------------------------------------------
/* Generic MAC return values. */
enum {
  /**< The MAC layer transmission was OK. */
  MAC_TX_OK,

  /**< The MAC layer transmission could not be performed due to a
     collision. */
  MAC_TX_COLLISION,

  /**< The MAC layer did not get an acknowledgement for the packet. */
  MAC_TX_NOACK,

  /**< The MAC layer deferred the transmission for a later time. */
  MAC_TX_DEFERRED,

  /**< The MAC layer transmission could not be performed because of an
     error. The upper layer may try again later. */
  MAC_TX_ERR,

  /**< The MAC layer transmission could not be performed because of a
     fatal error. The upper layer does not need to try again, as the
     error will be fatal then as well. */
  MAC_TX_ERR_FATAL,

  MAC_TX_STAT_END,
};

int tx_stat_array[MAC_TX_STAT_END][1];
int total_num_responded = 0;
int num_tx_packets = 0;
int starting_tx_seqno = 0;
int starting_rx_seqno = 0;
int lost_pp_packets = 0;
int lost_pp_seqnos[100];
int pp_first_packet = 1;
int previous_rx_seqno = 0;
int8_t packet_stat[100][3];


int total_replied = 0;

int throttle_ok = 1;
void pingpong_rx(int num);
void got_channelstudy(unsigned char* data);


void handle_alarm(int sig) 
{
  throttle_ok = 1;
}
void get_tx_stats(void) 
{
  fprintf(stdout, "****************TX-STATUS*****************\n");
  fprintf(stdout, "\tTotal number of packets transmitted: %d\n", num_tx_packets - starting_tx_seqno);
  fprintf(stdout, "\tTotal number of packets responded: %d\n", total_num_responded);
  fprintf(stdout, "\tNumber of MAC_TX_OK: %d\n",            tx_stat_array[MAC_TX_OK][0]);
  fprintf(stdout, "\tNumber of MAC_TX_COLLISION: %d\n",     tx_stat_array[MAC_TX_COLLISION][0]);
  fprintf(stdout, "\tNumber of MAC_TX_NOACK: %d\n",         tx_stat_array[MAC_TX_NOACK][0]);
  fprintf(stdout, "\tNumber of MAC_TX_DEFERRED: %d\n",      tx_stat_array[MAC_TX_DEFERRED][0]);
  fprintf(stdout, "\tNumber of MAC_TX_ERR: %d\n",           tx_stat_array[MAC_TX_ERR][0]);
  fprintf(stdout, "\tNumber of MAC_TX_ERR_FATAL: %d\n",     tx_stat_array[MAC_TX_ERR_FATAL][0]);
  fprintf(stdout, "******************************************\n");
}
void get_rx_stats(void) 
{
  fprintf(stdout, "****************RX-STATUS*****************\n");
  fprintf(stdout, "\tTotal number of packets received: %d\n", total_replied);
  fprintf(stdout, "\tSID\tOutgoingRSSI\tIncomingRSSI\n");
  int i = 0;
  for(i = 0; i < (num_tx_packets - starting_tx_seqno); i++) {
    fprintf(stdout, "\t%d\t%d\t%d\n", packet_stat[0], packet_stat[1], packet_stat[2]);
  }
  fprintf(stdout, "******************************************\n");
}
//---------------------------------------------------------------------------
// void get_rx_stats(void) 
// {
//   int i = 0;
//   fprintf(stdout, "****************RX-STATUS*****************\n");
//   fprintf(stdout, "Total number of packets lost: %d\n", lost_pp_packets);
//   fprintf(stdout, "Lost seqnos: \n");
//   for(i = 0; i < lost_pp_packets; i++) {
//     fprintf(stdout, "%d ", lost_pp_seqnos[i]);
//   }
//   fprintf(stdout, "\n");
//   fprintf(stdout, "******************************************\n");
// }
//---------------------------------------------------------------------------
void report_tx_stat(int sid, int status) 
{
  total_num_responded++;
  // fprintf(stdout, "sid: %d, status: %d\n",sid, status);

  if(status != MAC_TX_OK && status != MAC_TX_COLLISION && status != MAC_TX_NOACK && 
        status != MAC_TX_DEFERRED && status != MAC_TX_ERR && status != MAC_TX_ERR_FATAL) {
    fprintf(stderr, "Unknown status type.. not acceptable\n");
  } else {
    tx_stat_array[status][0]++;
  }
}
//---------------------------------------------------------------------------
void start_tx_monitor(int num)
{
  starting_tx_seqno = num;
  total_num_responded = 0;
  //clear the counters
  memset(tx_stat_array, 0, sizeof(tx_stat_array[0][0])*MAC_TX_STAT_END*1);
  memset(packet_stat, 0, sizeof(packet_stat[0][0])*100*3);
}
//---------------------------------------------------------------------------
// void parse_factory_received_packet(unsigned char *data, int len) 
// {
//   uint8_t sid = data[]
//   packet_stat[]
// }
//---------------------------------------------------------------------------
void start_rx_monitor(int num)
{
  starting_rx_seqno = num;
  previous_rx_seqno = num;
  memset(lost_pp_seqnos, 0, sizeof(lost_pp_seqnos));
}
//---------------------------------------------------------------------------
void analyze_incoming_packet(int num)
{
  int h = 0;
  if((num - previous_rx_seqno) > 1) {
    //lost_pp_packets += num - previous_rx_seqno - 1;
    for(h = 0; h < (num - previous_rx_seqno - 1); h++) {
      previous_rx_seqno++;
      lost_pp_seqnos[lost_pp_packets++] = previous_rx_seqno;
    }
  }
  previous_rx_seqno = num;
}
//---------------------------------------------------------------------------
// #if DEBUG_RAW
void print_packet(void) 
{
  // int i = 0;
  // if(input_packet_len > 0) {
  //   fprintf(stdout, "len: %d\n", input_packet_len);
  //   for (i = 0; i < input_packet_len; ++i) {
  //     fprintf(stdout, "%02x ", input_packet[i]);
  //   }
  //   fprintf(stdout, "\n\n");
  // }
  volatile uint8_t i,j,k; 
#define PER_ROW 16
  if(input_packet_len > 0) {
    fprintf(stdout, "len %d", input_packet_len);
    for(j=0, k=0; j <= ( input_packet_len / PER_ROW ); j++) {
      printf("\n");
      for(i=0; i < PER_ROW; i++) {
        // if(k >= input_packet_len ) { 
        //   printf("\n");
        //   return; 
        // } 
        if(i == PER_ROW/2) {
          printf("  ");
        } 
        printf("%02x ",input_packet[j*PER_ROW + i]);
      }
      printf("\t");
      for(i=0; i < PER_ROW; i++, k++) {
        if(k >= input_packet_len ) { 
          printf("\n");
          return; 
        } 
        if(i == PER_ROW/2) {
          printf("  ");
        } 
        if(input_packet[j*PER_ROW + i] >= 0x21 && input_packet[j*PER_ROW + i] <= 0x7E){
          printf("%c ",input_packet[j*PER_ROW + i]);
        }
        else {
          printf(". ");
        }
      }
    }
    printf("\n");
  }
  return;
}
// #endif // DEBUG_RAW

//---------------------------------------------------------------------------
static void send_802154frame(unsigned char *data, int len, int sid)
{

  int pos = 0, size = 0;
  int i = 0;
  uint8_t buf[28 * 3 + PACKETBUF_SIZE + 3];

  memset(frame802154, 0, sizeof(frame802154));
  /* Frame Control Field: [7] 0-Reserved,                                                         */
  /*                      [6] 1-Intra PAN {1-Source PAN ID ommitted, 0-Source PAN ID required},   */
  /*                      [5] 1-Ack req,                                                          */
  /*                      [4] 0-Frame Pending                                                     */
  /*                      [3] 1-Security Enabled,                                                 */
  /*                      [0-2] 001-Frame type                                                    */
  frame802154[pos++] = 0x41;

  //Frame Control Field:  [14-15] 11-Source addressing mode,                                      */
  /*                      [12-13] 00-Reserved                                                     */
  /*                      [10-11] 11-Destin addressing mode,                                      */
  /*                      [8-9] 00-Reserved                                                       */
#if !DEST_BROADCAST_ADDR
  frame802154[pos++] = 0xCC;  
#else
  frame802154[pos++] = 0xC8;
#endif //DEST_BROADCAST_ADDR

  frame802154[pos++] = sid; /*Sequence Number*/
  frame802154[pos++] = IEEE802154_PANID & 0xFF; /*Destination PAN ID*/
  frame802154[pos++] = (IEEE802154_PANID >> 8) & 0xFF;

#if !DEST_BROADCAST_ADDR
  for(i=LINKADDR_SIZE-1; i >= 0; i--) { /*Destination address*/
    frame802154[pos++] = dstaddr[i];    
  }    
#else
  for(i=2-1; i >= 0; i--) { /*Destination address*/
    frame802154[pos++] = 0xFF;    
  } 
#endif //DEST_BROADCAST_ADDR
 
  /*If the Intra PAN bit is set, then ignore the Source PAN ID
  Otherwise*/
  if ((frame802154[0] & 0x40) == 0x00) {
    frame802154[pos++] = IEEE802154_PANID & 0xFF; //Source PAN ID
    frame802154[pos++] = (IEEE802154_PANID >> 8) & 0xFF;
  }

  // srcaddr.copy(buf, pos, 0, MAC_ADDR_LEN);
  // pos += 8;
  for(i=LINKADDR_SIZE-1; i >= 0; i--) { //Source address
    frame802154[pos++] = ext_addr[i];    
  }

  /* Auxillary Header - enable if security */
  if((frame802154[0] & 0x08)) {
    /* security enabled */
    frame802154[pos++] = (0x04 << 5) | (0x01 << 3); /* Security Control */
    frame802154[pos++] = 0x00; /* 4 Bytes - Frame Counter */
    frame802154[pos++] = 0x00;
    frame802154[pos++] = 0x00;
    frame802154[pos++] = 0x00;
    frame802154[pos++] = 0x01; /* Key Index */
  }
 
  for(i=0; i<len; i++) {
    frame802154[pos++] = data[i];   //data
  }  

  buf[0] = '!';
  buf[1] = 'S';
  buf[2] = sid;
  
  size = packetutils_serialize_atts(&buf[3], sizeof(buf) - 3);
  memcpy(&buf[3 + size], frame802154, pos);
  
  write_to_slip(buf, pos + size + 3);
  slip_flushbuf(); 
}

int m = 0;
int serial_input(void) 
{
  int read_bytes = 0, i = 0;
  unsigned char slip_readbuf[MAX_SLIP_BUF];
  unsigned char c;

  memset(slip_readbuf, 0, MAX_SLIP_BUF);
  //memset(input_packet, 0, MAX_SLIP_BUF);

  //Non-blocking system call
  read_bytes = read(slipfd, slip_readbuf, MAX_SLIP_BUF);
  if(read_bytes > 0) {
    //fprintf(stdout, "read(): ");
    while(i < read_bytes) {
      if(!znpmode && !zwavemode && !usermode) {
        c = slip_readbuf[i];
        switch(c) {
          case SLIP_END: 
            //End of the packet
            input_packet_len = m;
  //#if DEBUG_RAW
            print_packet();
  //#endif // DEBUG_RAW
            if(txmode) {
              if(input_packet[0] == 0x21 && input_packet[1] == 0x52) {
                report_tx_stat(input_packet[2], input_packet[3]);
              }
            }
            if(pingpongmode) {
              if(input_packet[0] == 0x61 && input_packet[1] == 0xcc) {
                pingpong_rx(input_packet[2]);
              }
            }
            if(channelstudymode) {
              if(input_packet[0] == 0x21 && input_packet[1] == 0x51) {
                got_channelstudy(&input_packet[2]);
              }
            }
            if(slipTestMode) {
              if(input_packet[0] == 0x21 && input_packet[1] == 0x54) {
                //2, 3 bytes represents the version 1.1 (latest), 4th byte is the sum of two input bytes
                if((input_packet[4] == (slipTestBytes[0] + slipTestBytes[1])) && input_packet[2] == slipTestBytes[2] && input_packet[3] == slipTestBytes[3]) {
                  fprintf(stdout, "Test successfull, slip working... \n");
                  exit(0);
                } else {
                  fprintf(stderr, "Test unsuccessful, slip not working... \n");
                  exit(2);
                }
              }
            }
            if(factoryTestMode) {
              if(strcmp(factoryPlayer, "rx") == 0) {
                //receive the packet, get the RSSI value, add it to the buffer and forward the data.
                int8_t receivedRSSI = input_packet[1];
                uint8_t sid = input_packet[5];
                input_packet[34] = receivedRSSI & 0xFF;
                input_packet[35] = sid & 0xFF;
                fprintf(stdout, "sid: %d, received RSSI: %d\n", sid, receivedRSSI);
                send_802154frame(input_packet[23], 12, sid);
              } else if(strcmp(factoryPlayer, "tx") == 0) {
                //received the reboud packet and report both RSSI with seqnumber
                if(input_packet[0] == 0x21 && input_packet[1] == 0x52) {
                  report_tx_stat(input_packet[2], input_packet[3]);
                } else {
                  total_replied++;
                  int8_t reboudRSSI = input_packet[1];
                  int8_t outgoingRSSI = input_packet[34];
                  uint8_t sid = input_packet[35];
                  packet_stat[sid][0] = 0x01;
                  packet_stat[sid][1] = outgoingRSSI;
                  packet_stat[sid][2] = reboudRSSI;
                  fprintf(stdout, "Got the reply for sid: %d, outgoingRSSI: %d, incomingRSSI: %d\n", sid, outgoingRSSI, reboudRSSI);
                }
              }
            }
            i++;
            memset(input_packet, 0, MAX_SLIP_BUF);
            m = 0;
            continue;

          case SLIP_ESC:
            i++;
            c = slip_readbuf[i];
            switch(c) {
              case SLIP_ESC_END:
                slip_readbuf[i] = SLIP_END;
              break;

              case SLIP_ESC_ESC:
                slip_readbuf[i] = SLIP_ESC;
              break;
            }
            break;

        }
      }
      input_packet[m] = slip_readbuf[i];
      //fprintf(stdout, "%02x ", input_packet[m]);
      i++;
      m++;
    }  

    if(znpmode || zwavemode) {
        input_packet_len = m;
        //print_packet();

        //handle incoming zwave response
        fprintf(stdout, "zwave response: \n");
        if(input_packet[0] == ZWAVE_COMMAND_RESP_ENABLE_INTERFACE1 && 
            input_packet[1] == ZWAVE_COMMAND_RESP_ENABLE_INTERFACE2 && 
              input_packet_len == 2) {
          fprintf(stdout, "\tchip interface enabled and is synchronized\n");
        } else if(input_packet[0] == ZWAVE_COMMAND_RESP_READ_FLASH) {
          fprintf(stdout, "\tread flash sector %02x\n", input_packet[1]);
          fprintf(stdout, "\tdata %02x\n", input_packet[3]);
        } else if(input_packet[0] == ZWAVE_COMMAND_RESP_READ_SRAM) {
          fprintf(stdout, "\tread sram\n");
          fprintf(stdout, "\taddr %02x:%02x\n", input_packet[1], input_packet[0]);
          fprintf(stdout, "\tdata %02x\n", input_packet[3]);
        } else if(input_packet[0] == ZWAVE_COMMAND_RESP_CONTINUE_READ) {
          fprintf(stdout, "\tcontinue read\n");
          fprintf(stdout, "\tdata %02x, %02x, %02x\n", input_packet[1], input_packet[2], input_packet[3]);
        } else if(input_packet[0] == ZWAVE_COMMAND_RESP_WRITE_SRAM) {
          fprintf(stdout, "\twrite sram\n");
          fprintf(stdout, "\taddr %02x:%02x\n", input_packet[1], input_packet[0]);
          fprintf(stdout, "\tdata %02x\n", input_packet[3]);
        } else if(input_packet[0] == ZWAVE_COMMAND_RESP_CONTINUE_WRITE) {
          fprintf(stdout, "\tcontinue write\n");
          fprintf(stdout, "\tdata %02x, %02x, %02x\n", input_packet[1], input_packet[2], input_packet[3]);
        } else if(input_packet[0] == ZWAVE_COMMAND_RESP_ERASE_CHIP) {
          fprintf(stdout, "\terase chip\n");
        } else if(input_packet[0] == ZWAVE_COMMAND_RESP_ERASE_SECTOR) {
          fprintf(stdout, "\terase sector\n");
          fprintf(stdout, "\tsector %02x\n", input_packet[1]);
        } else if(input_packet[0] == ZWAVE_COMMAND_RESP_WRITE_FLASH_SECTOR) {
          fprintf(stdout, "\twrite flash sector\n");
          fprintf(stdout, "\tsector %02x\n", input_packet[1]);
        } else if(input_packet[0] == ZWAVE_COMMAND_RESP_CHECK_STATE) {
          fprintf(stdout, "\tread check state\n");
          fprintf(stdout, "\tstate %02x\n", input_packet[3]);
          uint8_t i = 0x01;
          while(i != 0x00) {
            switch(input_packet[3] & i) {
              case CRC_BUSY:
                fprintf(stdout, "\tcrc busy\n");
              break;

              case CRC_DONE:
                fprintf(stdout, "\tcrc done\n");
              break;

              case CRC_FAILED:
                fprintf(stdout, "\tcrc failed\n");
              break;

              case FLASH_FSM_BUSY:
                fprintf(stdout, "\tflash fsm busy\n");
              break;

              case CONN_REFUSED:
                fprintf(stdout, "\tconnection refused\n");
              break;

              case EXEC_SRAM_MODE:
                fprintf(stdout, "\tsram executable mode enabled\n");
              break;  
            }
            i = i << 1;
          }
        } else if(input_packet[0] == ZWAVE_COMMAND_RESP_READ_SIGNATURE) {
          fprintf(stdout, "\tread signature\n");
          fprintf(stdout, "\tsignature: %02x:%02x:%02x:%02x:%02x:%02x:%02x\n", 
                      input_packet[3],input_packet[7],input_packet[11],input_packet[15],
                        input_packet[19],input_packet[23],input_packet[27]);

        } else if(input_packet[0] == ZWAVE_COMMAND_RESP_DISABLE_EOOS_MODE) {
          fprintf(stdout, "\tdisable eoos mode\n");
        } else if(input_packet[0] == ZWAVE_COMMAND_RESP_ENABLE_EOOS_MODE) {
          fprintf(stdout, "\tenable eoos mode\n");
        } else if(input_packet[0] == ZWAVE_COMMAND_RESP_SET_LOCK_BITS) {
          fprintf(stdout, "\tset lock bits\n");
        } else if(input_packet[0] == ZWAVE_COMMAND_RESP_READ_LOCK_BITS) {
          fprintf(stdout, "\tread lock bits\n");
          print_packet();
        } else if(input_packet[0] == ZWAVE_COMMAND_RESP_SET_NVR) {
          fprintf(stdout, "\tset nvr\n");
        } else if(input_packet[0] == ZWAVE_COMMAND_RESP_READ_NVR) {
          fprintf(stdout, "\tread nvr\n");
        } else if(input_packet[0] == ZWAVE_COMMAND_RESP_RUN_CRC_CHECK) {
          fprintf(stdout, "\trun crc check\n");
        } else {
          fprintf(stdout, "\tunknown command\n");
          print_packet();
        }

        //reset the incoming packet
        memset(input_packet, 0, MAX_SLIP_BUF);
        m = 0;
    } else if (usermode) {
        fprintf(stdout, "usermode receive: \n");
        print_packet();
    }

    //fprintf(stdout, "\n");    

    if(txmode) {
      txmode = 0;
      get_tx_stats();
    }

#if RX_STATS
    if( (input_packet[2] - last_seq) > 1) {
      //lost atleast one packet 
      num_lost += (input_packet[2] - last_seq) - 1;
      for(n = 0; n < ((input_packet[2] - last_seq) - 1); n++) {
        lost_seqnos[s++] = last_seq + n + 1; 
        fprintf(stdout, "lost seqno: %d\n", last_seq + n + 1);
      }
    } else if ((input_packet[2] - last_seq) == 0) {
      //received dup packets
      fprintf(stdout, "dup packet: %d\n", input_packet[2]);
      dup_pack += 1;
    }
    last_seq = input_packet[2];
    fprintf(stdout, "last_seq: %d\n", last_seq);

    if(input_packet[2] > 100) {
      fprintf(stdout, "seqno: %d\n", input_packet[2]);
      fprintf(stdout, "lost packets: %d\n", num_lost);
      fprintf(stdout, "dup packets: %d\n", dup_pack);
      int r = 0;
      fprintf(stdout, "lost seqnos: ");
      for (r = 0; r < s; r++) {
        fprintf(stdout, "%02x, ", lost_seqnos[r]);
      }
      fprintf(stdout, "\n");
      exit(1);
    }
#endif //RX_STATS
  } else if (read_bytes == -1) {
    fprintf(stderr, "read(): %s", strerror(errno));
    return 1;
  } else {
    //fprintf(stderr, "read(): %s\n", strerror(errno));
    return 1;
  }

  return 0;
}
//---------------------------------------------------------------------------
int slip_empty(void)
{
  return slip_packet_end == 0;
}
//---------------------------------------------------------------------------
int slip_flushbuf(void)
{
  int send_bytes = 0;

  if(slip_empty()) {
    //No new packet to send.. return
    return 0;
  }

  send_bytes = write(slipfd, slip_buf + slip_begin, slip_packet_end - slip_begin);

  if(send_bytes == -1) {
    fprintf(stderr, "slip_flushbuf(): write(): %s\n", strerror(errno));
    return 1;
  } else {
    slip_begin += send_bytes;
    if(slip_begin == slip_packet_end) {
      slip_packet_count--; //Keep track of how many packet needs to be sent
      if(slip_end > slip_packet_end) {
        memcpy(slip_buf, slip_buf + slip_packet_end, slip_end - slip_packet_end);
      }
      slip_end -= slip_packet_end;
      slip_begin = slip_packet_end = 0;
      if(slip_end > 0) {
        // Find end of next slip packet 
        for (send_bytes = 1; send_bytes < slip_end; send_bytes++) {
          if(slip_buf[send_bytes] == SLIP_END) {
            slip_packet_end = send_bytes + 1;
            break;
          }
        }
        //introduce a delay between slip packets to avoid losing data
        //TODO:
        return 0;
      }
    }
  }
  return 0;
}
//---------------------------------------------------------------------------
int slip_send(unsigned char c) 
{
  int ret = 0;

#if DEBUG
  fprintf(stdout, "slip_send(): %02x, %c\n", c, c);
#endif

  if(slip_end >= sizeof(slip_buf)) {
    fprintf(stderr, "slip send overflow\n");
    ret = 1; 
  }
  
  //fill the buffer and increase the index
  slip_buf[slip_end++] = c;

  slip_sent++;
  if(c == SLIP_END) {
    // received full packet
    slip_packet_count++;
    if(slip_packet_end == 0) {
      slip_packet_end = slip_end;
    }
  }
  return ret;
}
//---------------------------------------------------------------------------
void write_to_serial(const uint8_t *buf, int len) 
{
  const uint8_t *b = buf;
  int i = 0;
  for (i = 0; i < len; ++i) {
    switch(b[i]) {
      case SLIP_END:
        slip_send(SLIP_ESC);
        slip_send(SLIP_ESC_END);
        break;

      case SLIP_ESC:
        slip_send(SLIP_ESC);
        slip_send(SLIP_ESC_ESC);
        break;

      default:
        slip_send(b[i]);
        break;
    }
  }
  slip_send(SLIP_END);
}
//---------------------------------------------------------------------------
void write_to_slip(const uint8_t *buf, int len) 
{
  struct itimerval timer;
  if(slipfd > 0) {
    // if(throttle_ok) {
    //   throttle_ok = 0;
      write_to_serial(buf, len);
    //   timer.it_value.tv_sec = 0 ;
    //   timer.it_value.tv_usec = 30000;
    //   timer.it_interval.tv_sec = 0;
    //   timer.it_interval.tv_usec = 30000 ;

    //   setitimer ( ITIMER_REAL, &timer, NULL ) ;
    // }
  }
}


//---------------------------------------------------------------------------
int znpslip_send(unsigned char c) 
{
  int ret = 0;

// #if DEBUG
  fprintf(stdout, "slip_send(): %02x, %c\n", c, c);
// #endif

  if(slip_end >= sizeof(slip_buf)) {
    fprintf(stderr, "slip send overflow\n");
    ret = 1; 
  }
  
  //fill the buffer and increase the index
  slip_buf[slip_end++] = c;

  slip_sent++;
  return ret;
}
//---------------------------------------------------------------------------
void write_to_znpserial(const uint8_t *buf, int len) 
{
  const uint8_t *b = buf;
  int i = 0;
  for (i = 0; i < len; ++i) {
    znpslip_send(b[i]);
  }
  // received full packet
  slip_packet_count++;
  if(slip_packet_end == 0) {
    slip_packet_end = slip_end;
  }
}
//---------------------------------------------------------------------------
void write_to_znp(const uint8_t *buf, int len) 
{
  //struct itimerval timer;
  if(slipfd > 0) {
    // if(throttle_ok) {
    //   throttle_ok = 0;
      write_to_znpserial(buf, len);
    //   timer.it_value.tv_sec = 0 ;
    //   timer.it_value.tv_usec = 30000;
    //   timer.it_interval.tv_sec = 0;
    //   timer.it_interval.tv_usec = 30000 ;

    //   setitimer ( ITIMER_REAL, &timer, NULL ) ;
    // }
  }
}
//---------------------------------------------------------------------------
int stty_telos(void)
{
  struct termios tty;
  int ret = 0;
  int i = 0;

  //flush all the unread data
  if(tcflush(slipfd, TCIOFLUSH) == -1) {
    fprintf(stderr, "tcflush(): %s\n", strerror(errno));
    ret = 1;
  }

  //get the terminal attributes in termios structure
  if(tcgetattr(slipfd, &tty) == -1) {
    fprintf(stderr, "tcgetattr(): %s\n", strerror(errno));
    ret = 1;
  }

  //set the terminal in raw mode
  cfmakeraw(&tty);

  // Nonblocking read
  tty.c_cc[VTIME] = 0;
  tty.c_cc[VMIN] = 0;
  if(slip_flowcontrol) {
    tty.c_cflag |= CRTSCTS;
  } else {
    tty.c_cflag &= ~CRTSCTS;
  }
  tty.c_cflag &= ~HUPCL;
  tty.c_cflag &= ~CLOCAL;
  tty.c_cflag |= CS8|CREAD|CLOCAL;

  cfsetispeed(&tty, slip_baudrate);
  cfsetospeed(&tty, slip_baudrate);

  //set the above attributes
  if(tcsetattr(slipfd, TCSAFLUSH, &tty) == -1) {
    fprintf(stderr, "tcsetattr() 1: %s\n", strerror(errno));
    ret = 1;
  }

  tty.c_cflag |= CLOCAL;
  if(tcsetattr(slipfd, TCSAFLUSH, &tty) == -1) {
    fprintf(stderr, "tcsetattr() 2: %s\n", strerror(errno));
    ret = 1;
  }

  i = TIOCM_DTR;
  if(ioctl(slipfd, TIOCMBIS, &i) == -1) {
    fprintf(stderr, "ioctl(): %s\n", strerror(errno));
    ret = 1;
  }

  //wait for hardware 10 ms - node-6lbr reference
  usleep(10 * 1000);

  if(tcflush(slipfd, TCIOFLUSH) == -1) {
    fprintf(stderr, "tcflush(): %s\n", strerror(errno));
    ret = 1;
  }

  return ret;
}
//---------------------------------------------------------------------------
int slip_init(void)
{
  int ret = 0;

  //Don't know the functionality of this funtion -- ??
  setvbuf(stdout, NULL, _IOLBF, 0);

  if(slip_siodev) {
    slipfd = open(slip_siodev, O_RDWR | O_NONBLOCK);
    if(slipfd == -1) {
      fprintf(stderr, "Cannot open %s - %s\n", slip_siodev, strerror(errno));
      ret = 1;
    } else {
      if(verbose) {
        fprintf(stdout, "Slip started on %s\n", slip_siodev);
      }
      stty_telos();
    }
  } else {
    fprintf(stderr, "Slip I/O undefined\n");
    ret = 1;
  }

  return ret;
} 
//---------------------------------------------------------------------------
int slip_close(void) 
{
  int ret = 0;
  ret = close(slipfd);
  if(ret != 0) {
    fprintf(stderr, "Unable to close %s - %s\n", slip_siodev, strerror(errno));
  } else {
    if(verbose) {
      fprintf(stdout, "Slip closed successfully\n");
    }
  }
  return ret;
}
//---------------------------------------------------------------------------
int
packetutils_serialize_atts(uint8_t *data, int size)
{
  int i;
  /* set the length first later */
  int pos = 1;
  int cnt = 0;
  /* assume that values are 16-bit */
  uint16_t val;
#if DEBUG
  fprintf(stdout, "packetutils: serializing packet atts");
#endif //DEBUG
  for(i = 0; i < 3; i++) {
    val = 0x0102;
    if(val != 0) {
      if(pos + 3 > size) {
        return -1;
      }
      data[pos++] = i;
      data[pos++] = val >> 8;
      data[pos++] = val & 255;
      cnt++;
#if DEBUG
      fprintf(stdout, " %d=%d", i, val);
#endif //DEBUG
    }
  }
#if DEBUG
  fprintf(stdout, " (%d)\n", cnt);
#endif //DEBUG

  data[0] = cnt;
  return pos;
}
//---------------------------------------------------------------------------
int
packetutils_deserialize_atts(const uint8_t *data, int size)
{
  int i, cnt, pos;

  pos = 0;
  cnt = data[pos++];
  fprintf(stdout, "packetutils: deserializing %d packet atts:", cnt);
  if(cnt > 28) {
    fprintf(stdout, " *** too many: %u!\n", 28);
    return -1;
  }
  for(i = 0; i < cnt; i++) {
    if(data[pos] >= 28) {
      /* illegal attribute identifier */
      fprintf(stdout, " *** unknown attribute %u\n", data[pos]);
      return -1;
    }
    fprintf(stdout, " %d=%d", data[pos], (data[pos + 1] << 8) | data[pos + 2]);
    //packetbuf_set_attr(data[pos], (data[pos + 1] << 8) | data[pos + 2]);
    pos += 3;
  }
  fprintf(stdout, "\n");
  return pos;
}

void send_dummy_packet(void) 
{
  int pos = 0, size = 0;
  int s = 0;
  uint8_t buf[100], data[100];

  data[pos++] = 0x49;
  data[pos++] = 0xc8;
  data[pos++] = 0xfc;
  data[pos++] = 0xda;
  data[pos++] = 0x48;
  data[pos++] = 0xff;
  data[pos++] = 0xff;
  data[pos++] = 0xbb;
  data[pos++] = 0x0b;
  data[pos++] = 0x1a;
  data[pos++] = 0x00;
  data[pos++] = 0x00;
  data[pos++] = 0x09;
  data[pos++] = 0xa5;
  data[pos++] = 0x00;
  data[pos++] = 0x88;

  data[pos++] = 0x00;
  data[pos++] = 0x00;
  data[pos++] = 0x00;
  data[pos++] = 0x00;
  data[pos++] = 0x00;
  data[pos++] = 0x24;
  data[pos++] = 0x27;
  data[pos++] = 0x9d;
  data[pos++] = 0x19;
  data[pos++] = 0x60;
  data[pos++] = 0x0c;
  data[pos++] = 0x59;
  data[pos++] = 0xa4;
  data[pos++] = 0x4e;
  data[pos++] = 0xa4;
  data[pos++] = 0xcd;

  data[pos++] = 0xca;
  data[pos++] = 0xc0;
  data[pos++] = 0x56;
  data[pos++] = 0x4f;
  data[pos++] = 0x0a;


  buf[0] = '!';
  buf[1] = 'S';
  buf[2] = s++;
  
  size = packetutils_serialize_atts(&buf[3], sizeof(buf) - 3);
  memcpy(&buf[3 + size], data, pos);
  
  write_to_slip(buf, pos + size + 3);
  slip_flushbuf(); 
}
//---------------------------------------------------------------------------
void send_channel(uint8_t channel)
{
  uint8_t buf[10];
  buf[0] = '!';
  buf[1] = 'C';
  buf[2] = channel;
  write_to_slip(buf, 3);
  slip_flushbuf(); 
}
//---------------------------------------------------------------------------
void request_channel(void)
{
  uint8_t buf[10];
  buf[0] = '?';
  buf[1] = 'C';
  write_to_slip(buf, 2);
  slip_flushbuf(); 
}
//---------------------------------------------------------------------------
void testSlipRadio(void)
{
  uint8_t buf[10];
  buf[0] = '?';
  buf[1] = 'T';
  buf[2] = slipTestBytes[0];
  buf[3] = slipTestBytes[1];
  write_to_slip(buf, 4);
  slip_flushbuf(); 
}
//---------------------------------------------------------------------------
void send_txpower(uint8_t power)
{
  uint8_t buf[10];
  buf[0] = '!';
  buf[1] = 'P';
  buf[2] = power;
  write_to_slip(buf, 3);
  slip_flushbuf(); 
}
//---------------------------------------------------------------------------
void send_macaddr(uint8_t *new_macaddr)
{
  uint8_t buf[10];
  int i = 0;

  buf[0] = '!';
  buf[1] = 'M';
  
  for(i = 0; i < 8; i++) {
    buf[2 + i] = new_macaddr[i];
  }
  write_to_slip(buf, 10);
  slip_flushbuf(); 
}
//---------------------------------------------------------------------------
void request_macaddr(void)
{
  uint8_t buf[10];
  buf[0] = '?';
  buf[1] = 'M';
  write_to_slip(buf, 2);
  slip_flushbuf(); 
}
//---------------------------------------------------------------------------
void request_panid(void)
{
  uint8_t buf[10];
  buf[0] = '?';
  buf[1] = 'A';
  write_to_slip(buf, 2);
  slip_flushbuf(); 
}
//---------------------------------------------------------------------------
void request_power(void)
{
  uint8_t buf[10];
  buf[0] = '?';
  buf[1] = 'P';
  write_to_slip(buf, 2);
  slip_flushbuf(); 
}
//---------------------------------------------------------------------------
void request_shortaddr(void)
{
  uint8_t buf[10];
  buf[0] = '?';
  buf[1] = 'S';
  write_to_slip(buf, 2);
  slip_flushbuf(); 
}
//---------------------------------------------------------------------------
void request_channelstudy(void)
{
  uint8_t buf[10];
  buf[0] = '?';
  buf[1] = 'Q';
  buf[2] = 0x05;
  buf[3] = 0x0c;
  write_to_slip(buf, 4);
  slip_flushbuf(); 
}
//---------------------------------------------------------------------------
void got_channelstudy(unsigned char* data) 
{
  channelstudymode = 0;
  int i = 0;
  fprintf(stdout, "Channel study result: ");
  for(i = 0; i < 32; i++) {
    fprintf(stdout, "%02x ", data[i]);
  }
  fprintf(stdout, "\n");
}
//---------------------------------------------------------------------------
void start_tx(int num, int delay) 
{
  uint8_t buf[110] = "01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789";
  int i = 0;
  start_tx_monitor(seqno);
  for(i = 0; i < num; i++) {
    send_802154frame(buf, sizeof(buf), seqno);
    fprintf(stdout, "Sent packet seqno: %d\n", seqno);
    seqno++;
    usleep(delay*1000);
  }
  //get_tx_stats(seqno);
  num_tx_packets = seqno;
}
//---------------------------------------------------------------------------
void factoryTestRadio(int num, int delay) 
{
  if(strcmp(factoryPlayer, "rx") == 0) {

  } else if (strcmp(factoryPlayer, "tx") == 0) {
    uint8_t buf[10] = "0123456789";
    int i = 0;
    start_tx_monitor(seqno);
    for(i = 0; i < num; i++) {
      packet_stat[i][0] = 0;
      packet_stat[i][1] = 0;
      packet_stat[i][2] = 0;
      send_802154frame(buf, sizeof(buf), seqno);
      fprintf(stdout, "Sent packet seqno: %d\n", seqno);
      seqno++;
      usleep(delay*1000);
      //Should have received the reply by now.
      //verify the reply and sid and move on.
    }
    //get_tx_stats(seqno);
    num_tx_packets = seqno;
  }
}
//---------------------------------------------------------------------------
void pingpong_rx(int num) 
{
  // if(pp_first_packet) {
  //   pp_first_packet = 0;
  //   start_tx_monitor(num);
  //   start_rx_monitor(num);
  // }
  if(pingpongmode) {
    fprintf(stdout, "Received the pkt with seqno: %d\n", num);
    uint8_t buf[10] = "0123456789";
    usleep(1000000);
    send_802154frame(buf, sizeof(buf), num+1);
    fprintf(stdout, "Sent packet seqno: %d\n", num+1);
  }
  // num_tx_packets = num+1;
}
//---------------------------------------------------------------------------
void pingpong_tx(void) 
{
  uint8_t buf[10] = "0123456789";
  send_802154frame(buf, sizeof(buf), seqno);
  fprintf(stdout, "Sent packet seqno: %d\n", seqno);
  seqno++;
}
//---------------------------------------------------------------------------
void zwave_reset(void) 
{
  system("echo 1 > /sys/class/gpio/gpio4_pd3/value");
  usleep(2000000);
  system("echo 0 > /sys/class/gpio/gpio4_pd3/value");
  usleep(5200);
  system("echo 0 > /sys/class/gpio/gpio4_pd3/value");
}
//---------------------------------------------------------------------------
void zwave_enable_interface(void)
{
  uint8_t buf[10];
  buf[0] = 0xAC;
  buf[1] = 0x53;
  buf[2] = 0xAA;
  buf[3] = 0x55;
  write_to_znp(buf, 4);
  slip_flushbuf(); 
}
//---------------------------------------------------------------------------
void zwave_read_flash_sector(uint8_t sector)
{
  uint8_t buf[10];
  buf[0] = 0x10;
  buf[1] = sector;
  buf[2] = 0xFF;
  buf[3] = 0xFF;
  write_to_znp(buf, 4);
  slip_flushbuf(); 
}
//---------------------------------------------------------------------------
void zwave_continue_read(void)
{
  uint8_t buf[10];
  buf[0] = 0xA0;
  buf[1] = 0x00;
  buf[2] = 0x00;
  buf[3] = 0x00;
  write_to_znp(buf, 4);
  slip_flushbuf(); 
}
//---------------------------------------------------------------------------
void zwave_serial_reset(void)
{
  uint8_t buf[10];
  buf[0] = 0xFF;
  buf[1] = 0xFF;
  buf[2] = 0xFF;
  buf[3] = 0xFF;
  write_to_znp(buf, 4);
  slip_flushbuf(); 
}
//---------------------------------------------------------------------------
void zwave_read_signature(void)
{
  uint8_t buf[10];
  int i = 0;
  for(i = 0; i < 7; i++) {
    buf[0] = 0x30;
    buf[1] = i;
    buf[2] = 0xFF;
    buf[3] = 0xFF;
    write_to_znp(buf, 4);
    slip_flushbuf(); 
    usleep(1000000);
  }
}
//---------------------------------------------------------------------------
void zwave_read_complete_flash(int from, int to)
{
  zwave_readflash_mode = 1;
  int i = 0, j = 0;
  for(i = from; i <= to; i++) {
    fprintf(stdout, "Reading sector %d\n", i);
    zwave_read_flash_sector(i);
    usleep(100);
    for(j = 0; j < 684; j++) {
      zwave_continue_read();
      usleep(100);
    }
  }
  zwave_readflash_mode = 0;
}
//---------------------------------------------------------------------------
void zwave_program_flash()
{

}
//---------------------------------------------------------------------------
void start_dummy(int num, int delay) 
{
  //uint8_t buf[110] = "01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789";
  int i = 0;
  //start_tx_monitor(seqno);
  for(i = 0; i < num; i++) {
    send_dummy_packet();
    //fprintf(stdout, "Sent packet seqno: %d\n", seqno);
    //seqno++;
    usleep(delay*1000);
  }
  //get_tx_stats(seqno);
  //num_tx_packets = seqno;
}
//---------------------------------------------------------------------------
void usage(const char *prog) 
{
  fprintf(stderr, "usage: %s [options]\n", prog);
  fprintf(stderr, "example: %s -v -d ttyS1\n", prog);
  fprintf(stderr, "Options:\n");
  fprintf(stderr, " [-h]          help\n");
  fprintf(stderr, " [-v]          verbose      - Trace/Debug statements\n");
  fprintf(stderr, " [-d siodev]   Slip I/0 dev - Serial device (default /dev/ttyUSB0)\n");
  fprintf(stderr, " [-B baudrate] Baudrate - 9600, 19200, 38400. 57600, 115200 (default 115200)\n");
  fprintf(stderr, " [-t byte1 byte2] Slip-radio test mode - slip will return sum to two input bytes\n");
  fprintf(stderr, " [-f player channel num delay] factory test, similar to pingpong\n");
}
//---------------------------------------------------------------------------
void slip_usage(void) 
{
  fprintf(stderr, "slip-usage: [options]\n");
  fprintf(stderr, "Options:\n");
  fprintf(stderr, " [h]                 help\n");
  fprintf(stderr, " [sc channel]        Send Channel (11-25) Example- sc 13\n");
  fprintf(stderr, " [rc]                Request Channel\n");
  fprintf(stderr, " [sm mac]            Send new mac Example- sm 00 a5 09 00 00 34 55\n");
  fprintf(stderr, " [rm]                Request mac\n");
  fprintf(stderr, " [ra]                Request panid\n");
  fprintf(stderr, " [rp]                Request power\n");
  fprintf(stderr, " [rs]                Request shortaddr\n");
  fprintf(stderr, " [rq]                Start channel study\n");
  fprintf(stderr, " [p power]           Set TX power (5, 3, 1, 0)\n");
  fprintf(stderr, " [a panid]           Example- p 48da\n");
  fprintf(stderr, " [u]                 User mode, terminal input is written to uart, press 'q' to quit\n");
  fprintf(stderr, " [q]                 to quit user mode\n");
  fprintf(stderr, " [t num delay]       transmit 'n' number of packets with 'delay' in ms, Exampe- t 5 100\n");
  fprintf(stderr, " [d num delay]       send dummy packet\n");
  fprintf(stderr, " [pp player]         Pingpong test - bounce packet between tx-rx, players can be 'tx' or 'rx', Example- pp rx\n");
  fprintf(stderr, " [znp]               start ZNP mode\n");
  fprintf(stderr, " [zw-r]              Zwave reset\n");
  fprintf(stderr, " [zwave]             Zwave mode\n");
}
//---------------------------------------------------------------------------
void zwave_usage(void) 
{
  fprintf(stderr, "zwave-usage: [options]\n");
  fprintf(stderr, "Options:\n");
  fprintf(stderr, " [h]                 help\n");
  fprintf(stderr, " [zw-r]              Zwave reset\n");
  fprintf(stderr, " [ei]                Enable Interface\n");
  fprintf(stderr, " [rf sector]         Read flash sector, Ex- rf 0x01\n");
  fprintf(stderr, " [cr]                Continue read\n");
  fprintf(stderr, " [rs]                Read signature\n");
  fprintf(stderr, " [ra from to]        Read complete flash, Ex- ra 0 2, will read 3 sectors of flash\n");
  fprintf(stderr, " [reset]             Resetting the chip brings it into Normal mode\n");
}
//---------------------------------------------------------------------------s
int main(int argc, char *argv[]) 
{

  int ret = 0;
  /*************************************************/
  // Handle command line arguments
  /*************************************************/
  const char *prog;
  signed char c;

  prog = argv[0];

  //parse the command line arguments
  // ":" - colon decides whether the option requires an argument or not
  while((c = getopt(argc, argv, "hvd:B:t:")) != -1) {
    switch(c) {
      case 'v':
        verbose = 1;
        break;

      case 'd':
        if(strncmp("/dev/", optarg, 5) == 0) {
          slip_siodev = optarg;
        } else {
          char t[32];
          memset(t, 0, sizeof(t));
          strcpy(t, "/dev/");
          strncat(t, optarg, sizeof(t) - 5);
          slip_siodev = t;
        }
//#if DEBUG
        fprintf(stdout, "slip_siodev: %s\n", slip_siodev);
//#endif /* DEBUG */
        break;

      case 'B':
        slip_baudrate = atoi(optarg);
        break;

      case 't':
        slipTestMode = 1;
        slipTestBytes[byteIndex++] = atoi(optarg);
        break;

      case 'f':
        factoryTestMode = 1;
        if(byteIndex == 0) {
          factoryPlayer = optarg;
        } else {
          factoryTestBytes[byteIndex++] = atoi(optarg);
        }
        break;

      case 'h':
        usage(prog);
        return 1;
        break;

      default:
        usage(prog);
        return 1;
        break;
    }
  }

  argc -= optind - 1;
  argv += optind - 1;

  //if extra argument is passed, catch that and through exception
  if(argc > 1) {
    fprintf(stderr, "Error, unknown arguments\n");
    usage(prog);
    return 1;
  }

#if DEBUG
    fprintf(stdout, "argc: %d, argv: %s\n", argc, argv[0]);
#endif /* DEBUG */

  switch(slip_baudrate) {
    case 9600:
      slip_baudrate = B9600;
      break;
    case 19200:
      slip_baudrate = B19200;
      break; 
    case 38400:
      slip_baudrate = B38400;
      break; 
    case 57600:
      slip_baudrate = B57600;
      break; 
    case 115200:
      slip_baudrate = B115200;
      break; 
    default:
      fprintf(stderr, "Unknown baudrate: %d\n", slip_baudrate);
      return 1;
      break;    
  }
  /*************************************************/


  //Initialize slip interface
  ret = slip_init();
  if(ret) {
    fprintf(stderr, "Slip initialization failed\n");
    return 1;
  } else {
    if(verbose) {
      fprintf(stdout, "Slip initialized successfully\n");
    }
  }

  if(slipTestMode) {
    fprintf(stdout, "Testing slip radio with bytes: %d, %d\n", slipTestBytes[0], slipTestBytes[1]);
    fprintf(stdout, "Expected version: %d.%d\n", slipTestBytes[2], slipTestBytes[3]);
    testSlipRadio();
  }

  if(factoryTestMode) {
    //Set the channel
    int channel = factoryTestBytes[0];
    if(channel > 10 && channel < 26) {
      send_channel(channel); 
      // send_channel(channel); 
      fprintf(stdout, "Channel %d, set\n", channel);
    } else {
      fprintf(stderr, "Channel %d invalid, input between 11-25\n", channel);
      exit(2);
    }
    // usleep(100);

    //set the mac address based on the player
    if(strcmp(factoryPlayer, "rx") == 0) {
      fprintf(stdout, "Starting factory radio as RECEIVER\n");
      memcpy(src_mac_addr, possible_mac_addrs[0], LINKADDR_SIZE);
      memcpy(dest_mac_addr, possible_mac_addrs[1], LINKADDR_SIZE);
      send_macaddr(src_mac_addr);
      usleep(1000);
    } else if (strcmp(factoryPlayer, "tx") == 0) {
      fprintf(stdout, "Starting factory radio as TRANSMITTER\n");
      memcpy(src_mac_addr, possible_mac_addrs[1], LINKADDR_SIZE);
      memcpy(dest_mac_addr, possible_mac_addrs[0], LINKADDR_SIZE);
      send_macaddr(src_mac_addr);
      usleep(1000);
    } else {
      fprintf(stderr, "Factory test player %s not allowed\n", factoryPlayer);
      exit(2);
    }

    // request_macaddr(); //store the macaddr into src_mac_addr

    factoryTestRadio(factoryTestBytes[1], factoryTestBytes[2]);
    get_tx_stats();
    get_rx_stats();
    exit(0);
  }


  //Start sigalarm handler
  struct sigaction sa;

  memset ( &sa, 0, sizeof ( sa ) ) ;

  sa.sa_handler = &handle_alarm ;
  sigaction ( SIGALRM, &sa, NULL );




  fd_set rfds;
  struct timeval tv;
  int retval, len = 0;
  char buff[255] = {0};
  char cmd_args[10][10];
  int b = 0;

  char znp_buff[255] = {0};
  char zwave_buff[255] = {0};

  while(1) {

    /* Watch stdin (fd 0) to see when it has input. */
    FD_ZERO(&rfds);
    FD_SET(0, &rfds);
    /* Wait up to five seconds. */
    tv.tv_sec = 0;
    tv.tv_usec = 1;

    retval = select(1, &rfds, NULL, NULL, &tv);
    /* Don’t rely on the value of tv now! */

    if (retval == -1) {
      if(errno != EINTR) //Interrupted because of SIGALRM, ignore it
        fprintf(stderr, "select(): %s\n", strerror(errno)); 
    } else if (retval) {
      //fprintf(stdout,"Data is available now.\n");
      if(FD_ISSET(0, &rfds)) {
        /* Read data from stdin using fgets. */
        fgets(buff, sizeof(buff), stdin);

        /* Remove trailing newline character from the input buffer if needed. */
        len = strlen(buff) - 1;
        if(len == 0) {
          fprintf(stdout, "Return key pressed\n");
          continue;
        }
        if (buff[len] == '\n')
            buff[len] = ' ';

        //parse input commands
        memset(cmd_args, 0, sizeof(cmd_args[0][0]) * 10 * 10);
        char *start_ptr = buff;
        char *space_ptr = strchr(start_ptr, ' ');
        int arg_inx = 0;
        while(space_ptr != NULL) {
          *space_ptr++ = '\0';
          strcpy(cmd_args[arg_inx++], start_ptr);
          start_ptr = space_ptr;
          space_ptr = strchr(start_ptr, ' ');
        }

        if(znpmode) {
          memset(znp_buff, 0, sizeof(znp_buff));
          fprintf(stdout, "args: ");
          unsigned char crc;
          //Calculate CRC
          crc = 0;
          for(b = 0; b < arg_inx; b++) {
            znp_buff[b] = strtol(cmd_args[b],0,16);
            if(b != 0)
              crc ^= znp_buff[b];
            fprintf(stdout, "%ld ", strtol(cmd_args[b],0,16));
          }
          fprintf(stdout, "\n");
          znp_buff[b] = crc;
          fprintf(stdout, "crc: %d\n", znp_buff[b]);
          arg_inx++;

          fprintf(stdout, "znp buff: %s\n", znp_buff);
        }

        if(zwavemode) {
          memset(zwave_buff, 0, sizeof(zwave_buff));
          fprintf(stdout, "args: ");
          unsigned char crc;
          //Calculate CRC
          crc = 0;
          for(b = 0; b < arg_inx; b++) {
            zwave_buff[b] = strtol(cmd_args[b],0,16);
            if(b != 0)
              crc ^= zwave_buff[b];
            fprintf(stdout, "%ld ", strtol(cmd_args[b],0,16));
          }
          fprintf(stdout, "\n");
          //zwave_buff[b] = crc;
          //fprintf(stdout, "crc: %d\n", zwave_buff[b]);
          //arg_inx++;

          // fprintf(stdout, "zwave buff: %s\n", zwave_buff);
        }

        if(!usermode && !znpmode && !zwavemode) {
          fprintf(stdout, "args: ");
          for(b = 0; b < arg_inx; b++) {
            fprintf(stdout, "%s ", cmd_args[b]);
          }
          fprintf(stdout, "\n");

          if(strcmp(cmd_args[0], "h") == 0) {
            slip_usage();
            continue;
          } else if (strcmp(cmd_args[0], "sc") == 0) {
            int channel = atoi(cmd_args[1]);
            if(channel > 10 && channel < 26) {
              send_channel(channel); 
              fprintf(stdout, "Channel %d, set\n", channel);
            } else {
              fprintf(stderr, "Channel %d invalid, input between 11-25\n", channel);
            }
            continue;
          } else if (strcmp(cmd_args[0], "rc") == 0) {
            request_channel();
            fprintf(stdout, "Channel requested\n");
            continue;
          } else if (strcmp(cmd_args[0], "a") == 0) {
            fprintf(stdout, "Sending PAN ID command\n");
            //send_panid();
            continue;
          } else if (strcmp(cmd_args[0], "p") == 0) {
            int power = atoi(cmd_args[1]);
            send_txpower(power);
            fprintf(stdout, "Sent Power command %d\n", power);
            continue;
          } else if (strcmp(cmd_args[0], "rm") == 0) {
            fprintf(stdout, "Requesting MAC\n");
            request_macaddr();
            continue;
          } else if (strcmp(cmd_args[0], "ra") == 0) {
            fprintf(stdout, "Requesting PAN ID\n");
            request_panid();
            continue;
          } else if (strcmp(cmd_args[0], "rp") == 0) {
            fprintf(stdout, "Requesting power\n");
            request_power();
            continue;
          } else if (strcmp(cmd_args[0], "rs") == 0) {
            fprintf(stdout, "Requesting short addr\n");
            request_shortaddr();
            continue;
          } else if (strcmp(cmd_args[0], "rq") == 0) {
            fprintf(stdout, "Requesting channel study\n");
            channelstudymode = 1;
            request_channelstudy();
            continue;
          } else if (strcmp(cmd_args[0], "zw-r") == 0) {
            fprintf(stdout, "Resetting zm5304\n");
            zwave_reset();
            continue;
          } else if (strcmp(cmd_args[0], "sm") == 0) {
            uint8_t new_macaddr[8];
            int x = 0;
            for(x = 0; x < 8; x++) {
              new_macaddr[x] = (uint8_t)strtol(cmd_args[x+1], NULL, 16);
              // strcpy(new_macaddr + x, cmd_args[x+1]);
            }
            // new_macaddr[0] = atoi(cmd_args[1]);
            // new_macaddr[1] = atoi(cmd_args[2]);
            // new_macaddr[2] = atoi(cmd_args[3]);
            // new_macaddr[3] = atoi(cmd_args[4]);
            // new_macaddr[4] = atoi(cmd_args[5]);
            // new_macaddr[5] = atoi(cmd_args[6]);
            // new_macaddr[6] = atoi(cmd_args[7]); 
            // new_macaddr[7] = atoi(cmd_args[8]);
            send_macaddr(new_macaddr);
            fprintf(stdout, "Sent new MAC %02x:%02x:%02x:%02x:%02x:%02x:%02x:%02x\n", new_macaddr[0],new_macaddr[1],new_macaddr[2],
                                                      new_macaddr[3],new_macaddr[4],new_macaddr[5],new_macaddr[6],new_macaddr[7]);
            continue;
          } else if (strcmp(cmd_args[0], "t") == 0) {
            int num = atoi(cmd_args[1]);
            int delay = atoi(cmd_args[2]);
            txmode = 1;
            fprintf(stdout, "Transmitting num: %d with delay: %d\n", num, delay);
            if(num > 0 && delay > 0) {
              start_tx(num, delay);
            } else {
              fprintf(stderr, "num and delay input values invalid.. value should be greater than zero\n");
            }
            continue;
          } else if (strcmp(cmd_args[0], "d") == 0) {
            int num = atoi(cmd_args[1]);
            int delay = atoi(cmd_args[2]);
            // txmode = 1;
            fprintf(stdout, "Transmitting num: %d with delay: %d\n", num, delay);
            if(num > 0 && delay > 0) {
              start_dummy(num, delay);
            } else {
              fprintf(stderr, "num and delay input values invalid.. value should be greater than zero\n");
            }
            continue;
          } else if (strcmp(cmd_args[0], "pp") == 0) {
            pingpongmode = 1;
            if(strcmp(cmd_args[1], "rx") == 0) {
              fprintf(stdout, "Starting pingpong receiver\n");
            } else if (strcmp(cmd_args[1], "tx") == 0) {
              fprintf(stdout, "Starting pingpong transmitter\n");
              pingpong_tx();
            } else {
              pingpongmode = 0;
              fprintf(stderr, "Wrong player, enter either rx or tx\n");
            }
            continue;
          } else if (strcmp(cmd_args[0], "u") == 0) {
            fprintf(stdout, "Starting user mode.. to quit press q\n");
            usermode = 1;
            // continue;
          } else if (strcmp(cmd_args[0], "znp") == 0) {
            fprintf(stdout, "Starting ZNP mode...\n");
            znpmode = 1;
            continue;
          } else if (strcmp(cmd_args[0], "zwave") == 0) {
            fprintf(stdout, "Starting ZWave mode...\n");
            zwavemode = 1;
            continue;
          } else {
            fprintf(stdout, "Invalid input, try again\n");
            slip_usage();
            continue;
            // fprintf(stdout, "Sending data using user mode\n");
            // usermode = 1;
          }
        }

        if(strcmp(cmd_args[0], "q") == 0) {
          if(usermode) {
            usermode = 0;
            fprintf(stdout, "Stopping user mode\n");
          } else if (pingpongmode) {
            pingpongmode = 0;
            fprintf(stdout, "Stopping pingpong mode\n");
          } else if (znpmode) {
            znpmode = 0;
            fprintf(stdout, "Stopping ZNP mode\n");
          } else if(zwavemode) {
            zwavemode = 0;
            fprintf(stdout, "Stopping ZWave mode\n");
          }
        }

        if(usermode) {
          fprintf(stdout, "'%s' of len %d was read from stdin.\n", buff, len);
          write_to_slip((uint8_t*)buff, len);
          slip_flushbuf(); 
        } else if (znpmode) {
          fprintf(stdout, "'%s' of len %d was read from stdin.\n", znp_buff, arg_inx);
          write_to_znp((uint8_t*)znp_buff, arg_inx); 
          slip_flushbuf(); 
        } else if (zwavemode) {
          fprintf(stdout, "args: ");
          for(b = 0; b < arg_inx; b++) {
            fprintf(stdout, "%s ", cmd_args[b]);
          }
          fprintf(stdout, "\n");

          if(strcmp(cmd_args[0], "h") == 0) {
            zwave_usage();
            continue;
          } else if(strcmp(cmd_args[0], "ei") == 0) {
            fprintf(stdout, "Sending enable interface\n");
            zwave_enable_interface();
            continue;
          } else if(strcmp(cmd_args[0], "rf") == 0) {
            int sector = atoi(cmd_args[1]);
            fprintf(stdout, "Reading flash sector - %d\n", sector);
            zwave_read_flash_sector(sector);
            continue;
          } else if(strcmp(cmd_args[0], "cr") == 0) {
            fprintf(stdout, "Sending continue read\n");
            zwave_continue_read();
            continue;
          } else if(strcmp(cmd_args[0], "rs") == 0) {
            fprintf(stdout, "Reading signature\n");
            zwave_read_signature();
            continue;
          } else if (strcmp(cmd_args[0], "zw-r") == 0) {
            fprintf(stdout, "Resetting zm5304\n");
            zwave_reset();
            continue;
          } else if (strcmp(cmd_args[0], "ra") == 0) {
            fprintf(stdout, "Reading complete flash\n");
            int from = atoi(cmd_args[1]);
            int to = atoi(cmd_args[2]);
            zwave_read_complete_flash(from, to);
            continue;
          } else if (strcmp(cmd_args[0], "pf") == 0) {
            fprintf(stdout, "Start flash programming\n");
            zwave_program_flash();
            continue;
          } else if (strcmp(cmd_args[0], "reset") == 0) {
            fprintf(stdout, "Resetting the chip\n");
            zwave_serial_reset();
            continue;
          } else {
            fprintf(stdout, "User mode - send raw bytes\n");
            fprintf(stdout, "'%s' of len %d was read from stdin.\n", zwave_buff, arg_inx);
            write_to_znp((uint8_t*)zwave_buff, arg_inx); 
            slip_flushbuf();
            zwave_usage();
            continue;
          }
        }
      }
    } else {
      serial_input();
      // fprintf(stdout, "No data within five seconds.\n");
    }
  }

end:
  slip_close();

  return 0;
} //---------------------------------------------------------------------------