/// Enhanced Sesenta with Silence Detection and Improved Kalman Filter
/// Based on original sesenta.hpp with false positive reduction

#ifndef __DRIVERS_SESENTA_IMPROVED_HPP__
#define __DRIVERS_SESENTA_IMPROVED_HPP__

#include "config_geom.hpp"
#include "opencv2/core/cvdef.h"
#include <algorithm>
#include <array>
#include <chrono>
#include <cmath>
#include <context.hpp>
#include <deque>
#include <iostream>
#include <opencv2/core.hpp>
#include <opencv2/video/tracking.hpp>
#include <stdio.h>

using namespace cv;

constexpr uint32_t mic_size = mem::mic0_range / sizeof(uint32_t);

// Sound Activity Detection parameters
constexpr double POWER_THRESHOLD =
    1e6; // Adjust based on your microphone sensitivity
constexpr double MIN_VALID_POWER = 1e4; // Minimum power for valid measurement
constexpr int SAD_HISTORY_SIZE = 5;     // Frames for activity decision
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
        mic7_br(ctx.mm.get<mem::mic7>()), mic8_br(ctx.mm.get<mem::mic8>()),
        mic9_br(ctx.mm.get<mem::mic9>()), mic10_br(ctx.mm.get<mem::mic10>()),
        mic11_br(ctx.mm.get<mem::mic11>()), mic12_br(ctx.mm.get<mem::mic12>()),
        mic13_br(ctx.mm.get<mem::mic13>()), mic14_br(ctx.mm.get<mem::mic14>()),
        mic15_br(ctx.mm.get<mem::mic15>()), mic16_br(ctx.mm.get<mem::mic16>()),
        mic17_br(ctx.mm.get<mem::mic17>()), mic18_br(ctx.mm.get<mem::mic18>()),
        mic19_br(ctx.mm.get<mem::mic19>()), mic20_br(ctx.mm.get<mem::mic20>()),
        mic21_br(ctx.mm.get<mem::mic21>()), mic22_br(ctx.mm.get<mem::mic22>()),
        mic23_br(ctx.mm.get<mem::mic23>()), mic24_br(ctx.mm.get<mem::mic24>()),
        mic25_br(ctx.mm.get<mem::mic25>()), mic26_br(ctx.mm.get<mem::mic26>()),
        mic27_br(ctx.mm.get<mem::mic27>()), mic28_br(ctx.mm.get<mem::mic28>()),
        mic29_br(ctx.mm.get<mem::mic29>()), mic30_br(ctx.mm.get<mem::mic30>()),
        mic31_br(ctx.mm.get<mem::mic31>()), mic32_br(ctx.mm.get<mem::mic32>()),
        mic33_br(ctx.mm.get<mem::mic33>()), mic34_br(ctx.mm.get<mem::mic34>()),
        mic35_br(ctx.mm.get<mem::mic35>()), mic36_br(ctx.mm.get<mem::mic36>()),
        mic37_br(ctx.mm.get<mem::mic37>()), mic38_br(ctx.mm.get<mem::mic38>()),
        mic39_br(ctx.mm.get<mem::mic39>()), mic40_br(ctx.mm.get<mem::mic40>()),
        mic41_br(ctx.mm.get<mem::mic41>()), mic42_br(ctx.mm.get<mem::mic42>()),
        mic43_br(ctx.mm.get<mem::mic43>()), mic44_br(ctx.mm.get<mem::mic44>()),
        mic45_br(ctx.mm.get<mem::mic45>()), mic46_br(ctx.mm.get<mem::mic46>()),
        mic47_br(ctx.mm.get<mem::mic47>()), mic48_br(ctx.mm.get<mem::mic48>()),
        mic49_br(ctx.mm.get<mem::mic49>()), mic50_br(ctx.mm.get<mem::mic50>()),
        mic51_br(ctx.mm.get<mem::mic51>()), mic52_br(ctx.mm.get<mem::mic52>()),
        mic53_br(ctx.mm.get<mem::mic53>()), mic54_br(ctx.mm.get<mem::mic54>()),
        mic55_br(ctx.mm.get<mem::mic55>()), mic56_br(ctx.mm.get<mem::mic56>()),
        mic57_br(ctx.mm.get<mem::mic57>()), mic58_br(ctx.mm.get<mem::mic58>()),
        mic59_br(ctx.mm.get<mem::mic59>()), kf(2, 1, 0, CV_32F) {

    ctx.print<INFO>("BEAM Improved with Silence Detection -->");
    initialize_kalman_filter();
    initializeSoundDetection();
  }

  ~Sesenta() {
    beamforming_started = false;
    if (beamforming_thread.joinable()) {
      beamforming_thread.join();
    }
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

  // Reset Kalman filter to initial state (call when sound resumes after
  // silence)
  void reset_kalman_filter(int32_t initial_direction) {
    cv::setIdentity(kf.errorCovPost, cv::Scalar::all(1.0f));
    kf.statePost.at<float>(0) = static_cast<float>(initial_direction);
    kf.statePost.at<float>(1) = 0.0f;
  }
  void initializeSoundDetection() {
    power_history.clear();
    sound_detected = false;
    consecutive_invalid_frames = 0;
  }

  // Convert direction index to 2D position
  // cv::Mat directionToPosition(int32_t direction, double power) {
  //   cv::Mat position = cv::Mat::zeros(2, 1, CV_32F);

  //   if (direction >= 0 && direction < 60) {
  //     // Map direction to microphone position
  //     float x = mic_positions[direction].x;
  //     float y = mic_positions[direction].y;

  //     // Adjust confidence based on power
  //     float confidence = std::min(1.0f, (float)(power / POWER_THRESHOLD));

  //     position.at<float>(0) = x * confidence;
  //     position.at<float>(1) = y * confidence;
  //   }

  //   return position;
  // }
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

    // Decision logic
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
    case 21:
      mic_data = mic21_br.read_array<int32_t, mic_size>();
      break;
    case 22:
      mic_data = mic22_br.read_array<int32_t, mic_size>();
      break;
    case 23:
      mic_data = mic23_br.read_array<int32_t, mic_size>();
      break;
    case 24:
      mic_data = mic24_br.read_array<int32_t, mic_size>();
      break;
    case 25:
      mic_data = mic25_br.read_array<int32_t, mic_size>();
      break;
    case 26:
      mic_data = mic26_br.read_array<int32_t, mic_size>();
      break;
    case 27:
      mic_data = mic27_br.read_array<int32_t, mic_size>();
      break;
    case 28:
      mic_data = mic28_br.read_array<int32_t, mic_size>();
      break;
    case 29:
      mic_data = mic28_br.read_array<int32_t, mic_size>();
      break;
    case 30:
      mic_data = mic30_br.read_array<int32_t, mic_size>();
      break;
    case 31:
      mic_data = mic31_br.read_array<int32_t, mic_size>();
      break;
    case 32:
      mic_data = mic32_br.read_array<int32_t, mic_size>();
      break;
    case 33:
      mic_data = mic33_br.read_array<int32_t, mic_size>();
      break;
    case 34:
      mic_data = mic34_br.read_array<int32_t, mic_size>();
      break;
    case 35:
      mic_data = mic35_br.read_array<int32_t, mic_size>();
      break;
    case 36:
      mic_data = mic36_br.read_array<int32_t, mic_size>();
      break;
    case 37:
      mic_data = mic37_br.read_array<int32_t, mic_size>();
      break;
    case 38:
      mic_data = mic38_br.read_array<int32_t, mic_size>();
      break;
    case 39:
      mic_data = mic39_br.read_array<int32_t, mic_size>();
      break;
    case 40:
      mic_data = mic40_br.read_array<int32_t, mic_size>();
      break;
    case 41:
      mic_data = mic41_br.read_array<int32_t, mic_size>();
      break;
    case 42:
      mic_data = mic42_br.read_array<int32_t, mic_size>();
      break;
    case 43:
      mic_data = mic43_br.read_array<int32_t, mic_size>();
      break;
    case 44:
      mic_data = mic44_br.read_array<int32_t, mic_size>();
      break;
    case 45:
      mic_data = mic45_br.read_array<int32_t, mic_size>();
      break;
    case 46:
      mic_data = mic46_br.read_array<int32_t, mic_size>();
      break;
    case 47:
      mic_data = mic47_br.read_array<int32_t, mic_size>();
      break;
    case 48:
      mic_data = mic48_br.read_array<int32_t, mic_size>();
      break;
    case 49:
      mic_data = mic49_br.read_array<int32_t, mic_size>();
      break;
    case 50:
      mic_data = mic50_br.read_array<int32_t, mic_size>();
      break;
    case 51:
      mic_data = mic51_br.read_array<int32_t, mic_size>();
      break;
    case 52:
      mic_data = mic52_br.read_array<int32_t, mic_size>();
      break;
    case 53:
      mic_data = mic53_br.read_array<int32_t, mic_size>();
      break;
    case 54:
      mic_data = mic54_br.read_array<int32_t, mic_size>();
      break;
    case 55:
      mic_data = mic55_br.read_array<int32_t, mic_size>();
      break;
    case 56:
      mic_data = mic56_br.read_array<int32_t, mic_size>();
      break;
    case 57:
      mic_data = mic57_br.read_array<int32_t, mic_size>();
      break;
    case 58:
      mic_data = mic58_br.read_array<int32_t, mic_size>();
      break;
    case 59:
      mic_data = mic59_br.read_array<int32_t, mic_size>();
      break;
    default:
      // ctx.print<ERROR>("Invalid microphone index: %d\n", mic_idx);
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

  auto get_mics_bram() {
    const int num_mics = 29; // 29 microphones
    std::vector<int32_t> data_ret = {};
    for (int mic = 0; mic < num_mics; mic++) {
      // set_mic_sel(dir);
      auto mic_data = get_mic_ith(mic);
      for (uint32_t sample_idx = 0; sample_idx < mic_size; sample_idx++) {
        uint32_t mic1 = mic_data[sample_idx];
        data_ret.push_back(mic1);
      }
    }
    return data_ret;
  }

  // void beamf(uint32_t dir) {
  //   record();
  //   auto beamformed_sum = get_mic_ith(dir);
  //   double power = 0.0;
  //   for (uint32_t sample_idx = 0; sample_idx < mic_size; sample_idx++) {
  //     double sample = static_cast<double>(beamformed_sum[sample_idx]);
  //     power += (sample * sample);
  //   }
  //   ctx.print<DEBUG>("Direction MIC %d: LED = %d   power: %f\n", dir,
  //                    M_DATA_TO_MIC[dir], power);
  //   set_led_sel(M_DATA_TO_MIC[dir]);
  // }

  // /// Main beamforming function with silence detection and Kalman filtering
  // void bf_kalman() {
  //   const int32_t num_directions = 30;
  //   record();

  //   // Step 1: Compute beam powers for all directions
  //   int32_t max_direction = 0;
  //   double max_power = 0.0;

  //   for (int32_t dir = 0; dir < num_directions; dir++) {
  //     auto beamformed_sum = get_mic_ith(dir);
  //     double power = 0.0;
  //     for (uint32_t sample_idx = 0; sample_idx < mic_size; sample_idx++) {
  //       double sample = static_cast<double>(beamformed_sum[sample_idx]);
  //       power += (sample * sample);
  //     }
  //     double normalized_power = power / mic_size;

  //     if (normalized_power > max_power) {
  //       max_power = normalized_power;
  //       max_direction = dir;
  //     }
  //   }

  //   // Step 2: Silence detection with hysteresis
  //   float threshold = sound_active_ ? SILENCE_THRESHOLD * POWER_HYSTERESIS
  //                                   : SILENCE_THRESHOLD;

  //   if (max_power < threshold) {
  //     silence_frame_count_++;

  //     if (silence_frame_count_ >= SILENCE_FRAMES_REQUIRED) {
  //       // Confirmed silence - stop predicting
  //       sound_active_ = false;
  //       silence_frame_count_ = SILENCE_FRAMES_REQUIRED; // Cap counter

  //       ctx.print<DEBUG>("Silence detected (power: %.2e < %.2e)\n",
  //       max_power,
  //                        threshold);

  //       // Turn off LED during silence
  //       // turn_off_leds();
  //       return;
  //     }

  //     // Still accumulating silence frames - don't update
  //     ctx.print<DEBUG>("Silence accumulating: %d/%d frames\n",
  //                      silence_frame_count_, SILENCE_FRAMES_REQUIRED);
  //     return;
  //   } else {
  //     // Sound detected
  //     if (!sound_active_) {
  //       // Transitioning from silence to sound - reset Kalman
  //       reset_kalman_filter(max_direction);
  //       ctx.print<INFO>("Sound resumed at direction %d\n", max_direction);
  //     }
  //     silence_frame_count_ = 0;
  //     sound_active_ = true;
  //   }

  //   // Step 3: Kalman filter prediction
  //   cv::Mat prediction = kf.predict();
  //   float predicted_position = prediction.at<float>(0);
  //   float predicted_velocity = prediction.at<float>(1);

  //   // Step 4: Validate measurement - reject spurious jumps
  //   float direction_diff = std::abs(max_direction - predicted_position);
  //   // Handle wrap-around (direction 0 and 29 are adjacent)
  //   direction_diff = std::min(direction_diff, 30.0f - direction_diff);

  //   bool measurement_valid = true;

  //   // If velocity is low but direction jumped significantly, it's likely
  //   noise if (std::abs(predicted_velocity) < 2.0f && direction_diff > 10.0f)
  //   {
  //     measurement_valid = false;
  //     ctx.print<DEBUG>("Spurious jump rejected: diff=%.1f, vel=%.2f\n",
  //                      direction_diff, predicted_velocity);
  //   }

  //   // Step 5: Kalman correction (or use prediction only)
  //   cv::Mat corrected;

  //   if (measurement_valid) {
  //     // Adaptive measurement noise based on power level
  //     float power_ratio = static_cast<float>(max_power / SILENCE_THRESHOLD);
  //     float adaptive_noise = 15.0f / std::max(1.0f, power_ratio);
  //     cv::setIdentity(kf.measurementNoiseCov,
  //     cv::Scalar::all(adaptive_noise));

  //     cv::Mat measurement =
  //         (cv::Mat_<float>(1, 1) << static_cast<float>(max_direction));
  //     corrected = kf.correct(measurement);
  //   } else {
  //     // Use prediction only - reject bad measurement
  //     corrected = prediction;
  //   }

  //   // Step 6: Extract filtered state
  //   float filtered_position = corrected.at<float>(0);
  //   float filtered_velocity = corrected.at<float>(1);

  //   int32_t filtered_direction =
  //       static_cast<int>(std::round(filtered_position));
  //   filtered_direction = std::max(0, std::min(29, filtered_direction));

  //   // Step 7: Final validation before LED activation
  //   bool activate_led = true;

  //   // Velocity sanity check
  //   if (std::abs(filtered_velocity) > MAX_VELOCITY) {
  //     activate_led = false;
  //     ctx.print<DEBUG>("Velocity too high: %.2f\n", filtered_velocity);
  //   }

  //   // Power must be significantly above threshold
  //   if (max_power < SILENCE_THRESHOLD * ACTIVATION_FACTOR) {
  //     activate_led = false;
  //     ctx.print<DEBUG>("Power below activation: %.2e\n", max_power);
  //   }

  //   // Step 8: Control LED
  //   if (activate_led) {
  //     set_led_sel(M_DATA_TO_MIC[filtered_direction]);
  //     last_active_led_ = M_DATA_TO_MIC[filtered_direction];

  //     ctx.print<INFO>("Raw: %d, Filtered: %d, Vel: %.2f, Power: %.2e\n",
  //                     max_direction, filtered_direction, filtered_velocity,
  //                     max_power);
  //   } else {
  //     // turn_off_leds();
  //   }
  // }

  void bf() {
    const int num_directions = 60;
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
      set_led_sel(M_DATA_TO_MIC[max_direction]);

    } else {
      // No sound detected - stop predicting and maintain last position
      ctx.print<DEBUG>("No sound detected (Power: %e), maintaining position\n",
                       max_power);
    }
   
    //  // Kalman filter: predict then correct
    //   cv::Mat prediction = kf.predict();

    //   // Create measurement matrix with detected direction
    //   cv::Mat measurement = (cv::Mat_<float>(1, 1) << (float)max_direction);

    //   // Correct with measurement
    //   cv::Mat corrected = kf.correct(measurement);

    //   // Get filtered direction (round to nearest integer)
    //   int filtered_direction = (int)std::round(corrected.at<float>(0));

    //   // Clamp to valid range
    //   filtered_direction = std::max(0, std::min(29, filtered_direction));

    //   ctx.print<INFO>("Raw: %d, Filtered: %d (Power: %e)\n",
    //                   max_direction, filtered_direction, max_power);

    //   // Use filtered direction for LED
    //   set_led_sel(M_DATA_TO_MIC[filtered_direction]);
  }
  void set_led_sel(uint32_t sel) { ctl.write_reg(reg::led_select, sel); }

  // void turn_off_leds() {
  //   // Option 1: Set to invalid/off value
  //   ctl.write_reg(reg::led_select, 0xFF);  // Or whatever value turns off
  //   LEDs

  //   // Option 2: If you have a separate LED enable register
  //   // ctl.clear_bit<reg::led_enable, 0>();
  // }

  uint32_t get_mic_size() { return mic_size; }
  void start_beamforming();

  // Getters for debugging
  bool is_sound_active() const { return sound_active_; }
  uint32_t get_silence_frames() const { return silence_frame_count_; }

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
  Memory<mem::mic21> &mic21_br;
  Memory<mem::mic22> &mic22_br;
  Memory<mem::mic23> &mic23_br;
  Memory<mem::mic24> &mic24_br;
  Memory<mem::mic25> &mic25_br;
  Memory<mem::mic26> &mic26_br;
  Memory<mem::mic27> &mic27_br;
  Memory<mem::mic28> &mic28_br;
  Memory<mem::mic29> &mic29_br;
  Memory<mem::mic30> &mic30_br;
  Memory<mem::mic31> &mic31_br;
  Memory<mem::mic32> &mic32_br;
  Memory<mem::mic33> &mic33_br;
  Memory<mem::mic34> &mic34_br;
  Memory<mem::mic35> &mic35_br;
  Memory<mem::mic36> &mic36_br;
  Memory<mem::mic37> &mic37_br;
  Memory<mem::mic38> &mic38_br;
  Memory<mem::mic39> &mic39_br;
  Memory<mem::mic40> &mic40_br;
  Memory<mem::mic41> &mic41_br;
  Memory<mem::mic42> &mic42_br;
  Memory<mem::mic43> &mic43_br;
  Memory<mem::mic44> &mic44_br;
  Memory<mem::mic45> &mic45_br;
  Memory<mem::mic46> &mic46_br;
  Memory<mem::mic47> &mic47_br;
  Memory<mem::mic48> &mic48_br;
  Memory<mem::mic49> &mic49_br;
  Memory<mem::mic50> &mic50_br;
  Memory<mem::mic51> &mic51_br;
  Memory<mem::mic52> &mic52_br;
  Memory<mem::mic53> &mic53_br;
  Memory<mem::mic54> &mic54_br;
  Memory<mem::mic55> &mic55_br;
  Memory<mem::mic56> &mic56_br;
  Memory<mem::mic57> &mic57_br;
  Memory<mem::mic58> &mic58_br;
  Memory<mem::mic59> &mic59_br;

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

  static constexpr std::array<uint8_t, 30> M_DATA_TO_MIC = {
      59, 57, 55, 53, 51, 49, 47, 45, 43, 41, 39, 37, 35, 33, 31,
      29, 27, 25, 23, 21, 19, 17, 15, 13, 11, 9,  7,  5,  3,  1};

  void beamf_thread();
};

inline void Sesenta::start_beamforming() {
  ctx.print<INFO>("Enter beamforming thread\n");
  if (!beamforming_started) {
    beamforming_thread = std::thread{&Sesenta::beamf_thread, this};
    beamforming_thread.detach();
  }
}

inline void Sesenta::beamf_thread() {
  beamforming_started = true;
  ctx.print<INFO>("Beamforming thread started for 30 directions.\n");
  ctx.print<INFO>("BRAM buffer size: %u samples\n", mic_size);
  ctx.print<INFO>("Silence threshold: %.2e\n", SILENCE_THRESHOLD);

  while (beamforming_started) {
    bf();
  }
}

#endif // __DRIVERS_SESENTA_IMPROVED_HPP__
