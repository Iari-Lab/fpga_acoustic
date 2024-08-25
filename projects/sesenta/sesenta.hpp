/// (c) Koheron

#ifndef __DRIVERS_ADC_DAC_BRAM_HPP__
#define __DRIVERS_ADC_DAC_BRAM_HPP__

#include <context.hpp>
#include <array>
#include <cmath>
constexpr uint32_t mic_size = 512;
// constexpr uint32_t mic_size = mem::mic1_range/sizeof(uint32_t);

class Sesenta
{
  public:
    Sesenta(Context& ctx_)
    : ctx(ctx_)
    , ctl(ctx.mm.get<mem::control>())
    , sts(ctx.mm.get<mem::status>())
    , mic_map(ctx.mm.get<mem::mic1>())
    , mic_map1(ctx.mm.get<mem::mic2>())
    , mic_map2(ctx.mm.get<mem::mic3>())
    , mic_map3(ctx.mm.get<mem::mic4>())
    , mic_map4(ctx.mm.get<mem::mic5>())
    , mic_map5(ctx.mm.get<mem::mic6>())
    , mic_map6(ctx.mm.get<mem::mic7>())
    , mic_map7(ctx.mm.get<mem::mic8>())
    {
    }
    // void set_led_on() {
    //     ctx.print<DEBUG>("FILTER on::\n");
    //     ctl.set_bit<reg::led, 0>();
    // }

    // void set_led_off(){
    //     ctx.print<DEBUG>("FILTER off::\n");
    //     ctl.clear_bit<reg::led, 0>();
    // }



    void trigger_addr_count_rst() {
        ctl.set_bit<reg::trig0, 0>();
        ctl.clear_bit<reg::trig0, 0>();
    }

    void trigger_mic_rst() {
        ctl.set_bit<reg::trig1, 0>();
        ctl.clear_bit<reg::trig1, 0>();
    }
    void trigger_led_rst() {
        ctl.set_bit<reg::trig2, 0>();
        ctl.clear_bit<reg::trig2, 0>();
    }


    uint32_t get_mic_size() {
        return mic_size;
    }
    auto get_mic() {
        return mic_map.read_array_value_at_index<uint32_t, 1>(0);
    }
    auto get_mic1() {
        return mic_map1.read_array_value_at_index<uint32_t, 1>(0);
    }

    auto get_mic2() {
        return mic_map2.read_array_value_at_index<uint32_t, 1>(0);
    }

    auto get_mic3() {
        return mic_map3.read_array_value_at_index<uint32_t, 1>(0);
    }

    auto get_mic4() {
        return mic_map4.read_array_value_at_index<uint32_t, 1>(0);
    }

    auto get_mic5() {
        return mic_map5.read_array_value_at_index<uint32_t, 1>(0);
    }

    auto get_mic6() {
        return mic_map6.read_array_value_at_index<uint32_t, 1>(0);
    }

    auto get_mic7() {
        return mic_map7.read_array_value_at_index<uint32_t, 1>(0);
    }
    // std::array<uint32_t, mic_size> get_mic() {
    //     // trigger_mic_rst();
    //     return mic_map.read_array<uint32_t, mic_size>();
    // }
    // std::array<uint32_t, mic_size> get_mic1() {
    //     return mic_map1.read_array<uint32_t, mic_size>();
    // }

    // std::array<uint32_t, mic_size> get_mic2() {
    //     return mic_map2.read_array<uint32_t, mic_size>();
    // }

    // std::array<uint32_t, mic_size> get_mic3() {
    //     return mic_map3.read_array<uint32_t, mic_size>();
    // }

    // std::array<uint32_t, mic_size> get_mic4() {
    //     return mic_map4.read_array<uint32_t, mic_size>();
    // }

    // std::array<uint32_t, mic_size> get_mic5() {
    //     return mic_map5.read_array<uint32_t, mic_size>();
    // }

    // std::array<uint32_t, mic_size> get_mic6() {
    //     return mic_map6.read_array<uint32_t, mic_size>();
    // }

    // std::array<uint32_t, mic_size> get_mic7() {
    //     return mic_map7.read_array<uint32_t, mic_size>();
    // }

 private:
    Context& ctx;
    Memory<mem::control>& ctl;
    Memory<mem::status>& sts;
    Memory<mem::mic1>& mic_map;
    Memory<mem::mic2>& mic_map1;
    Memory<mem::mic3>& mic_map2;
    Memory<mem::mic4>& mic_map3;
    Memory<mem::mic5>& mic_map4;
    Memory<mem::mic6>& mic_map5;
    Memory<mem::mic7>& mic_map6;
    Memory<mem::mic8>& mic_map7;


}; // class AdcDacBram

#endif // __DRIVERS_ADC_DAC_BRAM_HPP__
