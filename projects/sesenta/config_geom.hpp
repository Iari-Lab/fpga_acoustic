/// config_geom.hpp
/// Microphone array geometry configuration
/// Generated from positions_with_mcu_pins.csv

#ifndef __CONFIG_GEOM_HPP__
#define __CONFIG_GEOM_HPP__

#include <array>
#include <cstdint>

namespace geom {

// 2D Position structure for microphone locations
struct MicPosition {
    float x;    // mm
    float y;    // mm
};

// Total number of microphones in the array
constexpr uint32_t NUM_MICS = 60;

// Microphone positions from CSV (x, y in mm)
// Index corresponds to microphone number (M0 = index 0, M1 = index 1, etc.)
constexpr std::array<MicPosition, NUM_MICS> MIC_POSITIONS = {{
    // M0-M9
    {  20.0f,    0.0f     },  // M0
    {  10.0f,   17.32051f },  // M1
    { -10.0f,   17.32051f },  // M2
    { -20.0f,    0.0f     },  // M3
    { -10.0f,  -17.32051f },  // M4
    {  10.0f,  -17.32051f },  // M5
    {  30.0f,  -17.32051f },  // M6
    {  40.0f,    0.0f     },  // M7
    {  30.0f,   17.32051f },  // M8
    {  20.0f,   34.64102f },  // M9
    
    // M10-M19
    {   0.0f,   34.64102f },  // M10
    { -20.0f,   34.64102f },  // M11
    { -30.0f,   17.32051f },  // M12
    { -40.0f,    0.0f     },  // M13
    { -30.0f,  -17.32051f },  // M14
    { -20.0f,  -34.64102f },  // M15
    {   0.0f,  -34.64102f },  // M16
    {  20.0f,  -34.64102f },  // M17
    {  40.0f,  -34.64102f },  // M18
    {  50.0f,  -17.32051f },  // M19
    
    // M20-M29
    {  60.0f,    0.0f     },  // M20
    {  50.0f,   17.32051f },  // M21
    {  40.0f,   34.64102f },  // M22
    {  30.0f,   51.96152f },  // M23
    {  10.0f,   51.96152f },  // M24
    { -10.0f,   51.96152f },  // M25
    { -30.0f,   51.96152f },  // M26
    { -40.0f,   34.64102f },  // M27
    { -50.0f,   17.32051f },  // M28
    { -60.0f,    0.0f     },  // M29
    
    // M30-M39
    { -50.0f,  -17.32051f },  // M30
    { -40.0f,  -34.64102f },  // M31
    { -30.0f,  -51.96152f },  // M32
    { -10.0f,  -51.96152f },  // M33
    {  10.0f,  -51.96152f },  // M34
    {  30.0f,  -51.96152f },  // M35
    {  50.0f,  -51.96152f },  // M36
    {  60.0f,  -34.64102f },  // M37
    {  70.0f,  -17.32051f },  // M38
    {  80.0f,    0.0f     },  // M39
    
    // M40-M49
    {  70.0f,   17.32051f },  // M40
    {  60.0f,   34.64102f },  // M41
    {  50.0f,   51.96152f },  // M42
    {  40.0f,   69.28203f },  // M43
    {  20.0f,   69.28203f },  // M44
    {   0.0f,   69.28203f },  // M45
    { -20.0f,   69.28203f },  // M46
    { -40.0f,   69.28203f },  // M47
    { -50.0f,   51.96152f },  // M48
    { -60.0f,   34.64102f },  // M49
    
    // M50-M59
    { -70.0f,   17.32051f },  // M50
    { -80.0f,    0.0f     },  // M51
    { -70.0f,  -17.32051f },  // M52
    { -60.0f,  -34.64102f },  // M53
    { -50.0f,  -51.96152f },  // M54
    { -40.0f,  -69.28203f },  // M55
    { -20.0f,  -69.28203f },  // M56
    {   0.0f,  -69.28203f },  // M57
    {  20.0f,  -69.28203f },  // M58
    {  40.0f,  -69.28203f }   // M59
}};

// Helper function to get position by mic index
inline MicPosition getMicPosition(uint32_t mic_idx) {
    if (mic_idx < NUM_MICS) {
        return MIC_POSITIONS[mic_idx];
    }
    return {0.0f, 0.0f};  // Return center if invalid index
}

// Helper function to find nearest mic to a given position
inline uint32_t findNearestMic(float x, float y) {
    uint32_t nearest = 0;
    float min_dist_sq = 1e9f;
    
    for (uint32_t i = 0; i < NUM_MICS; i++) {
        float dx = x - MIC_POSITIONS[i].x;
        float dy = y - MIC_POSITIONS[i].y;
        float dist_sq = dx * dx + dy * dy;
        if (dist_sq < min_dist_sq) {
            min_dist_sq = dist_sq;
            nearest = i;
        }
    }
    return nearest;
}

// Array geometry bounds (useful for visualization/normalization)
constexpr float ARRAY_X_MIN = -80.0f;  // mm
constexpr float ARRAY_X_MAX =  80.0f;  // mm
constexpr float ARRAY_Y_MIN = -69.28203f;  // mm
constexpr float ARRAY_Y_MAX =  69.28203f;  // mm

// Array center (should be 0,0 but defined for clarity)
constexpr float ARRAY_CENTER_X = 0.0f;
constexpr float ARRAY_CENTER_Y = 0.0f;

// Approximate array radius (outermost mic distance from center)
constexpr float ARRAY_RADIUS = 80.0f;  // mm

}  // namespace geom

#endif // __CONFIG_GEOM_HPP__
