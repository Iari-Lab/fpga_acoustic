/// (c) Koheron

#ifndef __DRIVERS_SESENTA_HPP__
#define __DRIVERS_SESENTA_HPP__

#include <algorithm>
#include <array>
#include <chrono>
#include <cmath>
#include <context.hpp>
#include <iostream>


#include "config_geom.hpp"
#include "opencv2/core/cvdef.h"
#include <deque>
#include <opencv2/core.hpp>
#include <opencv2/video/tracking.hpp>
#include <stdio.h>


constexpr uint32_t mic_size = mem::mic0_range / sizeof(uint32_t);
// Sound Activity Detection parameters
constexpr double POWER_THRESHOLD =
    1.2e9; 
constexpr double MIN_VALID_POWER = 2.09e9; // Minimum power for valid measurement
constexpr int SAD_HISTORY_SIZE = 35;     // Frames for activity decision
constexpr double VELOCITY_THRESHOLD = 0.1; // Maximum reasonable velocity (m/s)
class Sesenta {
public:
//=== TUNING PARAMETERS - Adjust these for your environment ===

  // Silence detection: Set based on measured noise floor
  // Measure power when no sound is present, then set ~3-5x above that
  static constexpr float SILENCE_THRESHOLD = 1e8f;

  // Number of consecutive silent frames before turning off LED
  static constexpr uint32_t SILENCE_FRAMES_REQUIRED = 3;

  // Hysteresis ratio: turn-off threshold = SILENCE_THRESHOLD * POWER_HYSTERESIS
  static constexpr float POWER_HYSTERESIS = 0.8f;

  // Maximum reasonable direction change per frame (in direction units 0-29)
  static constexpr float MAX_VELOCITY = 15.0f;

  // Power must exceed threshold * this factor to activate LED
  static constexpr float ACTIVATION_FACTOR = 1.5f;
  Sesenta(Context &ctx_)
      : ctx(ctx_), ctl(ctx.mm.get<mem::control>()),
        sts(ctx.mm.get<mem::status>()), mic0_br(ctx.mm.get<mem::mic0>()),
        mic1_br(ctx.mm.get<mem::mic1>()), mic2_br(ctx.mm.get<mem::mic2>()),
        mic3_br(ctx.mm.get<mem::mic3>()), mic4_br(ctx.mm.get<mem::mic4>()),
        mic5_br(ctx.mm.get<mem::mic5>()), mic6_br(ctx.mm.get<mem::mic6>()),
        mic7_br(ctx.mm.get<mem::mic7>()) , kf(2, 1, 0, CV_32F) {
    ctx.print<INFO>("BEAm------------------------------------------>\n");

    initialize_kalman_filter();
    initializeSoundDetection();
  }
  ~Sesenta() {
    beamforming_started = false;
    beamforming_thread.join();
  }
void initialize_kalman_filter() {
    // State: [position, velocity]
    // Transition: position(t+1) = position(t) + velocity(t)
    //             velocity(t+1) = velocity(t)
    kf.transitionMatrix = (cv::Mat_<float>(2, 2) << 1, 1, 0, 1);

    // Measurement: we only observe position (direction)
    kf.measurementMatrix = (cv::Mat_<float>(1, 2) << 1, 0);

    // Process noise - how much state can change unexpectedly
    // Lower = smoother tracking, Higher = more responsive
    cv::setIdentity(kf.processNoiseCov, cv::Scalar::all(0.5f));

    // Measurement noise - how noisy are direction readings
    // Higher = more smoothing, trust predictions more
    cv::setIdentity(kf.measurementNoiseCov, cv::Scalar::all(15.0f));

    // Initial error covariance
    cv::setIdentity(kf.errorCovPost, cv::Scalar::all(1.0f));

    // Initial state: direction 15 (center), velocity 0
    kf.statePost.at<float>(0) = 15.0f;
    kf.statePost.at<float>(1) = 0.0f;
  }
  void initializeSoundDetection() {
    power_history.clear();
    sound_detected = false;
    consecutive_invalid_frames = 0;
  }
// Sound Activity Detection based on power thresholding
  bool detectSoundActivity(double power) {
    // Add to history
    power_history.push_back(power);
    if (power_history.size() > SAD_HISTORY_SIZE) {
      power_history.pop_front();
    }

    // Calculate average power over history
    double avg_power = 0.0;
    for (double p : power_history) {
      avg_power += p;
    }
    avg_power /= power_history.size();
    // print avg power
    // ctx.print<DEBUG>("Avg Power: %f, Current Power: %f\n", avg_power, power);
    ctx.print<DEBUG>("Avg Power: %e\n", avg_power, power);

    // // Decision logic
    bool current_detection =
        (avg_power > POWER_THRESHOLD) && (power > MIN_VALID_POWER);

    // Hysteresis to avoid rapid switching
    if (current_detection) {
      consecutive_invalid_frames = 0;
      sound_detected = true;
    } else {
      consecutive_invalid_frames++;
      if (consecutive_invalid_frames > SAD_HISTORY_SIZE) {
        sound_detected = false;
      }
    }
    return sound_detected;
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
    default:
      return std::array<int32_t, mic_size>{0};
    }
    return mic_data;
  }
  void start_bf() { start_beamforming(); }

  void record() {
    ctl.set_bit<reg::start_capture, 0>();
    std::this_thread::sleep_for(std::chrono::microseconds(1));
    ctl.clear_bit<reg::start_capture, 0>();
    while (!(sts.read_reg(reg::done_capture) & 0x1))
      ;
  }

  auto get_mics_bram(uint32_t dir) {
    const int num_mics = 8;
    std::vector<int32_t> data_ret = {};
    for (int mic = 0; mic < num_mics; mic++) {
      auto mic_data = get_mic_ith(mic);
      for (uint32_t sample_idx = 0; sample_idx < mic_size; sample_idx++) {
        data_ret.push_back(mic_data[sample_idx]);
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
      power += (sample * sample);
    }
    ctx.print<DEBUG>("Direction MIC %d: LED = %d   power: %f\n", dir,
                     M_DATA_TO_MIC[dir], power);
    set_led_sel(M_DATA_TO_MIC[dir],1);
  }

  void bf() {
    const int num_directions = 8;
    std::array<double, num_directions> beam_powers = {0.0};
    record();
    int max_direction = 0;
    double max_power = 0.0;
    double total_power = 0.0;
    for (int dir = 0; dir < num_directions; dir++) {
      beam_powers = {0.0};
      auto beamformed_sum = get_mic_ith(dir);
      double power = 0.0;
      for (uint32_t sample_idx = 0; sample_idx < mic_size; sample_idx++) {
        double sample = (double)beamformed_sum[sample_idx];
        power += (sample * sample);
      }
      total_power += power;
      beam_powers[dir] = power / mic_size;
      if (beam_powers[dir] > max_power) {
        max_power = beam_powers[dir];
        max_direction = dir;
      }
    }

    bool sound_active = detectSoundActivity(total_power);
    if (sound_active) {
      ctx.print<DEBUG>("Sound detected (Power: %e), maintaining position\n",
                       max_power);
      ctx.print<INFO>("Maximum sound energy detected from direction: %d (M%d) "
                    "(Power: %e)\n",
                    max_direction, M_DATA_TO_MIC[max_direction], max_power);
      set_led_sel(M_DATA_TO_MIC[max_direction],1);

    } else {
      // No sound detected - stop predicting and maintain last position
      ctx.print<DEBUG>("No sound detected (Power: %e), maintaining position\n",
                       max_power);
    }
      // detectSoundActivity(max_power);
    // ctx.print<INFO>(
    //     "Maximum sound energy detected from direction: %d (M%d) (Power: %e)\n",
    //     max_direction, M_DATA_TO_MIC[max_direction], max_power);
    // set_led_sel(M_DATA_TO_MIC[max_direction],1);
  }
  void set_led_sel(uint32_t sel, uint32_t color) {
    uint32_t sel_val = (sel << 1) + color;
    ctl.write_reg(reg::led_select, sel_val);
  }
  uint32_t get_mic_size() { return mic_size; }
  void start_beamforming();

private:
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
  std::atomic<bool> beamforming_started{false};
  std::thread beamforming_thread;
  cv::KalmanFilter kf;

  // Sound activity detection
  bool sound_detected;
  int32_t last_valid_direction;
  int32_t consecutive_invalid_frames;
  std::deque<double> power_history;

  // Silence detection state
  uint32_t silence_frame_count_ = 0;
  bool sound_active_ = false;
  uint32_t last_active_led_ = 0;
  // static constexpr std::array<uint8_t, 8> M_DATA_TO_MIC = {59, 3, 7, 11,
  //                                                          15, 19, 55, 58};
  static constexpr std::array<uint8_t, 8> M_DATA_TO_MIC = {59, 58, 55, 19,15,11,7,3};
  void beamf_thread();
};

inline void Sesenta::start_beamforming() {
  ctx.print<INFO>(" enter thread\n");
  if (!beamforming_started) {
    beamforming_thread = std::thread{&Sesenta::beamf_thread, this};
    beamforming_thread.detach();
  }
}

inline void Sesenta::beamf_thread() {
  beamforming_started = true;
  ctx.print<INFO>("Beamforming thread started for 8 directions.\n");
  ctx.print<INFO>("BRAM buffer size: %u samples\n", mic_size);
  while (beamforming_started) {
    bf();
  }
}
#endif // __SESENTA_HPP__
