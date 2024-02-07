//
//  shims.c
//  
//
//  Created by Eric Wu on 2024/2/1.
//

#include "shims.h"

// 精确休眠函数
void precise_sleep(time_t sec, long nsec) {
    // 规范化 nsec
    while (nsec >= 1000000000) {
        nsec -= 1000000000;
        sec++;
    }

    struct timespec req, rem;
    req.tv_sec = sec;
    req.tv_nsec = nsec;

    while (clock_nanosleep(CLOCK_MONOTONIC, 0, &req, &rem) == -1) {
        if (errno == EINTR) {
            printf("clock_nanosleep interrupted, remaining time: %ld seconds and %ld nanoseconds\n", rem.tv_sec, rem.tv_nsec);
            req = rem; // 设置剩余的时间
        } else {
            perror("clock_nanosleep failed");
            return;
        }
    }
}
