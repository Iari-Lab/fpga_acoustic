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
    }

     const int32_t i_mic0 = 0;
     const int32_t i_mic1 = 1;
     const int32_t i_mic2 = 2;
     const int32_t i_mic3 = 3;
     const int32_t i_mic4 = 4;
     const int32_t i_mic5 = 5;
     const int32_t i_mic6 = 6;
     const int32_t i_mic7 = 7;

    uint32_t i_rst_clk_mics = 0;
    uint32_t i_rst_leds = 1;
    unsigned int i_dma_gate = 2;


    void reset_led() {
        ctx.print<DEBUG>(" reset led::\n");
        ctl.set_bit<reg::rst_regs, 2>();
        ctl.clear_bit<reg::rst_regs, 2>();
    }
    void reset_clk_mics() {
        ctx.print<DEBUG>(" reset clk mics::\n");
        ctl.set_bit<reg::rst_regs, 0>();
        ctl.clear_bit<reg::rst_regs,0>();
    }
    void reset_clk_leds() {
        ctx.print<DEBUG>(" reset leds clk::\n");
        ctl.set_bit<reg::rst_regs, 1>();
        ctl.clear_bit<reg::rst_regs,1>();
    }

    void dma_on() {
        ctl.set_bit<reg::rst_regs, 3>();
        ctx.print<DEBUG>(" DMA on::\n");
    }
    void dma_off() {
        ctl.clear_bit<reg::rst_regs, 3>();
        ctx.print<DEBUG>(" DMA off::\n");
    }

    void set_nsamples(uint32_t samples) {
        ctx.print<DEBUG>(" set SAMPLES %d ::\n", samples);
        ctl.write_reg(reg::n_samples, samples);
    }

    auto get_nsamples() {
        uint32_t samples = ctl.read_reg(reg::n_samples);
        ctx.print<DEBUG>(" GET SAMPLES %d ::\n", samples);
        return samples;
    }

    void start_dma_transfer(uint32_t samples) {
        set_nsamples(samples + read_offset);
        uint32_t npoints = get_nsamples();
        dma.setup_transfer(mem::ram_addr, 256 * npoints );
        dma_on();
        dma_transfer_duration = npoints / 4000000;
        dma.wait(dma_transfer_duration); // so far this works
    }

    auto get_mics(uint32_t samples) {
        start_dma_transfer(samples);
        ctx.print<DEBUG>("Samples-----------------> %d\n", samples);
        uint32_t mic1=0,mic2=0,mic3=0,mic4=0,mic5=0,mic6=0,mic7=0,mic8=0;
        std::vector<uint32_t> data_ret = {};
        uint32_t offset = 0;
        for (int i = 1; i < (int)samples + 1; i++) {
            offset = i * 8;
            mic1= ram.read_array_value_at_index<uint32_t, 1>(i_mic0 + offset);
            mic2= ram.read_array_value_at_index<uint32_t, 1>(i_mic1 + offset);
            mic3= ram.read_array_value_at_index<uint32_t, 1>(i_mic2 + offset);
            mic4= ram.read_array_value_at_index<uint32_t, 1>(i_mic3 + offset);
            mic5= ram.read_array_value_at_index<uint32_t, 1>(i_mic4 + offset);
            mic6= ram.read_array_value_at_index<uint32_t, 1>(i_mic5 + offset);
            mic7= ram.read_array_value_at_index<uint32_t, 1>(i_mic6 + offset);
            mic8= ram.read_array_value_at_index<uint32_t, 1>(i_mic7 + offset);    

            data_ret.push_back(mic1);
            data_ret.push_back(mic2);
            data_ret.push_back(mic3);
            data_ret.push_back(mic4);
            data_ret.push_back(mic5);
            data_ret.push_back(mic6);
            data_ret.push_back(mic7);
            data_ret.push_back(mic8);
            ctx.print<INFO>("MICS1 %d %d %d %d %d %d %d %d\n", mic1, mic2, mic3, mic4,mic5, mic6, mic7, mic8);
        }
        dma_off();
        return data_ret;
    }



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
    static constexpr uint32_t read_offset = 5;
    Context& ctx;
    DmaS2MM& dma;
    Memory<mem::control>& ctl;
    Memory<mem::status>& sts;
    float dma_transfer_duration;
    static constexpr float fs_adc = prm::fclk0; 
    float fs;
    Memory<mem::ram>& ram;



}; // class AdcDacBram

#endif // __DRIVERS_ADC_DAC_BRAM_HPP__
