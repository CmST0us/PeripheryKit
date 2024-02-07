//
//  shims.h
//  
//
//  Created by Eric Wu on 2024/2/1.
//

#ifndef shims_h
#define shims_h

#include <stdio.h>
#include <time.h>
#include <errno.h>

void precise_sleep(time_t sec, long nsec);

#endif /* shims_h */
