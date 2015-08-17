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

#include "slipcomms.h"

unsigned int verbose = 0;
const char *slip_siodev = NULL;
speed_t slip_baudrate = BAUDRATE;
int slip_flowcontrol = 0;

int slipfd = 0;
int slip_end = 0, slip_begin = 0, slip_packet_end = 0, slip_packet_count = 0, slip_sent = 0;
unsigned char slip_buf[MAX_SLIP_BUF];

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
  if(slipfd > 0) {
    write_to_serial(buf, len);
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
void usage(const char *prog) 
{
  fprintf(stderr, "usage: %s [options]\n", prog);
  fprintf(stderr, "example: %s -v -d ttyS1\n", prog);
  fprintf(stderr, "Options:\n");
  fprintf(stderr, " [-h]          help\n");
  fprintf(stderr, " [-v]          verbose      - Trace/Debug statements\n");
  fprintf(stderr, " [-d siodev]   Slip I/0 dev - Serial device (default /dev/ttyUSB0)\n");
  fprintf(stderr, " [-B baudrate] Baudrate - 9600, 19200, 38400. 57600, 115200 (default 115200)\n");
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
  while((c = getopt(argc, argv, "hvd:B:")) != -1) {
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
#if DEBUG
        fprintf(stdout, "slip_siodev: %s\n", slip_siodev);
#endif /* DEBUG */
        break;

      case 'B':
        slip_baudrate = atoi(optarg);
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

  uint8_t buffer[5] = "hello";
  write_to_slip(buffer, sizeof(buffer));
  slip_flushbuf();

  slip_close();

  return 0;
}
//---------------------------------------------------------------------------