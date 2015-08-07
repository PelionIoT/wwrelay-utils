/* hello-ftdi.c: flash LED connected between CTS and GND.
   This example uses the libftdi API.
   Minimal error checking; written for brevity, not durability. */

#include <stdio.h>
#include <ftdi.h>

#define LED1 0x20  /* CTS (brown wire on FTDI cable) */
// idVendor           0x0403 Future Technology Devices International, Ltd
//  idProduct          0x6014 FT232H Single HS USB-UART/FIFO IC

int main()
{
    unsigned char c = 0;
    struct ftdi_context ftdic;

    /* Initialize context for subsequent function calls */
    ftdi_init(&ftdic);

    /* Open FTDI device based on FT232R vendor & product IDs */
    if(ftdi_usb_open(&ftdic, 0x0403, 0x6014) < 0) {
        puts("Can't open device");
        return 1;
    }

    /* Enable bitbang mode with a single output line */
    ftdi_enable_bitbang(&ftdic, LED1);
//    ftdi_enable_bitbang(&ftdic, LED2);
//    ftdi_enable_bitbang(&ftdic, LED3);

    /* Endless loop: invert LED state, write output, pause 1 second */
    for(;;) {
        c ^= LED1;
        ftdi_write_data(&ftdic, &c, 1);
        sleep(1);
    }
}
