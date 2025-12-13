/// (c) Koheron

#ifndef __DRIVERS_SESENTA_HPP__
#define __DRIVERS_SESENTA_HPP__

#include <array>
#include <chrono>
#include <cmath>
#include <context.hpp>
#include <iostream>
// constexpr uint32_t mic_size = 512;
// constexpr uint32_t mic_size = 2048;
constexpr uint32_t mic_size = mem::mic0_range / sizeof(uint32_t);

class Sesenta {
public:
  Sesenta(Context &ctx_)
      : ctx(ctx_), ctl(ctx.mm.get<mem::control>()),
        sts(ctx.mm.get<mem::status>()), mic0_br(ctx.mm.get<mem::mic0>()),
        mic1_br(ctx.mm.get<mem::mic1>()), mic2_br(ctx.mm.get<mem::mic2>()),
        mic3_br(ctx.mm.get<mem::mic3>()), mic4_br(ctx.mm.get<mem::mic4>()),
        mic5_br(ctx.mm.get<mem::mic5>()), mic6_br(ctx.mm.get<mem::mic6>()),
        mic7_br(ctx.mm.get<mem::mic7>()), mic8_br(ctx.mm.get<mem::mic8>()),
        mic9_br(ctx.mm.get<mem::mic9>()), mic10_br(ctx.mm.get<mem::mic10>()),
        mic11_br(ctx.mm.get<mem::mic11>()), mic12_br(ctx.mm.get<mem::mic12>()),
        mic13_br(ctx.mm.get<mem::mic13>()), mic14_br(ctx.mm.get<mem::mic14>())
  {
    ctx.print<INFO>("BEAm------------------------------------------>");
    start_beamforming();
  }
  ~Sesenta() {
    beamforming_started = false;
    beamforming_thread.join();
  }
  uint32_t i_rst_clk_mics = 0;
  uint32_t i_rst_leds = 1;
  unsigned int i_dma_gate = 2;

  
  std::array<int16_t, mic_size> get_mic_ith(uint32_t mic_idx) {
    std::array<int16_t, mic_size> mic_data;
    
    // Determine which buffer to read from based on the microphone pair
    std::array<uint32_t, mic_size> raw_data;
    
    // Support all 30 microphone pairs (30 microphones)
    switch (mic_idx) {
    case 0:
    case 1:
        raw_data = mic0_br.read_array<uint32_t, mic_size>();
        break;
    case 2:
    case 3:
        raw_data = mic1_br.read_array<uint32_t, mic_size>();
        break;
    case 4:
    case 5:
        raw_data = mic2_br.read_array<uint32_t, mic_size>();
        break;
    case 6:
    case 7:
        raw_data = mic3_br.read_array<uint32_t, mic_size>();
        break;
    case 8:
    case 9:
        raw_data = mic4_br.read_array<uint32_t, mic_size>();
        break;
    case 10:
    case 11:
        raw_data = mic5_br.read_array<uint32_t, mic_size>();
        break;
    case 12:
    case 13:
        raw_data = mic6_br.read_array<uint32_t, mic_size>();
        break;
    case 14:
    case 15:
        raw_data = mic7_br.read_array<uint32_t, mic_size>();
        break;
    case 16:
    case 17:
        raw_data = mic8_br.read_array<uint32_t, mic_size>();
        break;
    case 18:
    case 19:
        raw_data = mic9_br.read_array<uint32_t, mic_size>();
        break;
    case 20:
    case 21:
        raw_data = mic10_br.read_array<uint32_t, mic_size>();
        break;
    case 22:
    case 23:
        raw_data = mic11_br.read_array<uint32_t, mic_size>();
        break;
    case 24:
    case 25:
        raw_data = mic12_br.read_array<uint32_t, mic_size>();
        break;
    case 26:
    case 27:
        raw_data = mic13_br.read_array<uint32_t, mic_size>();
        break;
    case 28:
    case 29:
        raw_data = mic14_br.read_array<uint32_t, mic_size>();
        break;
    default:
        ctx.print<ERROR>("Invalid microphone index: %d\n", mic_idx);
        return std::array<int16_t, mic_size>{0};
    }

    // Process each 32-bit value to extract the appropriate 16-bit sample
    for (uint32_t i = 0; i < mic_size; i++) {
        uint32_t combined_value = raw_data[i];
        uint16_t mic_lower = combined_value & 0xFFFF;
        uint16_t mic_upper = (combined_value >> 16) & 0xFFFF;
        
        // Convert to signed 16-bit
        if (mic_idx % 2 == 0) {
            // Lower 16 bits for even mic indices (0, 2, 4, ..., 28)
            mic_data[i] = static_cast<int16_t>(mic_lower);
        } else {
            // Upper 16 bits for odd mic indices (1, 3, 5, ..., 29)
            mic_data[i] = static_cast<int16_t>(mic_upper);
        }
    }

    return mic_data;
  }

  void set_mic_sel(uint32_t sel) {
    ctl.write_reg(reg::mic_select, sel);
    ctl.set_bit<reg::start_capture, 0>();
    std::this_thread::sleep_for(std::chrono::microseconds(1));
    ctl.clear_bit<reg::start_capture, 0>();
    auto t_start = std::chrono::high_resolution_clock::now();
    while (!(sts.read_reg(reg::done_capture) & 0x1))
      ;
    auto t_end = std::chrono::high_resolution_clock::now();
    auto elapsed_us =
        std::chrono::duration_cast<std::chrono::microseconds>(t_end - t_start)
            .count();
    std::cout << "Capture wait time: " << elapsed_us << " us\n";
  }

  auto get_mics_bram(uint32_t dir) {
    const int num_mics = 30;  // 30 microphones
    std::vector<int32_t> data_ret = {};
    for (int mic = 0; mic < num_mics; mic++) {
      set_mic_sel(dir);
      auto mic_data = get_mic_ith(mic);
      for (uint32_t sample_idx = 0; sample_idx < mic_size; sample_idx++) {
        uint32_t mic1 = mic_data[sample_idx];
        data_ret.push_back(mic1);
      }
    }
    return data_ret;
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
  Memory<mem::control> &ctl;
  Memory<mem::status> &sts;
  float dma_transfer_duration;
  static constexpr float fs_adc = prm::fclk0;
  float fs;
  Memory<mem::mic0> &mic0_br;
  Memory<mem::mic1> &mic1_br;
  Memory<mem::mic2> &mic2_br;
  Memory<mem::mic3> &mic3_br;
  Memory<mem::mic4> &mic4_br;
  Memory<mem::mic5> &mic5_br;
  Memory<mem::mic6> &mic6_br;
  Memory<mem::mic7> &mic7_br;
  Memory<mem::mic8> &mic8_br;
  Memory<mem::mic9> &mic9_br;
  Memory<mem::mic10> &mic10_br;
  Memory<mem::mic11> &mic11_br;
  Memory<mem::mic12> &mic12_br;
  Memory<mem::mic13> &mic13_br;
  Memory<mem::mic14> &mic14_br;

  std::atomic<bool> beamforming_started{false};
  std::thread beamforming_thread;

  // Mapping for 30 microphones (M0-M29)
  // Corresponding to 30 beamforming directions
  static constexpr std::array<uint8_t, 30> M_DATA_TO_MIC = {
      60, 58, 56, 54, 52, 50, 48, 46, 44, 42,
      40, 38, 36, 34, 32, 30, 28, 26, 24, 22,
      20, 18, 16, 14, 12, 10, 8, 6, 4, 2
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
  const int num_mics = 30;  // 30 microphones
  const int num_directions = 30;  // 30 beamforming directions

  beamforming_started = true;
  ctx.print<INFO>("Beamforming thread started for 30 microphones (M0-M29).\n");

  const double pcm_sample_rate = 48000.0; // 48 kHz
  const double buffer_fill_time_ms = (1 / pcm_sample_rate) * 1000.0;

  ctx.print<INFO>("BRAM buffer size: %u samples\n", mic_size);
  ctx.print<INFO>("Required wait time per direction: %.2f ms\n",
                  buffer_fill_time_ms);

  while (beamforming_started) {
    std::array<double, num_directions> beam_powers = {0.0};

    for (int dir = 0; dir < num_directions; dir++) {
      set_mic_sel(dir);
      std::array<double, mic_size> beamformed_signal = {0.0};

      for (int mic = 0; mic < num_mics; mic++) {
        auto mic_data = get_mic_ith(mic);

        for (uint32_t sample_idx = 0; sample_idx < mic_size; sample_idx++) {
          beamformed_signal[sample_idx] +=
              static_cast<double>(mic_data[sample_idx]);
        }
      }

      double power = 0.0;
      for (uint32_t sample_idx = 0; sample_idx < mic_size; sample_idx++) {
        power += (beamformed_signal[sample_idx] * beamformed_signal[sample_idx]);
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
        "Maximum sound energy detected from direction: %d (M%d) (Power: %e)\n",
        max_direction, M_DATA_TO_MIC[max_direction], max_power);

    set_led_sel(M_DATA_TO_MIC[max_direction]);
  }
}

#endif // __SESENTA_HPP__
