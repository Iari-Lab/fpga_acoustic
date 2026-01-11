/// (c) Koheron
/// Improved Kalman Filter Implementation for Sound Source Tracking
/// Features: Sound Activity Detection, 2D Position Tracking, Adaptive Noise

#ifndef __DRIVERS_SESENTA_IMPROVED_HPP__
#define __DRIVERS_SESENTA_IMPROVED_HPP__

#include <algorithm>
#include <array>
#include <chrono>
#include <cmath>
#include <context.hpp>
#include <iostream>
#include <opencv2/core.hpp>
#include <opencv2/video/tracking.hpp>
#include "opencv2/core/cvdef.h"
#include <stdio.h>
#include <deque>
#include "config_geom.hpp"

using namespace cv;

constexpr uint32_t mic_size = mem::mic0_range / sizeof(uint32_t);

// Sound Activity Detection parameters
constexpr double POWER_THRESHOLD = 1e6;  // Adjust based on your microphone sensitivity
constexpr double MIN_VALID_POWER = 1e4;   // Minimum power for valid measurement
constexpr int SAD_HISTORY_SIZE = 5;       // Frames for activity decision
constexpr double VELOCITY_THRESHOLD = 0.1; // Maximum reasonable velocity (m/s)

// 2D Position structure for microphone locations
struct MicPosition {
    float x;  // mm
    float y;  // mm
};

class SesentaImproved {
public:
    SesentaImproved(Context &ctx_)
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
          // 2D Kalman filter: state = [x, y, vx, vy], measurement = [x, y]
          kf(4, 2, 0, CV_32F),
          sound_detected(false),
          last_valid_direction(-1),
          consecutive_invalid_frames(0) {
        
        ctx.print<INFO>("Improved Kalman Filter with Sound Activity Detection initialized");
        
        // Initialize microphone positions (from CSV data)
        initializeMicrophonePositions();
        
        // Initialize 2D Kalman filter
        initializeKalmanFilter();
        
        // Initialize sound activity detection
        initializeSoundDetection();
    }
    
    ~SesentaImproved() {
        beamforming_started = false;
        beamforming_thread.join();
    }

private:
    // Microphone positions (loaded from CSV equivalent)
    std::array<MicPosition, 60> mic_positions;
    
    // Sound activity detection
    bool sound_detected;
    int last_valid_direction;
    int consecutive_invalid_frames;
    std::deque<double> power_history;
    
    // Kalman filter state management
    bool filter_initialized;
    cv::Mat last_valid_state;
    
    void initializeMicrophonePositions() {
        // Initialize microphone positions from your CSV data
        // This is a simplified version - load actual positions from your CSV
        for (int i = 0; i < 60; i++) {
            // Convert polar to cartesian based on your CSV data
            float angle_deg = (i * 6.0f);  // Approximate based on hexagonal layout
            float radius = 20.0f + (i / 6) * 20.0f;  // Ring-based positioning
            
            mic_positions[i].x = radius * cos(angle_deg * M_PI / 180.0f);
            mic_positions[i].y = radius * sin(angle_deg * M_PI / 180.0f);
            mic_positions[i].angle = angle_deg;
        }
    }
    
    void initializeKalmanFilter() {
        // 2D Constant Velocity Model
        // State: [x, y, vx, vy]
        // Measurement: [x, y]
        
        // Transition matrix (constant velocity model)
        // [1 0 1 0]  x = x + vx*dt
        // [0 1 0 1]  y = y + vy*dt
        // [0 0 1 0]  vx = vx
        // [0 0 0 1]  vy = vy
        kf.transitionMatrix = (cv::Mat_<float>(4, 4) << 
            1, 0, 1, 0,
            0, 1, 0, 1,
            0, 0, 1, 0,
            0, 0, 0, 1);
        
        // Measurement matrix - we measure x and y position
        kf.measurementMatrix = (cv::Mat_<float>(2, 4) << 
            1, 0, 0, 0,
            0, 1, 0, 0);
        
        // Process noise covariance
        cv::setIdentity(kf.processNoiseCov, cv::Scalar::all(0.1));
        
        // Measurement noise covariance (will be adaptive)
        cv::setIdentity(kf.measurementNoiseCov, cv::Scalar::all(100.0));
        
        // Initial error covariance
        cv::setIdentity(kf.errorCovPost, cv::Scalar::all(1000.0));
        
        // Initial state (start at center, zero velocity)
        kf.statePost.at<float>(0) = 0.0f;  // x
        kf.statePost.at<float>(1) = 0.0f;  // y
        kf.statePost.at<float>(2) = 0.0f;  // vx
        kf.statePost.at<float>(3) = 0.0f;  // vy
        
        filter_initialized = true;
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
        
        // Decision logic
        bool current_detection = (avg_power > POWER_THRESHOLD) && 
                                (power > MIN_VALID_POWER);
        
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
    
    // Convert direction index to 2D position
    cv::Mat directionToPosition(int direction, double power) {
        cv::Mat position = cv::Mat::zeros(2, 1, CV_32F);
        
        if (direction >= 0 && direction < 60) {
            // Map direction to microphone position
            float x = mic_positions[direction].x;
            float y = mic_positions[direction].y;
            
            // Adjust confidence based on power
            float confidence = std::min(1.0f, (float)(power / POWER_THRESHOLD));
            
            position.at<float>(0) = x * confidence;
            position.at<float>(1) = y * confidence;
        }
        
        return position;
    }
    
    // Validate measurement consistency
    bool isMeasurementValid(const cv::Mat& measurement) {
        if (!filter_initialized) return true;
        
        // Check if measurement is reasonable given current state
        cv::Mat predicted = kf.predict();
        float dx = measurement.at<float>(0) - predicted.at<float>(0);
        float dy = measurement.at<float>(1) - predicted.at<float>(1);
        float distance = std::sqrt(dx*dx + dy*dy);
        
        // Reject measurements that are too far from prediction
        return distance < 50.0f;  // 50mm threshold
    }
    
    // Adaptive measurement noise based on signal quality
    void updateMeasurementNoise(double power, double confidence) {
        // Lower noise for higher power/confidence
        double base_noise = 100.0;
        double noise_factor = std::max(0.1, 1.0 - confidence);
        double adaptive_noise = base_noise * noise_factor;
        
        kf.measurementNoiseCov.at<float>(0, 0) = adaptive_noise;
        kf.measurementNoiseCov.at<float>(1, 1) = adaptive_noise;
    }

public:
    // Enhanced beamforming function with 2D tracking
    void bf_improved() {
        const int num_directions = 60;  // All microphones
        std::array<double, num_directions> beam_powers = {0.0};
        
        record();
        
        int max_direction = -1;
        double max_power = 0.0;
        
        // Scan all directions
        for (int dir = 0; dir < num_directions; dir++) {
            auto beamformed_sum = get_mic_ith(dir);
            
            double power = 0.0;
            for (uint32_t sample_idx = 0; sample_idx < mic_size; sample_idx++) {
                double sample = (double)beamformed_sum[sample_idx];
                power += (sample * sample);
            }
            
            beam_powers[dir] = power / mic_size;
            
            if (beam_powers[dir] > max_power) {
                max_power = beam_powers[dir];
                max_direction = dir;
            }
        }
        
        // Sound Activity Detection
        bool sound_active = detectSoundActivity(max_power);
        
        if (sound_active && max_direction >= 0) {
            // Convert direction to 2D position
            cv::Mat measurement = directionToPosition(max_direction, max_power);
            
            // Validate measurement
            if (isMeasurementValid(measurement)) {
                // Update measurement noise based on signal quality
                double confidence = std::min(1.0, max_power / POWER_THRESHOLD);
                updateMeasurementNoise(max_power, confidence);
                
                // Kalman filter: predict then correct
                cv::Mat prediction = kf.predict();
                cv::Mat corrected = kf.correct(measurement);
                
                // Extract filtered position
                float filtered_x = corrected.at<float>(0);
                float filtered_y = corrected.at<float>(1);
                float filtered_vx = corrected.at<float>(2);
                float filtered_vy = corrected.at<float>(3);
                
                // Find closest microphone to filtered position
                int closest_mic = findClosestMicrophone(filtered_x, filtered_y);
                
                // Validate velocity
                float velocity = std::sqrt(filtered_vx*filtered_vx + filtered_vy*filtered_vy);
                
                ctx.print<INFO>("Sound detected at direction: %d (M%d), Power: %e, "
                               "Filtered pos: (%.1f, %.1f)mm, Velocity: %.2f m/s\n",
                               max_direction, M_DATA_TO_MIC[max_direction], max_power,
                               filtered_x, filtered_y, velocity);
                
                // Only update LED if velocity is reasonable
                if (velocity < VELOCITY_THRESHOLD) {
                    set_led_sel(M_DATA_TO_MIC[closest_mic]);
                    last_valid_direction = closest_mic;
                } else {
                    ctx.print<DEBUG>("Velocity too high, maintaining last position\n");
                    if (last_valid_direction >= 0) {
                        set_led_sel(M_DATA_TO_MIC[last_valid_direction]);
                    }
                }
                
            } else {
                ctx.print<DEBUG>("Invalid measurement rejected\n");
                // Use prediction if measurement is invalid
                cv::Mat prediction = kf.predict();
                
                float pred_x = prediction.at<float>(0);
                float pred_y = prediction.at<float>(1);
                int closest_mic = findClosestMicrophone(pred_x, pred_y);
                
                set_led_sel(M_DATA_TO_MIC[closest_mic]);
            }
            
        } else {
            // No sound detected - stop predicting and maintain last position
            ctx.print<DEBUG>("No sound detected (Power: %e), maintaining position\n", max_power);
            
            if (last_valid_direction >= 0) {
                set_led_sel(M_DATA_TO_MIC[last_valid_direction]);
            } else {
                // Default to center if no previous valid position
                set_led_sel(M_DATA_TO_MIC[30]);  // Center microphone
            }
            
            // Optionally reset filter if no sound for extended period
            consecutive_invalid_frames++;
            if (consecutive_invalid_frames > 100) {  // ~1-2 seconds
                // Reset to avoid drift
                kf.statePost.at<float>(0) = 0.0f;
                kf.statePost.at<float>(1) = 0.0f;
                kf.statePost.at<float>(2) = 0.0f;
                kf.statePost.at<float>(3) = 0.0f;
            }
        }
    }
    
    // Find closest microphone to given position
    int findClosestMicrophone(float x, float y) {
        int closest_idx = 0;
        float min_distance = std::numeric_limits<float>::max();
        
        for (int i = 0; i < 60; i++) {
            float dx = x - mic_positions[i].x;
            float dy = y - mic_positions[i].y;
            float distance = std::sqrt(dx*dx + dy*dy);
            
            if (distance < min_distance) {
                min_distance = distance;
                closest_idx = i;
            }
        }
        
        return closest_idx;
    }

    // Existing functions (unchanged)
    std::array<int32_t, mic_size> get_mic_ith(uint32_t mic_idx) {
        // ... (same as original implementation)
        std::array<int32_t, mic_size> mic_data;
        
        // Add bounds checking
        if (mic_idx >= 30) {  // Adjust based on your actual microphone count
            ctx.print<ERROR>("Invalid microphone index: %d\n", mic_idx);
            return std::array<int32_t, mic_size>{0};
        }
        
        switch (mic_idx) {
            // ... (add cases for all your microphones)
            // For now, using original implementation:
            case 0: mic_data = mic0_br.read_array<int32_t, mic_size>(); break;
            case 1: mic_data = mic1_br.read_array<int32_t, mic_size>(); break;
            case 2: mic_data = mic2_br.read_array<int32_t, mic_size>(); break;
            case 3: mic_data = mic3_br.read_array<int32_t, mic_size>(); break;
            case 4: mic_data = mic4_br.read_array<int32_t, mic_size>(); break;
            case 5: mic_data = mic5_br.read_array<int32_t, mic_size>(); break;
            case 6: mic_data = mic6_br.read_array<int32_t, mic_size>(); break;
            case 7: mic_data = mic7_br.read_array<int32_t, mic_size>(); break;
            case 8: mic_data = mic8_br.read_array<int32_t, mic_size>(); break;
            case 9: mic_data = mic9_br.read_array<int32_t, mic_size>(); break;
            case 10: mic_data = mic10_br.read_array<int32_t, mic_size>(); break;
            case 11: mic_data = mic11_br.read_array<int32_t, mic_size>(); break;
            case 12: mic_data = mic12_br.read_array<int32_t, mic_size>(); break;
            case 13: mic_data = mic13_br.read_array<int32_t, mic_size>(); break;
            case 14: mic_data = mic14_br.read_array<int32_t, mic_size>(); break;
            case 15: mic_data = mic15_br.read_array<int32_t, mic_size>(); break;
            case 16: mic_data = mic16_br.read_array<int32_t, mic_size>(); break;
            case 17: mic_data = mic17_br.read_array<int32_t, mic_size>(); break;
            case 18: mic_data = mic18_br.read_array<int32_t, mic_size>(); break;
            case 19: mic_data = mic19_br.read_array<int32_t, mic_size>(); break;
            case 20: mic_data = mic20_br.read_array<int32_t, mic_size>(); break;
            case 21: mic_data = mic21_br.read_array<int32_t, mic_size>(); break;
            case 22: mic_data = mic22_br.read_array<int32_t, mic_size>(); break;
            case 23: mic_data = mic23_br.read_array<int32_t, mic_size>(); break;
            case 24: mic_data = mic24_br.read_array<int32_t, mic_size>(); break;
            case 25: mic_data = mic25_br.read_array<int32_t, mic_size>(); break;
            case 26: mic_data = mic26_br.read_array<int32_t, mic_size>(); break;
            case 27: mic_data = mic27_br.read_array<int32_t, mic_size>(); break;
            case 28: mic_data = mic28_br.read_array<int32_t, mic_size>(); break;
            case 29: mic_data = mic29_br.read_array<int32_t, mic_size>(); break;
            default:
                ctx.print<ERROR>("Invalid microphone index: %d\n", mic_idx);
                return std::array<int32_t, mic_size>{0};
        }
        
        return mic_data;
    }
    
    void record() {
        ctl.set_bit<reg::start_capture, 0>();
        std::this_thread::sleep_for(std::chrono::microseconds(1));
        ctl.clear_bit<reg::start_capture, 0>();
        while (!(sts.read_reg(reg::done_capture) & 0x1));
    }
    
    void set_led_sel(uint32_t sel) { 
        ctl.write_reg(reg::led_select, sel); 
    }
    
    void start_beamforming() {
        if (!beamforming_started) {
            beamforming_thread = std::thread{&SesentaImproved::beamf_thread, this};
            beamforming_thread.detach();
        }
    }
    
    void beamf_thread() {
        beamforming_started = true;
        ctx.print<INFO>("Improved beamforming thread started\n");
        while (beamforming_started) {
            bf_improved();
        }
    }

private:
    // Member variables (same as original plus new ones)
    Context &ctx;
    Memory<mem::control> &ctl;
    Memory<mem::status> &sts;
    // ... (all the mic memory references)
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
    
    std::atomic<bool> beamforming_started{false};
    std::thread beamforming_thread;
    cv::KalmanFilter kf;
    
    // Updated mapping for 60 microphones (if needed)
    static constexpr std::array<uint8_t, 30> M_DATA_TO_MIC = {
        59, 57, 55, 53, 51, 49, 47, 45, 43, 41, 39, 37, 35, 33, 31,
        29, 27, 25, 23, 21, 19, 17, 15, 13, 11, 9,  7,  5,  3,  1};
};

#endif // __DRIVERS_SESENTA_IMPROVED_HPP__
