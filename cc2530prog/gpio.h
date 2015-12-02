#ifndef __CC2530PROG_GPIO_H
#define __CC2530PROG_GPIO_H

#ifndef GPIO_BACKEND
#error "unknown GPIO backend"
#endif

#include <stdbool.h>

/* Reset polarity is active low */
#define RST_GPIO        5
#define  RST_GPIO_POL   !        Active low polarity 
#define CCLK_GPIO       6
#define DATA_GPIO       7

extern int relay_version;

extern unsigned int reset_gpio;
extern unsigned int data_gpio;
extern unsigned int clk_gpio;
/*
 * gpio sysfs helpers
 */
enum gpio_direction {
	GPIO_DIRECTION_IN,
	GPIO_DIRECTION_OUT,
	GPIO_DIRECTION_HIGH,
};

int gpio_export(int n);
int gpio_unexport(int n);
int gpio_set_direction(int n, enum gpio_direction direction);
int gpio_get_value(int n, bool *value);
int gpio_set_value(int n, bool value);

#endif /* __CC2530PROG_GPIO_H */
