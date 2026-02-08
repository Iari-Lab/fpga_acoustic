#include "sesenta.hpp"
#include <assert.h>
#include <math.h>
#include <algorithm>


int main(int argc, char *argv[])
{   
    Context ctx;
    ctx.init();
    Sesenta sesenta(ctx);
    sesenta.start_bf();


    return 0;
}