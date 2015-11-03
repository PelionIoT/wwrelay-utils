/**
* slipcomms: communication interface to debug cc2530 slip-radio
* Copyright: WigWag Inc.
* Author: Yash
**/

#ifndef _SLIP_COMMS_H_
#define _SLIP_COMMS_H_

#define DEBUG 1
#define DEBUG_RAW 1
#define RX_STATS 0

#define BAUDRATE 115200

#define SLIP_END     0300
#define SLIP_ESC     0333
#define SLIP_ESC_END 0334
#define SLIP_ESC_ESC 0335

#define MAX_SLIP_BUF 10000

#define RELAY_1 1
#define IEEE802154_PANID 0x48DA
#define PACKETBUF_SIZE 128
#define LINKADDR_SIZE 8

#define DEST_BROADCAST_ADDR 1

#endif /* _SLIP_COMMS_H_ */