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
        mic13_br(ctx.mm.get<mem::mic13>()), mic14_br(ctx.mm.get<mem::mic14>()),
        mic15_br(ctx.mm.get<mem::mic15>()), mic16_br(ctx.mm.get<mem::mic16>()),
        mic17_br(ctx.mm.get<mem::mic17>()), mic18_br(ctx.mm.get<mem::mic18>()),
        mic19_br(ctx.mm.get<mem::mic19>()), mic20_br(ctx.mm.get<mem::mic20>())
        {
    ctx.print<INFO>("BEAm------------------------------------------>");
    // start_beamforming();
  }
  ~Sesenta() {
    beamforming_started = false;
    beamforming_thread.join();
  }
  uint32_t i_rst_clk_mics = 0;
  uint32_t i_rst_leds = 1;
  unsigned int i_dma_gate = 2;

  std::array<int32_t, mic_size> get_mic_ith(uint32_t mic_idx) {
    std::array<int32_t, mic_size> mic_data;

    switch (mic_idx) {
    case 0:
      mic_data = mic0_br.read_array<int32_t, mic_size>();
      break;
    case 1:
      mic_data = mic1_br.read_array<int32_t, mic_size>();
      break;
    case 2:
      mic_data = mic2_br.read_array<int32_t, mic_size>();
      break;
    case 3:
      mic_data = mic3_br.read_array<int32_t, mic_size>();
      break;
    case 4:
      mic_data = mic4_br.read_array<int32_t, mic_size>();
      break;
    case 5:
      mic_data = mic5_br.read_array<int32_t, mic_size>();
      break;
    case 6:
      mic_data = mic6_br.read_array<int32_t, mic_size>();
      break;
    case 7:
      mic_data = mic7_br.read_array<int32_t, mic_size>();
      break;
    case 8:
      mic_data = mic8_br.read_array<int32_t, mic_size>();
      break;
    case 9:
      mic_data = mic9_br.read_array<int32_t, mic_size>();
      break;
    case 10:
      mic_data = mic10_br.read_array<int32_t, mic_size>();
      break;
    case 11:
      mic_data = mic11_br.read_array<int32_t, mic_size>();
      break;
    case 12:
      mic_data = mic12_br.read_array<int32_t, mic_size>();
      break;
    case 13:
      mic_data = mic13_br.read_array<int32_t, mic_size>();
      break;
    case 14:
      mic_data = mic14_br.read_array<int32_t, mic_size>();
      break;
    case 15:
      mic_data = mic15_br.read_array<int32_t, mic_size>();
      break;
    case 16: 
      mic_data = mic16_br.read_array<int32_t, mic_size>();
    break;
    case 17:
      mic_data = mic17_br.read_array<int32_t, mic_size>();
      break;
    case 18:
      mic_data = mic18_br.read_array<int32_t, mic_size>();
      break;
    case 19:
      mic_data = mic19_br.read_array<int32_t, mic_size>();
      break;
    case 20:
      mic_data = mic20_br.read_array<int32_t, mic_size>();
      break;
    default:
      // ctx.print<ERROR>("Invalid microphone index: %d\n", mic_idx);
      return std::array<int32_t, mic_size>{0};
    }

    return mic_data;
  }

  void record() {
    ctl.set_bit<reg::start_capture, 0>();
    std::this_thread::sleep_for(std::chrono::microseconds(1));
    ctl.clear_bit<reg::start_capture, 0>();
    // auto t_start = std::chrono::high_resolution_clock::now();
    while (!(sts.read_reg(reg::done_capture) & 0x1))
      ;
    // auto t_end = std::chrono::high_resolution_clock::now();
    // auto elapsed_us =
    //     std::chrono::duration_cast<std::chrono::microseconds>(t_end -
    //     t_start)
    //         .count();
    // std::cout << "Capture wait time: " << elapsed_us << " us\n";
  }
  void set_mic_sel(uint32_t sel) {
    ctl.write_reg(reg::mic_select, sel);
    ctl.set_bit<reg::start_capture, 0>();
    std::this_thread::sleep_for(std::chrono::microseconds(1));
    ctl.clear_bit<reg::start_capture, 0>();
    // auto t_start = std::chrono::high_resolution_clock::now();
    while (!(sts.read_reg(reg::done_capture) & 0x1))
      ;
    // auto t_end = std::chrono::high_resolution_clock::now();
    // auto elapsed_us =
    //     std::chrono::duration_cast<std::chrono::microseconds>(t_end -
    //     t_start)
    //         .count();
    // std::cout << "Capture wait time: " << elapsed_us << " us\n";
  }

  auto get_mics_bram(uint32_t dir) {
    const int num_mics = 30; // 30 microphones
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
  void beamf(uint32_t dir) {
    record();
    auto beamformed_sum = get_mic_ith(dir);
    double power = 0.0;
    for (uint32_t sample_idx = 0; sample_idx < mic_size; sample_idx++) {
      double sample = (double)beamformed_sum[sample_idx];
      // double sample = static_cast<double>(beamformed_sum[sample_idx]);
      power += (sample * sample);
    }
    ctx.print<DEBUG>("Direction MIC %d: LED = %d   power: %f\n", dir,
                     M_DATA_TO_MIC[dir], power);
    set_led_sel(M_DATA_TO_MIC[dir]);
  }

  void bf() {

    const int num_directions = 21;

    std::array<double, num_directions> beam_powers = {0.0};
    // while (1) {

      beam_powers = {0.0};

      record();
      for (int dir = 0; dir < num_directions; dir++) {
        auto beamformed_sum = get_mic_ith(dir);

        double power = 0.0;
        for (uint32_t sample_idx = 0; sample_idx < mic_size; sample_idx++) {
          double sample = (double)beamformed_sum[sample_idx];
          // double sample = static_cast<double>(beamformed_sum[sample_idx]);
          power += (sample * sample);
        }

        beam_powers[dir] = power / mic_size;
        ctx.print<DEBUG>("Direction MIC %d: power: %f \n", dir,
                         beam_powers[dir]);

        // ctx.print<DEBUG>("Direction MIC %d: LED = %d   power: %f  samples
        // %d\n", dir,
        //  M_DATA_TO_MIC[dir], beam_powers[dir], mic_size);
      }

      int max_direction = 0;
      double max_power = 0.0;
      for (int dir = 0; dir < num_directions; dir++) {
        if (beam_powers[dir] > max_power) {
          max_power = beam_powers[dir];
          max_direction = dir;
        }
      }

      ctx.print<INFO>("Maximum sound energy detected from direction: %d (M%d) "
                      "(Power: %e)\n",
                      max_direction, M_DATA_TO_MIC[max_direction], max_power);

      // set_led_sel(M_DATA_TO_MIC[max_direction]);
    // }
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
  Memory<mem::mic15> &mic15_br;
  Memory<mem::mic16> &mic16_br;
  Memory<mem::mic17> &mic17_br;
  Memory<mem::mic18> &mic18_br;
  Memory<mem::mic19> &mic19_br;
  Memory<mem::mic20> &mic20_br;

  std::atomic<bool> beamforming_started{false};
  std::thread beamforming_thread;

  // Mapping for 30 microphones (M0-M29)
  // Corresponding to 30 beamforming directions
  static constexpr std::array<uint8_t, 30> M_DATA_TO_MIC = {
      60, 58, 56, 54, 52, 50, 48, 46, 44, 42, 40, 38, 36, 34, 32,
      30, 28, 26, 24, 22, 20, 18, 16, 14, 12, 10, 8,  6,  4,  2};

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
  const int num_directions = 30;

  beamforming_started = true;
  ctx.print<INFO>("Beamforming thread started for 30 directions.\n");

  ctx.print<INFO>("BRAM buffer size: %u samples\n", mic_size);

  while (beamforming_started) {
    std::array<double, num_directions> beam_powers = {0.0};

    record();
    for (int dir = 0; dir < num_directions; dir++) {

      if (dir == 16 || dir == 27 || dir == 28) {
        // skip defective microphones
        continue;
      }
      auto beamformed_sum = get_mic_ith(dir);

      double power = 0.0;
      for (uint32_t sample_idx = 0; sample_idx < mic_size; sample_idx++) {
        double sample = static_cast<double>(beamformed_sum[sample_idx]);
        power += (sample * sample);
      }

      beam_powers[dir] = power / mic_size;
      // ctx.print<DEBUG>("Direction MIC %d: LED = %d   power: %f\n", dir,
      //  M_DATA_TO_MIC[dir], power);
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
