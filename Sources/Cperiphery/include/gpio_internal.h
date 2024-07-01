/*
 * c-periphery
 * https://github.com/vsergeev/c-periphery
 * License: MIT
 */

#ifndef _PERIPHERY_GPIO_INTERNAL_H
#define _PERIPHERY_GPIO_INTERNAL_H

#include <stdarg.h>
#include <stdio.h>
#include <string.h>

#include "gpio.h"

/*********************************************************************************/
/* Operations table and handle structure */
/*********************************************************************************/

int gpio_cdev_read(gpio_t *gpio, bool *value);
int gpio_cdev_write(gpio_t *gpio, bool value);
int gpio_cdev_read_event(gpio_t *gpio, gpio_edge_t *edge, uint64_t *timestamp);
int gpio_cdev_poll(gpio_t *gpio, int timeout_ms);
int gpio_cdev_close(gpio_t *gpio);
int gpio_cdev_get_direction(gpio_t *gpio, gpio_direction_t *direction);
int gpio_cdev_get_edge(gpio_t *gpio, gpio_edge_t *edge);
int gpio_cdev_get_bias(gpio_t *gpio, gpio_bias_t *bias);
int gpio_cdev_get_drive(gpio_t *gpio, gpio_drive_t *drive);
int gpio_cdev_get_inverted(gpio_t *gpio, bool *inverted);
int gpio_cdev_set_direction(gpio_t *gpio, gpio_direction_t direction);
int gpio_cdev_set_edge(gpio_t *gpio, gpio_edge_t edge);
int gpio_cdev_set_bias(gpio_t *gpio, gpio_bias_t bias);
int gpio_cdev_set_drive(gpio_t *gpio, gpio_drive_t drive);
int gpio_cdev_set_inverted(gpio_t *gpio, bool inverted);
unsigned int gpio_cdev_line(gpio_t *gpio);
int gpio_cdev_fd(gpio_t *gpio);
int gpio_cdev_name(gpio_t *gpio, char *str, size_t len);
int gpio_cdev_label(gpio_t *gpio, char *str, size_t len);
int gpio_cdev_chip_fd(gpio_t *gpio);
int gpio_cdev_chip_name(gpio_t *gpio, char *str, size_t len);
int gpio_cdev_chip_label(gpio_t *gpio, char *str, size_t len);
int gpio_cdev_tostring(gpio_t *gpio, char *str, size_t len);
int gpio_sysfs_close(gpio_t *gpio);
int gpio_sysfs_read(gpio_t *gpio, bool *value);
int gpio_sysfs_write(gpio_t *gpio, bool value);
int gpio_sysfs_read_event(gpio_t *gpio, gpio_edge_t *edge, uint64_t *timestamp);
int gpio_sysfs_poll(gpio_t *gpio, int timeout_ms);
int gpio_sysfs_set_direction(gpio_t *gpio, gpio_direction_t direction);
int gpio_sysfs_get_direction(gpio_t *gpio, gpio_direction_t *direction);
int gpio_sysfs_set_edge(gpio_t *gpio, gpio_edge_t edge);
int gpio_sysfs_get_edge(gpio_t *gpio, gpio_edge_t *edge);
int gpio_sysfs_set_bias(gpio_t *gpio, gpio_bias_t bias);
int gpio_sysfs_get_bias(gpio_t *gpio, gpio_bias_t *bias);
int gpio_sysfs_set_drive(gpio_t *gpio, gpio_drive_t drive);
int gpio_sysfs_get_drive(gpio_t *gpio, gpio_drive_t *drive);
int gpio_sysfs_set_inverted(gpio_t *gpio, bool inverted);
int gpio_sysfs_get_inverted(gpio_t *gpio, bool *inverted);
unsigned int gpio_sysfs_line(gpio_t *gpio);
int gpio_sysfs_fd(gpio_t *gpio);
int gpio_sysfs_name(gpio_t *gpio, char *str, size_t len);
int gpio_sysfs_label(gpio_t *gpio, char *str, size_t len);
int gpio_sysfs_chip_fd(gpio_t *gpio);
int gpio_sysfs_chip_name(gpio_t *gpio, char *str, size_t len);
int gpio_sysfs_chip_label(gpio_t *gpio, char *str, size_t len);
int gpio_sysfs_tostring(gpio_t *gpio, char *str, size_t len);
struct gpio_ops {
    int (*read)(gpio_t *gpio, bool *value);
    int (*write)(gpio_t *gpio, bool value);
    int (*read_event)(gpio_t *gpio, gpio_edge_t *edge, uint64_t *timestamp);
    int (*poll)(gpio_t *gpio, int timeout_ms);
    int (*close)(gpio_t *gpio);
    int (*get_direction)(gpio_t *gpio, gpio_direction_t *direction);
    int (*get_edge)(gpio_t *gpio, gpio_edge_t *edge);
    int (*get_bias)(gpio_t *gpio, gpio_bias_t *bias);
    int (*get_drive)(gpio_t *gpio, gpio_drive_t *drive);
    int (*get_inverted)(gpio_t *gpio, bool *inverted);
    int (*set_direction)(gpio_t *gpio, gpio_direction_t direction);
    int (*set_edge)(gpio_t *gpio, gpio_edge_t edge);
    int (*set_bias)(gpio_t *gpio, gpio_bias_t bias);
    int (*set_drive)(gpio_t *gpio, gpio_drive_t drive);
    int (*set_inverted)(gpio_t *gpio, bool inverted);
    unsigned int (*line)(gpio_t *gpio);
    int (*fd)(gpio_t *gpio);
    int (*name)(gpio_t *gpio, char *str, size_t len);
    int (*label)(gpio_t *gpio, char *str, size_t len);
    int (*chip_fd)(gpio_t *gpio);
    int (*chip_name)(gpio_t *gpio, char *str, size_t len);
    int (*chip_label)(gpio_t *gpio, char *str, size_t len);
    int (*tostring)(gpio_t *gpio, char *str, size_t len);
};

static const struct gpio_ops gpio_cdev_ops = {
    .read = gpio_cdev_read,
    .write = gpio_cdev_write,
    .read_event = gpio_cdev_read_event,
    .poll = gpio_cdev_poll,
    .close = gpio_cdev_close,
    .get_direction = gpio_cdev_get_direction,
    .get_edge = gpio_cdev_get_edge,
    .get_bias = gpio_cdev_get_bias,
    .get_drive = gpio_cdev_get_drive,
    .get_inverted = gpio_cdev_get_inverted,
    .set_direction = gpio_cdev_set_direction,
    .set_edge = gpio_cdev_set_edge,
    .set_bias = gpio_cdev_set_bias,
    .set_drive = gpio_cdev_set_drive,
    .set_inverted = gpio_cdev_set_inverted,
    .line = gpio_cdev_line,
    .fd = gpio_cdev_fd,
    .name = gpio_cdev_name,
    .label = gpio_cdev_label,
    .chip_fd = gpio_cdev_chip_fd,
    .chip_name = gpio_cdev_chip_name,
    .chip_label = gpio_cdev_chip_label,
    .tostring = gpio_cdev_tostring,
};


static struct gpio_ops gpio_sysfs_ops = {
    .read = gpio_sysfs_read,
    .write = gpio_sysfs_write,
    .read_event = gpio_sysfs_read_event,
    .poll = gpio_sysfs_poll,
    .close = gpio_sysfs_close,
    .get_direction = gpio_sysfs_get_direction,
    .get_edge = gpio_sysfs_get_edge,
    .get_bias = gpio_sysfs_get_bias,
    .get_drive = gpio_sysfs_get_drive,
    .get_inverted = gpio_sysfs_get_inverted,
    .set_direction = gpio_sysfs_set_direction,
    .set_edge = gpio_sysfs_set_edge,
    .set_bias = gpio_sysfs_set_bias,
    .set_drive = gpio_sysfs_set_drive,
    .set_inverted = gpio_sysfs_set_inverted,
    .line = gpio_sysfs_line,
    .fd = gpio_sysfs_fd,
    .name = gpio_sysfs_name,
    .label = gpio_sysfs_label,
    .chip_fd = gpio_sysfs_chip_fd,
    .chip_name = gpio_sysfs_chip_name,
    .chip_label = gpio_sysfs_chip_label,
    .tostring = gpio_sysfs_tostring,
};

struct gpio_handle {
    const struct gpio_ops *ops;

    union {
        struct {
            unsigned int line;
            int line_fd;
            int chip_fd;
            gpio_direction_t direction;
            gpio_edge_t edge;
            gpio_bias_t bias;
            gpio_drive_t drive;
            bool inverted;
            char label[32];
        } cdev;
        struct {
            unsigned int line;
            int line_fd;
            bool exported;
        } sysfs;
    } u;

    /* error state */
    struct {
        int c_errno;
        char errmsg[96];
    } error;
};

/*********************************************************************************/
/* Common error formatting function */
/*********************************************************************************/

inline static int _gpio_error(gpio_t *gpio, int code, int c_errno, const char *fmt, ...) {
    va_list ap;

    gpio->error.c_errno = c_errno;

    va_start(ap, fmt);
    vsnprintf(gpio->error.errmsg, sizeof(gpio->error.errmsg), fmt, ap);
    va_end(ap);

    /* Tack on strerror() and errno */
    if (c_errno) {
        char buf[64];
        strerror_r(c_errno, buf, sizeof(buf));
        snprintf(gpio->error.errmsg+strlen(gpio->error.errmsg), sizeof(gpio->error.errmsg)-strlen(gpio->error.errmsg), ": %s [errno %d]", buf, c_errno);
    }

    return code;
}

#endif

