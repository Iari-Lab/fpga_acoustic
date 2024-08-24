/// (c) Koheron

#ifndef __DRIVERS_ADC_DAC_BRAM_HPP__
#define __DRIVERS_ADC_DAC_BRAM_HPP__

#include <context.hpp>
#include <array>
#include <cmath>
constexpr uint32_t mic_size = mem::mic1_range/sizeof(uint32_t);

class Sesenta
{
  public:
    Sesenta(Context& ctx_)
    : ctx(ctx_)
    , ctl(ctx.mm.get<mem::control>())
    , sts(ctx.mm.get<mem::status>())
    , mic_map(ctx.mm.get<mem::mic1>())
    {
    }
    void set_led_on() {
        ctx.print<DEBUG>("FILTER on::\n");
        ctl.set_bit<reg::led, 0>();
    }

    void set_led_off(){
        ctx.print<DEBUG>("FILTER off::\n");
        ctl.clear_bit<reg::led, 0>();
    }



    void trigger_addr_count_rst() {
        ctl.set_bit<reg::trig0, 0>();
        ctl.clear_bit<reg::trig0, 0>();
    }

    void trigger_mic_rst() {
        ctl.set_bit<reg::trig1, 0>();
        ctl.clear_bit<reg::trig1, 0>();
    }

    uint32_t get_mic_size() {
        return mic_size;
    }


    std::array<uint32_t, mic_size> get_mic() {
        // trigger_addr_count_rst();
        // trigger_mic_rst();
        return mic_map.read_array<uint32_t, mic_size>();
    }

 private:
    Context& ctx;
    Memory<mem::control>& ctl;
    Memory<mem::status>& sts;
    Memory<mem::mic1>& mic_map;


}; // class AdcDacBram

#endif // __DRIVERS_ADC_DAC_BRAM_HPP__
