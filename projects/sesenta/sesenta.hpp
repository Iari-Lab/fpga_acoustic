/// (c) Koheron

#ifndef __DRIVERS_ADC_DAC_BRAM_HPP__
#define __DRIVERS_ADC_DAC_BRAM_HPP__

#include <context.hpp>
#include <array>
#include <cmath>
#include <server/drivers/dma-s2mm.hpp>
constexpr uint32_t mic_size = 512;
// constexpr uint32_t mic_size = mem::mic1_range/sizeof(uint32_t);

class Sesenta
{
  public:
    Sesenta(Context& ctx_)
    : ctx(ctx_)
    , dma(ctx.get<DmaS2MM>())
    , ctl(ctx.mm.get<mem::control>())
    , sts(ctx.mm.get<mem::status>())
    , ram(ctx.mm.get<mem::ram>())
    {
        dma_transfer_duration = n_pts / fs_adc;
    }

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

    auto get_mic(uint32_t mic_id) {
        // uint32_t samples = 2;
        uint32_t samples = ctl.read_reg(reg::n_samples);
        ctx.print<DEBUG>("Samples %d\n", samples);
        data = ram.read_array<uint32_t, data_size>();
        for (int i = 0; i < (int)samples*8; i++) {
            ctx.print<DEBUG>("%u ", data[i]);
        }
        ctx.print<DEBUG>("\n\n");
        uint32_t mic1=0;
        std::vector<double> data_ret = {};
        for (int i = 0; i < (int)samples; i++) {
            mic1 = data[mic_id + (i*8)]; 
            data_ret.push_back(mic1);
        }

        for (int i = 0; i < (int)samples*8; i++) {
            ctx.print<DEBUG>("%f ", data_ret[i]);
        }
        ctx.print<DEBUG>("\n\n");
        return data_ret;
    }

    void set_nsamples(uint32_t samples) {
        ctx.print<DEBUG>("MODE set %d ::\n", samples);
        ctl.write_reg(reg::n_samples, samples);
    }


    // fs = fs_adc / (2.0f ); // Sampling frequency (factor of 2 because of FIR)
    // dma_transfer_duration = 1.0f;
    // dma_transfer_duration = prm::n_pts / fs_adc;
    // std::array<uint32_t, data_size> data;

    uint32_t get_mic_size() {
        return mic_size;
    }

 private:

    // one minute of data
    // static constexpr uint32_t data_size = 2250000 ;
    // static constexpr uint32_t n_pts =data_size;
    // only 20 secs of data
    static constexpr uint32_t data_size = 750000 ;
    static constexpr uint32_t n_pts = data_size;
    static constexpr uint32_t read_offset = (n_pts - data_size) / 2;
    Context& ctx;
    DmaS2MM& dma;
    Memory<mem::control>& ctl;
    Memory<mem::status>& sts;
    float dma_transfer_duration;
    static constexpr float fs_adc = prm::fclk0; // ADC sampling rate (Hz)
    float fs;
    Memory<mem::ram>& ram;

    // fs = fs_adc / (2.0f ); // Sampling frequency (factor of 2 because of FIR)
    // dma_transfer_duration = 1.0f;
    // dma_transfer_duration = prm::n_pts / fs_adc;
    std::array<uint32_t, data_size> data;


}; // class AdcDacBram

#endif // __DRIVERS_ADC_DAC_BRAM_HPP__
