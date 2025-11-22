/// (c) Koheron

#ifndef __DRIVERS_SESENTA_HPP__
#define __DRIVERS_SESENTA_HPP__

#include <array>
#include <cmath>
#include <context.hpp>
#include <server/drivers/dma-s2mm.hpp>
// constexpr uint32_t mic_size = 512;
// constexpr uint32_t mic_size = 2048;
constexpr uint32_t mic_size = mem::mic0_range / sizeof(uint32_t);

class Sesenta {
public:
  Sesenta(Context &ctx_)
      : ctx(ctx_), dma(ctx.get<DmaS2MM>()), ctl(ctx.mm.get<mem::control>()),
        sts(ctx.mm.get<mem::status>()), ram(ctx.mm.get<mem::ram>()),
        ram2(ctx.mm.get<mem::ram2>()), mic0_br(ctx.mm.get<mem::mic0>()),
        mic1_br(ctx.mm.get<mem::mic1>()), mic2_br(ctx.mm.get<mem::mic2>()),
        mic3_br(ctx.mm.get<mem::mic3>()) 

  {
    ctx.print<INFO>("BEAm------------------------------------------>-\n");
    start_beamforming();
  }
  ~Sesenta() {
    beamforming_started = false;
    beamforming_thread.join();
  }
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
    dma.setup_transfer(mem::ram_addr, mem::ram2_addr, 256 * npoints);
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
  auto read_mics6(uint32_t samples) {
    const int num_mics = 8;
    const int total_mics = 2;
    ctx.print<DEBUG>("Samples-----------------> %d\n", samples);
    uint32_t mic = 0;
    uint32_t mic2 = 0;
    std::vector<int32_t> data_ret = {};
    int32_t offset = 0;
    for (int i = 1; i < (int)samples + 1; i++) {
      offset = (i * num_mics); // s
      ctx.print<INFO>("MICS1 ");
      for (int mic_idx = 0; mic_idx < total_mics; mic_idx++) {
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
      ctx.print<INFO>("-\n");
    }
    for (int i = 1; i < (int)samples + 1; i++) {
      offset = (i * num_mics); // s
      ctx.print<INFO>("MICS2 ");
      for (int mic_idx = 0; mic_idx < total_mics; mic_idx++) {
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
      ctx.print<INFO>("-\n");
    }
    return data_ret;
  }

  auto get_mics6(uint32_t samples) {
    const int num_mics = 8;
    const int total_mics = 2;
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
      for (int mic_idx = 0; mic_idx < total_mics; mic_idx++) {
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
      ctx.print<INFO>("-\n");
    }
    for (int i = 1; i < (int)samples + 1; i++) {
      offset = (i * num_mics); // s
      ctx.print<INFO>("MICS2 ");
      for (int mic_idx = 0; mic_idx < total_mics; mic_idx++) {
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
      ctx.print<INFO>("-\n");
    }
    return data_ret;
  }

  auto get_mics4(uint32_t samples) {
    const int num_mics = 8;
    const int total_mics = 4;
    start_dma_transfer(samples);
    ctx.print<DEBUG>("Samples-----------------> %d\n", samples);
    uint32_t mic = 0;
    std::vector<int32_t> data_ret = {};
    int32_t offset = 0;
    dma_off();
    dma1_off();
    for (int i = 1; i < (int)samples + 1; i++) {
      offset = (i * num_mics); // s
      ctx.print<INFO>("MICS1 ");
      for (int mic_idx = 0; mic_idx < total_mics; mic_idx++) {
        mic = ram.read_array_value_at_index<uint32_t, 1>(mic_idx + offset);
        data_ret.push_back(mic);
        ctx.print<INFO>(" %d", mic);
      }
      ctx.print<INFO>("-\n");
    }
    return data_ret;
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
      offset = (i * 8); // s
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
  std::array<uint32_t, mic_size> get_mic_ith(uint32_t mic_idx) {
    std::array<uint32_t, mic_size> raw_data;
    
    switch (mic_idx) {
      case 0: raw_data = mic0_br.read_array<uint32_t, mic_size>(); break;
      case 1: raw_data = mic1_br.read_array<uint32_t, mic_size>(); break;
      case 2: raw_data = mic2_br.read_array<uint32_t, mic_size>(); break;
      case 3: raw_data = mic3_br.read_array<uint32_t, mic_size>(); break;
      default:
        ctx.print<ERROR>("Invalid microphone index: %d\n", mic_idx);
        return std::array<uint32_t, mic_size>{0};
    }
    
    for (uint32_t i = 0; i < mic_size; i++) {
      ctx.print<DEBUG>(" Raw data[%d]: 0x%08X\n", i, raw_data[i]);
    }
    
    return raw_data;
  }
  // std::array<uint32_t, mic_size> get_mic_ith(uint32_t mic_idx) {
  //   switch (mic_idx) {
  //   case 0:
  //     return mic0_br.read_array<uint32_t, mic_size>();
  //   case 1:
  //     return mic1_br.read_array<uint32_t, mic_size>();
  //   case 2:
  //     return mic2_br.read_array<uint32_t, mic_size>();
  //   case 3:
  //     return mic3_br.read_array<uint32_t, mic_size>();
  //   default:
  //     return std::array<uint32_t, mic_size>{0};
  //   }
  // }

  void set_mic_sel(uint32_t sel) { 
    ctl.write_reg(reg::mic_select, sel);
    ctl.set_bit<reg::start_capture, 0>(); 
    std::this_thread::sleep_for(std::chrono::microseconds(1));
    ctl.clear_bit<reg::start_capture, 0>(); 
   }

  void set_led_sel(uint32_t sel) { ctl.write_reg(reg::led_select, sel); }

  uint32_t get_mic_size() { return mic_size; }
  void start_beamforming();

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
  Memory<mem::mic0> &mic0_br;
  Memory<mem::mic1> &mic1_br;
  Memory<mem::mic2> &mic2_br;
  Memory<mem::mic3> &mic3_br;
  // Memory<mem::mic4> &mic4_br;
  // Memory<mem::mic5> &mic5_br;

  std::atomic<bool> beamforming_started{false};
  std::thread beamforming_thread;
  // static constexpr std::array<uint8_t, 7> M_DATA_TO_MIC = {
  //     31, // M_DATA[0] → MIC31 (from M28: 59-28=31)
  //     37, // M_DATA[1] → MIC37 (from M22: 59-22=37)
  //     25, // M_DATA[2] → MIC25 (from M34: 59-34=25)
  //     28, // M_DATA[3] → MIC28 (from M31: 59-31=28)
  //     34, // M_DATA[4] → MIC34 (from M25: 59-25=34)
  //     40  // M_DATA[5] → MIC40 (from M19: 59-19=40)
  // };

  static constexpr std::array<uint8_t, 4> M_DATA_TO_MIC = {
      20, // M_DATA[0] → MIC39 
      8, // M_DATA[1] → MIC51 
      2, // M_DATA[2] → MIC57 
      14  // M_DATA[3] → MIC45 
  };
  void beamf_thread();

}; // class Sesenta

inline void Sesenta::start_beamforming() {

      ctx.print<INFO>(" enter thread\n");
  if (!beamforming_started) {
    beamforming_thread = std::thread{&Sesenta::beamf_thread, this};
    // start_beamforming.
    beamforming_thread.detach();
    // beamf_thread();
  }
}
inline void Sesenta::beamf_thread() {
  const int num_mics = 4;
  const int num_directions = 4;
  
  beamforming_started = true;
  ctx.print<INFO>("Beamforming thread started for 6 mics.\n");
  
  const double pcm_sample_rate = 48000.0; // 48 kHz
  const double buffer_fill_time_ms = (1 / pcm_sample_rate) * 1000.0;
  
  ctx.print<INFO>("BRAM buffer size: %u samples\n", mic_size);
  ctx.print<INFO>("Required wait time per direction: %.2f ms\n", buffer_fill_time_ms);
  
  while (beamforming_started) {
    std::array<double, num_directions> beam_powers = {0.0};
    
    // Iterate through each of the 6 possible sound source directions
    for (int dir = 0; dir < num_directions; dir++) {
        set_mic_sel(dir);
        while ((sts.read_reg(reg::done_capture) & 0x1)) {
          std::this_thread::sleep_for(
            std::chrono::milliseconds(25) // Add 5ms margin
          );
        }      


      
      std::array<double, mic_size> beamformed_signal = {0.0};
      
      for (int mic = 0; mic < num_mics; mic++) {
        auto mic_data = get_mic_ith(mic);
        
        for (uint32_t sample_idx = 0; sample_idx < mic_size; sample_idx++) {
          beamformed_signal[sample_idx] += static_cast<double>(mic_data[sample_idx]);
        }
      }
      
      double power = 0.0;
      for (uint32_t sample_idx = 0; sample_idx < mic_size; sample_idx++) {
        power += beamformed_signal[sample_idx] * beamformed_signal[sample_idx];
      }
      
      beam_powers[dir] = power;
      ctx.print<DEBUG>("Direction %d: Power = %e\n", dir, power);
    }
    
    int max_direction = 0;
    double max_power = 0.0;
    for (int dir = 0; dir < num_directions; dir++) {
      if (beam_powers[dir] > max_power) {
        max_power = beam_powers[dir];
        max_direction = dir;
      }
    }
    
    ctx.print<INFO>(
        "Maximum sound energy detected from direction: %d (Power: %e)\n",
        max_direction, max_power);
    
    set_led_sel(M_DATA_TO_MIC[max_direction]);
    
    // Optional delay to control the update rate of the LEDs
    // std::this_thread::sleep_for(std::chrono::milliseconds(100));
  }
}
// inline void Sesenta::beamf_thread() {
//   const int num_mics = 6;
//   const int num_directions = 6;
//   beamforming_started = true;

//       ctx.print<INFO>(" enter thread Hansem\n");
//   while (beamforming_started) {

//       ctx.print<INFO>(" infinit\n");
//     std::array<double, num_directions> beam_powers = {0};
//     for (int dir = 0; dir < num_directions; dir++) {
//       set_mic_sel(dir);
//       std::array<double, mic_size> beamformed_signal = {0};
//       // Sum signals delayed from all microphones
//       for (int mic = 0; mic < num_mics; mic++) {
//         auto mic_data = get_mic_ith(mic);
//         // Add each sample
//         for (uint32_t sample = 0; sample < mic_size; sample++) {
//           beamformed_signal[sample] += static_cast<double>(mic_data[sample]);
//         }
//       }
//       // Calculate the power (energy) of the beamformed
//       double power = 0.0;
//       for (uint32_t sample = 0; sample < mic_size; sample++) {
//         power += beamformed_signal[sample] * beamformed_signal[sample];
//       }
//       beam_powers[dir] = power;
//     }
//     // direction with maximum power
//     int max_direction = 0;
//     double max_power = beam_powers[0];
//     for (int dir = 1; dir < num_directions; dir++) {
//       if (beam_powers[dir] > max_power) {
//         max_power = beam_powers[dir];
//         max_direction = dir;
//       }
//     }
//     ctx.print<INFO>(
//         "Maximum sound energy detected from direction: %d (Power: %f)\n",
//         max_direction, max_power);
//     set_led_sel(M_DATA_TO_MIC[max_direction]);
//   }
// }

#endif // __SESENTA_HPP__
