#include "sesenta.hpp"
#include <assert.h>
#include <math.h>
#include <algorithm>

#define KOHERON_SERVER_PORT 36000

int main(int argc, char *argv[])
{   
    Context ctx;
    ctx.init();

    bool enableLED = atoi(argv[1]) != 0;

    Sesenta sesenta(ctx);
    if (enableLED>0) {
        sesenta.set_led_on();
    }   
    else {
        sesenta.set_led_off();
    }

    printf(" \n\n");

    return 0;
}