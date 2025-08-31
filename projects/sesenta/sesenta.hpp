/// (c) Koheron

#ifndef __DRIVERS_ADC_DAC_BRAM_HPP__
#define __DRIVERS_ADC_DAC_BRAM_HPP__

#include <array>
#include <cmath>
#include <context.hpp>
#include <server/drivers/dma-s2mm.hpp>
constexpr uint32_t mic_size = 512;
// constexpr uint32_t mic_size = mem::mic1_range/sizeof(uint32_t);

class Sesenta {
public:
  Sesenta(Context &ctx_)
      : ctx(ctx_), dma(ctx.get<DmaS2MM>()), ctl(ctx.mm.get<mem::control>()),
        sts(ctx.mm.get<mem::status>()), ram(ctx.mm.get<mem::ram>()),
        ram2(ctx.mm.get<mem::ram2>()) {}
  uint32_t i_rst_clk_mics = 0;
  uint32_t i_rst_leds = 1;
  unsigned int i_dma_gate = 2;

  void dma_on() { ctl.set_bit<reg::dma_gate, 0>(); }
  void dma_off() { ctl.clear_bit<reg::dma_gate, 0>(); }
  void dma1_on() { ctl.set_bit<reg::dma_gate1, 0>(); }
  void dma1_off() { ctl.clear_bit<reg::dma_gate1, 0>(); }

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
    dma.setup_transfer(mem::ram_addr, mem::ram2_addr, 512 * npoints);
    dma_on();
    dma1_on();
    double pdm_f = 3072.0;
    dma_transfer_duration = float(npoints / pdm_f);
    dma.wait_for_transfer(dma_transfer_duration); // so far this works
  }

  void split_mic_value(uint32_t mic_value, uint16_t &mic1, uint16_t &mic2) {
    mic1 = mic_value & 0xFFFF;
    mic2 = (mic_value >> 16) & 0xFFFF;
  }

  auto get_mics(uint32_t samples) {
    const int num_mics = 16;
    start_dma_transfer(samples);
    ctx.print<DEBUG>("Samples-----------------> %d\n", samples);
    uint32_t mic = 0;
    uint32_t mic2 = 0;
    std::vector<int32_t> data_ret = {};
    int32_t offset = 0;
    dma_off();
    dma1_off();
    for (int i = 1; i < (int)samples + 1; i++) {
      offset = (i * num_mics); // s
      ctx.print<INFO>("MICS1 ");
      for (int mic_idx = 0; mic_idx < num_mics; mic_idx++) {
        mic = ram.read_array_value_at_index<uint32_t, 1>(mic_idx + offset);
        uint16_t _mic1 = 0;
        uint16_t _mic2 = 0;
        split_mic_value(mic, _mic1, _mic2);
        int32_t mic1_signed = static_cast<int32_t>(static_cast<int16_t>(_mic1));
        int32_t mic2_signed = static_cast<int32_t>(static_cast<int16_t>(_mic2));
        data_ret.push_back(mic1_signed);
        data_ret.push_back(mic2_signed);
        ctx.print<INFO>(" %d %d", mic1_signed, mic2_signed);
      }
      ctx.print<INFO>("\n");
    }
    for (int i = 1; i < (int)samples + 1; i++) {
      offset = (i * num_mics); // s
      ctx.print<INFO>("MICS2 ");
      for (int mic_idx = 0; mic_idx < num_mics; mic_idx++) {
        mic2 = ram2.read_array_value_at_index<uint32_t, 1>(mic_idx + offset);
        uint16_t _mic1 = 0;
        uint16_t _mic2 = 0;
        split_mic_value(mic2, _mic1, _mic2);
        int32_t mic1_signed = static_cast<int32_t>(static_cast<int16_t>(_mic1));
        int32_t mic2_signed = static_cast<int32_t>(static_cast<int16_t>(_mic2));
        data_ret.push_back(mic1_signed);
        data_ret.push_back(mic2_signed);
        ctx.print<INFO>(" %d %d", mic1_signed, mic2_signed);
      }
      ctx.print<INFO>("\n");
    }
    return data_ret;
  }

  auto get_mics_ith(uint32_t samples, uint32_t mic_idx) {
    start_dma_transfer(samples);
    ctx.print<DEBUG>("Samples-----------------> %d\n", samples);
    uint32_t mic = 0;
    uint32_t mic2 = 0;
    std::vector<int32_t> data_ret = {};
    int32_t offset = 0;
    dma_off();
    dma1_off();
    for (int i = 1; i < (int)samples + 1; i++) {
      offset = (i * 16); // s
      ctx.print<INFO>("MICS1 ");
      mic = ram.read_array_value_at_index<uint32_t, 1>(mic_idx + offset);
      uint16_t _mic1 = 0;
      uint16_t _mic2 = 0;
      split_mic_value(mic, _mic1, _mic2);
      int32_t mic1_signed = static_cast<int32_t>(static_cast<int16_t>(_mic1));
      int32_t mic2_signed = static_cast<int32_t>(static_cast<int16_t>(_mic2));
      data_ret.push_back(mic1_signed);
      data_ret.push_back(mic2_signed);
      ctx.print<INFO>(" %d %d", mic1_signed, mic2_signed);
      ctx.print<INFO>("MICS2 ");
      mic2 = ram2.read_array_value_at_index<uint32_t, 1>(mic_idx + offset);
      _mic1 = 0;
      _mic2 = 0;
      split_mic_value(mic2, _mic1, _mic2);
      mic1_signed = static_cast<int32_t>(static_cast<int16_t>(_mic1));
      mic2_signed = static_cast<int32_t>(static_cast<int16_t>(_mic2));
      data_ret.push_back(mic1_signed);
      data_ret.push_back(mic2_signed);
      ctx.print<INFO>(" %d %d", mic1_signed, mic2_signed);
      ctx.print<INFO>("\n");
    }
    return data_ret;
  }

  void set_mic_sel(uint32_t sel) { ctl.write_reg(reg::mic_select, sel); }

  uint32_t get_mic_size() { return mic_size; }

private:
  // one minute of data
  // static constexpr uint32_t data_size = 2250000 ;
  // static constexpr uint32_t n_pts =data_size;
  // only 20 secs of data
  static constexpr uint32_t data_size = 750000;
  static constexpr uint32_t n_pts = data_size;
  static constexpr uint32_t read_offset = 5;
  Context &ctx;
  DmaS2MM &dma;
  Memory<mem::control> &ctl;
  Memory<mem::status> &sts;
  float dma_transfer_duration;
  static constexpr float fs_adc = prm::fclk0;
  float fs;
  Memory<mem::ram> &ram;
  Memory<mem::ram2> &ram2;

}; // class AdcDacBram

#endif // __DRIVERS_ADC_DAC_BRAM_HPP__
