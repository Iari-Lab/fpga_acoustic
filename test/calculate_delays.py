import numpy as np

SOUND_SPEED = 343  # m/s
SAMPLING_FREQ = 48000
SYSTEM_CLOCK = 120e6
SOURCE_HEIGHT = 0.15  # mts (15 cm above mict s)

# hexagon  on RED leds
selected_mics = {
    31: (-0.040, 0.0346),   # (-40.0, 34.6) mm
    28: (-0.050, -0.0173),  # (-50.0, -17.3) mm
    25: (-0.010, -0.052),   # (-10.0, -52.0) mm
    22: (0.040, -0.0346),   # (40.0, -34.6) mm
    19: (0.050, 0.0173),    # (50.0, 17.3) mm
    34: (0.010, 0.052)      # (10.0, 52.0) mm
}

mic_ids = list(selected_mics.keys())
mic_positions = np.array(list(selected_mics.values()))


def calculate_3d_distance(source_pos, mic_pos):
    """3D distance between src and mic"""
    return np.sqrt((source_pos[0] - mic_pos[0])**2 +
                   (source_pos[1] - mic_pos[1])**2 +
                   (source_pos[2] - 0)**2)  # Mics at z=0


def calculate_delays_for_source(source_mic_id, mic_positions, mic_ids):

    # Source: 15cm above
    source_idx = mic_ids.index(source_mic_id)
    source_x, source_y = mic_positions[source_idx]
    source_pos = (source_x, source_y, SOURCE_HEIGHT)

    print(f"\nSource above Mic {source_mic_id}:")
    print(
        f"Source position: ({source_x*1000:.1f}, {source_y*1000:.1f}, {SOURCE_HEIGHT*1000:.1f}) mm")

    # distances from source to all
    distances = []
    for i, mic_id in enumerate(mic_ids):
        mic_pos = mic_positions[i]
        distance = calculate_3d_distance(source_pos, mic_pos)
        distances.append(distance)
        print(f"  distance {mic_id}: {distance*1000:.2f} mm")

    distances = np.array(distances)

    # Calculate propagation times
    propagation_times = distances / SOUND_SPEED

    # Ref time (shortest path - should be the microphone directly below)
    reference_time = np.min(propagation_times)
    reference_mic_idx = np.argmin(propagation_times)
    reference_mic_id = mic_ids[reference_mic_idx]

    # print(f"  Reference mic: {reference_mic_id} (shortest path: {reference_time*1e6:.2f} μs)")

    # delays relative to reference
    delays = propagation_times - reference_time

    # sample delays
    sample_delays = np.round(delays * SAMPLING_FREQ).astype(int)

    return {
        'source_mic_id': source_mic_id,
        'source_position': source_pos,
        'distances': distances,
        'propagation_times': propagation_times,
        'delays': delays,
        'sample_delays': sample_delays,
        'reference_mic_id': reference_mic_id
    }


# delays for each source position (above each microphone)
all_results = {}

for source_mic_id in mic_ids:
    result = calculate_delays_for_source(source_mic_id, mic_positions, mic_ids)
    all_results[source_mic_id] = result


all_delays = []
all_sample_delays = []

for result in all_results.values():
    all_delays.extend(result['delays'])
    all_sample_delays.extend(result['sample_delays'])

print(
    f"Time delay: {np.min(all_delays)*1e6:.1f} to {np.max(all_delays)*1e6:.1f} μs")
print(
    f"Sample delay: {np.min(all_sample_delays)} to {np.max(all_sample_delays)} samples")

# elays matrix
print(f"\nDelays (us):")
print(f"{'Source→':<8}", end="")
for mic_id in mic_ids:
    print(f"M{mic_id:<4}", end="")
print()

for source_mic_id in mic_ids:
    print(f"M{source_mic_id:<7}", end="")
    delays = all_results[source_mic_id]['delays'] * 1e6
    for delay in delays:
        print(f"{delay:5.1f}", end="")
    print()

print(f"\nSamples delay Matrix:")
print(f"{'Source→':<8}", end="")
for mic_id in mic_ids:
    print(f"M{mic_id:<4}", end="")
print()

for source_mic_id in mic_ids:
    print(f"M{source_mic_id:<7}", end="")
    sample_delays = all_results[source_mic_id]['sample_delays']
    for delay in sample_delays:
        print(f"{delay:5d}", end="")
    print()
