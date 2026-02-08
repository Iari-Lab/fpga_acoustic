#include "sesenta.hpp"
#include <assert.h>
#include <math.h>
#include <algorithm>


int main(int argc, char *argv[])
{   
    Context ctx;
    ctx.init();

    bool enableLED = atoi(argv[1]) != 0;

    Sesenta sesenta(ctx);
    sesenta.start_bf();


    return 0;
}