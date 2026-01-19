#!/usr/bin/env python3
"""
BRAM Configuration Generator for Sesenta Project
Generates memory configuration for config.yml based on user parameters.
"""

import argparse

def parse_range(range_str):
    """Convert range string (e.g., '8K', '16K') to bytes."""
    range_str = range_str.upper().strip()
    if range_str.endswith('K'):
        return int(range_str[:-1]) * 1024
    elif range_str.endswith('M'):
        return int(range_str[:-1]) * 1024 * 1024
    else:
        return int(range_str)

def generate_mic_config(num_mics, range_str, start_offset):
    """Generate microphone memory configuration entries."""
    range_bytes = parse_range(range_str)
    
    entries = []
    current_offset = start_offset
    
    for i in range(num_mics):
        entry = f"""- name: mic{i}
  range: {range_str}
  offset: '0x{current_offset:08X}'"""
        entries.append(entry)
        current_offset += range_bytes
    
    return '\n'.join(entries)

def generate_full_config(num_mics, range_str, start_offset=0x40040000):
    """Generate the complete config.yml content."""
    mic_config = generate_mic_config(num_mics, range_str, start_offset)
    
    config = f"""name: sesenta
board: boards/myir
cores:
- fpga/cores/axi_ctl_register_v1_0
- fpga/cores/axis_variable_v1_0
- fpga/cores/axis_tlast_v1_0
- fpga/cores/axi_sts_register_v1_0
- fpga/cores/addr_counter_v1_0
memory:
- name: control
  range: 4K
  offset: '0x40000000'
- name: status
  range: 4K
  offset: '0x50000000'
{mic_config}

control_registers:
- led_select
- start_capture
status_registers:
- mode
- done_capture
parameters:
  fclk0: 100000000
xdc:
- boards/myir/config/ports.xdc
drivers:
- server/drivers/common.hpp
- ./sesenta.hpp
"""
    return config

def main():
    parser = argparse.ArgumentParser(description='Generate BRAM configuration for config.yml')
    parser.add_argument('-n', '--num-mics', type=int, default=30,
                        help='Number of microphones (default: 30)')
    parser.add_argument('-r', '--range', type=str, default='16K',
                        help='Range per mic (e.g., 8K, 16K, 32K) (default: 16K)')
    parser.add_argument('-o', '--offset', type=str, default='0x40040000',
                        help='Starting offset in hex (default: 0x40040000)')
    parser.add_argument('-f', '--output-file', type=str, default=None,
                        help='Output file path (default: print to stdout)')
    parser.add_argument('--only-mics', action='store_true',
                        help='Only output the mic entries, not the full config')
    
    args = parser.parse_args()
    
    # Parse starting offset
    start_offset = int(args.offset, 16) if args.offset.startswith('0x') else int(args.offset)
    
    if args.only_mics:
        result = generate_mic_config(args.num_mics, args.range, start_offset)
    else:
        result = generate_full_config(args.num_mics, args.range, start_offset)
    
    if args.output_file:
        with open(args.output_file, 'w') as f:
            f.write(result)
        print(f"Configuration written to {args.output_file}")
        print(f"  - Mics: {args.num_mics}")
        print(f"  - Range: {args.range}")
        print(f"  - Start offset: 0x{start_offset:08X}")
        print(f"  - End offset: 0x{start_offset + args.num_mics * parse_range(args.range):08X}")
    else:
        print(result)

def generate_sesenta_hpp(num_mics):
    """Generate the sesenta.hpp file content."""
    
    # Constructor initializer list
    init_list = ',\n        '.join([f"mic{i}_br(ctx.mm.get<mem::mic{i}>())" for i in range(num_mics)])
    
    # Switch cases
    switch_cases = '\n'.join([f"""    case {i}:
      mic_data = mic{i}_br.read_array<int32_t, mic_size>();
      break;""" for i in range(num_mics)])
    
    # Member declarations
    members = '\n'.join([f"  Memory<mem::mic{i}> &mic{i}_br;" for i in range(num_mics)])
    
    # M_DATA_TO_MIC array (counting down from 58, ending with 59)
    mic_map = list(range(58, 58 - num_mics + 1, -1))
    if len(mic_map) > 0:
        mic_map[-1] = 59
    mic_map_str = ', '.join([str(x) for x in mic_map])
    
    hpp_content = f'''/// (c) Koheron

#ifndef __DRIVERS_SESENTA_HPP__
#define __DRIVERS_SESENTA_HPP__

#include <algorithm>
#include <array>
#include <chrono>
#include <cmath>
#include <context.hpp>
#include <iostream>
constexpr uint32_t mic_size = mem::mic0_range / sizeof(uint32_t);

class Sesenta {{
public:
  Sesenta(Context &ctx_)
      : ctx(ctx_), ctl(ctx.mm.get<mem::control>()),
        sts(ctx.mm.get<mem::status>()), {init_list} {{
    ctx.print<INFO>("BEAm------------------------------------------>");
  }}
  ~Sesenta() {{
    beamforming_started = false;
    beamforming_thread.join();
  }}

  uint32_t i_rst_clk_mics = 0;
  uint32_t i_rst_leds = 1;
  unsigned int i_dma_gate = 2;

  std::array<int32_t, mic_size> get_mic_ith(uint32_t mic_idx) {{
    std::array<int32_t, mic_size> mic_data;
    switch (mic_idx) {{
{switch_cases}
    default:
      return std::array<int32_t, mic_size>{{0}};
    }}
    return mic_data;
  }}
  void start_bf() {{ start_beamforming(); }}

  void record() {{
    ctl.set_bit<reg::start_capture, 0>();
    std::this_thread::sleep_for(std::chrono::microseconds(1));
    ctl.clear_bit<reg::start_capture, 0>();
    while (!(sts.read_reg(reg::done_capture) & 0x1));
  }}
  void set_mic_sel(uint32_t sel) {{
    ctl.write_reg(reg::mic_select, sel);
    ctl.set_bit<reg::start_capture, 0>();
    std::this_thread::sleep_for(std::chrono::microseconds(1));
    ctl.clear_bit<reg::start_capture, 0>();
    while (!(sts.read_reg(reg::done_capture) & 0x1));
  }}

  auto get_mics_bram(uint32_t dir) {{
    const int num_mics = {num_mics};
    std::vector<int32_t> data_ret = {{}};
    for (int mic = 0; mic < num_mics; mic++) {{
      set_mic_sel(dir);
      auto mic_data = get_mic_ith(mic);
      for (uint32_t sample_idx = 0; sample_idx < mic_size; sample_idx++) {{
        data_ret.push_back(mic_data[sample_idx]);
      }}
    }}
    return data_ret;
  }}
  void beamf(uint32_t dir) {{
    record();
    auto beamformed_sum = get_mic_ith(dir);
    double power = 0.0;
    for (uint32_t sample_idx = 0; sample_idx < mic_size; sample_idx++) {{
      double sample = (double)beamformed_sum[sample_idx];
      power += (sample * sample);
    }}
    ctx.print<DEBUG>("Direction MIC %d: LED = %d   power: %f\\n", dir, M_DATA_TO_MIC[dir], power);
    set_led_sel(M_DATA_TO_MIC[dir]);
  }}

  void bf() {{
    const int num_directions = {num_mics};
    std::array<double, num_directions> beam_powers = {{0.0}};
    record();
    int max_direction = 0;
    double max_power = 0.0;
    for (int dir = 0; dir < num_directions; dir++) {{
      beam_powers = {{0.0}};
      auto beamformed_sum = get_mic_ith(dir);
      double power = 0.0;
      for (uint32_t sample_idx = 0; sample_idx < mic_size; sample_idx++) {{
        double sample = (double)beamformed_sum[sample_idx];
        power += (sample * sample);
      }}
      beam_powers[dir] = power / mic_size;
      if (beam_powers[dir] > max_power) {{
        max_power = beam_powers[dir];
        max_direction = dir;
      }}
    }}
    ctx.print<INFO>("Maximum sound energy detected from direction: %d (M%d) (Power: %e)\\n",
                    max_direction, M_DATA_TO_MIC[max_direction], max_power);
    set_led_sel(M_DATA_TO_MIC[max_direction]);
  }}
  void set_led_sel(uint32_t sel) {{ ctl.write_reg(reg::led_select, sel); }}
  uint32_t get_mic_size() {{ return mic_size; }}
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
{members}
  std::atomic<bool> beamforming_started{{false}};
  std::thread beamforming_thread;
  static constexpr std::array<uint8_t, {num_mics}> M_DATA_TO_MIC = {{{mic_map_str}}};
  void beamf_thread();
}};

inline void Sesenta::start_beamforming() {{
  ctx.print<INFO>(" enter thread\\n");
  if (!beamforming_started) {{
    beamforming_thread = std::thread{{&Sesenta::beamf_thread, this}};
    beamforming_thread.detach();
  }}
}}

inline void Sesenta::beamf_thread() {{
  beamforming_started = true;
  ctx.print<INFO>("Beamforming thread started for {num_mics} directions.\\n");
  ctx.print<INFO>("BRAM buffer size: %u samples\\n", mic_size);
  while (beamforming_started) {{ bf(); }}
}}
#endif // __SESENTA_HPP__
'''
    return hpp_content


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Generate BRAM config.yml and sesenta.hpp')
    parser.add_argument('-n', '--num-mics', type=int, default=30, help='Number of mics (default: 30)')
    parser.add_argument('-r', '--range', type=str, default='16K', help='Range per mic (default: 16K)')
    parser.add_argument('-o', '--offset', type=str, default='0x40040000', help='Start offset (default: 0x40040000)')
    parser.add_argument('-f', '--output-file', type=str, default=None, help='Output config.yml path')
    parser.add_argument('--hpp', type=str, default=None, help='Output sesenta.hpp path')
    parser.add_argument('--only-mics', action='store_true', help='Only output mic entries')
    args = parser.parse_args()
    
    start_offset = int(args.offset, 16) if args.offset.startswith('0x') else int(args.offset)
    
    if args.only_mics:
        result = generate_mic_config(args.num_mics, args.range, start_offset)
    else:
        result = generate_full_config(args.num_mics, args.range, start_offset)
    
    if args.output_file:
        with open(args.output_file, 'w') as f:
            f.write(result)
        print(f"config.yml written to {args.output_file}")
    else:
        print(result)
    
    if args.hpp:
        with open(args.hpp, 'w') as f:
            f.write(generate_sesenta_hpp(args.num_mics))
        print(f"sesenta.hpp written to {args.hpp}")
    
    print(f"\nSummary: {args.num_mics} mics, {args.range} range, 0x{start_offset:08X} - 0x{start_offset + args.num_mics * parse_range(args.range):08X}")
