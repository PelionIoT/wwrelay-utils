/*
 * Copyright (c) 2018, Arm Limited and affiliates.
 * SPDX-License-Identifier: Apache-2.0
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

/**
* slipcomms: communication interface to debug cc2530 slip-radio
* Copyright: WigWag Inc.
* Author: Yash
**/

#ifndef _SLIP_COMMS_H_
#define _SLIP_COMMS_H_

#define DEBUG 0
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

#define DEST_BROADCAST_ADDR 0

#endif /* _SLIP_COMMS_H_ */