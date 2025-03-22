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
    int32_t i_mic0 = 0;
    int32_t i_mic1 = 1;
    int32_t i_mic2 = 2;
    int32_t i_mic3 = 3;
    int32_t i_mic4 = 4;
    int32_t i_mic5 = 5;
    int32_t i_mic6 = 6;
    int32_t i_mic7 = 7;

    uint32_t i_rst_clk_mics = 0;
    uint32_t i_rst_leds = 1;
    unsigned int i_dma_gate = 2;

    void dma_on() {
        ctl.set_bit<reg::dma_gate, 0>();
    }
    void dma_off() {
        ctl.clear_bit<reg::dma_gate, 0>();
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
        dma.setup_transfer(mem::ram_addr, 512 * npoints );
        // dma.setup_transfer(mem::ram_addr, 256 * npoints );
        dma_on();
        double pdm_f = 30720.0;
        dma_transfer_duration = float(npoints / pdm_f);
        dma.wait_for_transfer(dma_transfer_duration); // so far this works
    }

    auto get_mics1(uint32_t samples) {
        start_dma_transfer(samples);
        ctx.print<DEBUG>("Samples-----------------> %d\n", samples);

        std::vector<int16_t> data_ret = {}; 
        int32_t offset = 0;

        for (int i = 1; i < (int)samples + 1; i++) {
            offset = (i * 30); 

            for (int mic = 0; mic < 30; mic++) {
                int16_t mic_value = ram.read_array_value_at_index<int16_t, 1>(mic + offset);
                data_ret.push_back(mic_value); 
                ctx.print<INFO>("%d ", mic_value);
            }

            ctx.print<INFO>("\n");
        }

        dma_off();
        return data_ret;
    }
    auto get_mics2(uint32_t samples) {
        start_dma_transfer(samples);
        ctx.print<DEBUG>("Samples-----------------> %d\n", samples);
        uint32_t mic1 = 0, mic2 = 0, mic3 = 0, mic4 = 0, mic5 = 0, mic6 = 0,
                mic7 = 0, mic8 = 0;
        std::vector<int32_t> data_ret = {};
        int32_t offset = 0;
        for (int i = 1; i < (int)samples + 1; i++) {
            offset = (i * 8);
            // offset = (i * 8)+(16384*8);
            mic1 = ram.read_array_value_at_index<int32_t, 1>(i_mic0 + offset);
            mic2 = ram.read_array_value_at_index<int32_t, 1>(i_mic1 + offset);
            mic3 = ram.read_array_value_at_index<int32_t, 1>(i_mic2 + offset);
            mic4 = ram.read_array_value_at_index<int32_t, 1>(i_mic3 + offset);
            mic5 = ram.read_array_value_at_index<int32_t, 1>(i_mic4 + offset);
            mic6 = ram.read_array_value_at_index<int32_t, 1>(i_mic5 + offset);
            mic7 = ram.read_array_value_at_index<int32_t, 1>(i_mic6 + offset);
            mic8 = ram.read_array_value_at_index<int32_t, 1>(i_mic7 + offset);

            data_ret.push_back(mic1);
            data_ret.push_back(mic2);
            data_ret.push_back(mic3);
            data_ret.push_back(mic4);
            data_ret.push_back(mic5);
            data_ret.push_back(mic6);
            data_ret.push_back(mic7);
            data_ret.push_back(mic8);
            ctx.print<INFO>("MICS1 %d %d %d %d %d %d %d %d\n", mic1, mic2, mic3,
                            mic4, mic5, mic6, mic7, mic8);
        }
        dma_off();
        return data_ret;
    }

    auto get_mics(uint32_t samples) {
      start_dma_transfer(samples);
      ctx.print<DEBUG>("Samples-----------------> %d\n", samples);
      uint32_t mic1 = 0, mic2 = 0, mic3 = 0, mic4 = 0, mic5 = 0, mic6 = 0,
               mic7 = 0, mic8 = 0;
      std::vector<uint32_t> data_ret = {};
      int32_t offset = 0;
      for (int i = 1; i < (int)samples + 1; i++) {
        offset = (i * 8);
        // offset = (i * 8)+(16384*8);
        mic1 = ram.read_array_value_at_index<uint32_t, 1>(i_mic0 + offset);
        mic2 = ram.read_array_value_at_index<uint32_t, 1>(i_mic1 + offset);
        mic3 = ram.read_array_value_at_index<uint32_t, 1>(i_mic2 + offset);
        mic4 = ram.read_array_value_at_index<uint32_t, 1>(i_mic3 + offset);
        mic5 = ram.read_array_value_at_index<uint32_t, 1>(i_mic4 + offset);
        mic6 = ram.read_array_value_at_index<uint32_t, 1>(i_mic5 + offset);
        mic7 = ram.read_array_value_at_index<uint32_t, 1>(i_mic6 + offset);
        mic8 = ram.read_array_value_at_index<uint32_t, 1>(i_mic7 + offset);

        data_ret.push_back(mic1);
        data_ret.push_back(mic2);
        data_ret.push_back(mic3);
        data_ret.push_back(mic4);
        data_ret.push_back(mic5);
        data_ret.push_back(mic6);
        data_ret.push_back(mic7);
        data_ret.push_back(mic8);
        ctx.print<INFO>("MICS1 %d %d %d %d %d %d %d %d\n", mic1, mic2, mic3,
                        mic4, mic5, mic6, mic7, mic8);
      }
      dma_off();
      return data_ret;
    }

    auto get_mic(uint32_t samples) {
        start_dma_transfer(samples);
        ctx.print<DEBUG>("Samples-----------------> %d\n", samples);
        uint32_t mic1=0;
        std::vector<int32_t> data_ret = {};
        for (uint32_t i = 1; i < samples + 1; i++) {
            mic1= ram.read_array_value_at_index<int32_t, 1>(i);
            data_ret.push_back(mic1);
            ctx.print<INFO>("%d ", mic1);
        }
        ctx.print<INFO>("MICS0 %d\n", mic1);
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
