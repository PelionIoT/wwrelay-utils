/**
* slipcomms: communication interface to debug cc2530 slip-radio
* Copyright: WigWag Inc.
* Author: Yash
**/

#ifndef _SLIP_COMMS_H_
#define _SLIP_COMMS_H_

#define DEBUG 1

#define BAUDRATE 115200

#define SLIP_END     0300
#define SLIP_ESC     0333
#define SLIP_ESC_END 0334
#define SLIP_ESC_ESC 0335

#define MAX_SLIP_BUF 2048

#endif /* _SLIP_COMMS_H_ */