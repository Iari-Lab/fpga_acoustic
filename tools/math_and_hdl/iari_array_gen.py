#!/usr/bin/env python3
"""
IARI Microphone Array Tool 

1. Visualization with PCB SVG background (properly aligned)
2. XDC constraint file generation
3. Verilog delays generation with calculated delays

"""

import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import matplotlib.patches as patches
from pathlib import Path
import warnings
import cairosvg
from PIL import Image
import io

# Constants for delay calculation
SOUND_SPEED = 343  # m/s
SAMPLING_FREQ = 48000
SOURCE_HEIGHT = 0.15  # 15 cm above mics

# SVG transformation constants (determined by matching SVG circles to CSV positions)
SVG_CENTER_X = 80.591125
SVG_CENTER_Y = 89.899269
SVG_WIDTH = 161.1884
SVG_HEIGHT = 179.7812


def setup_matplotlib():
    """Setup matplotlib for plotting"""
    warnings.filterwarnings('default')
    plt.switch_backend("Agg")
    plt.style.use("seaborn-v0_8")
    plt.rcParams["axes.unicode_minus"] = False


class MicArrayTool:
    """Complete microphone array tool with SVG background support"""

    def __init__(self, csv_path="data/positions_with_mcu_pins.csv",
                 svg_path="sesenta.svg"):
        """
        Initialize the tool

        Args:
            csv_path: Path to CSV with microphone positions
            svg_path: Path to PCB SVG file
        """
        self.csv_path = csv_path
        self.svg_path = svg_path
        self.df = None
        self.distances = None
        self.load_data()

    def load_data(self):
        """Load microphone position data"""
        self.df = pd.read_csv(self.csv_path)
        self.distances = np.sqrt(self.df['x']**2 + self.df['y']**2)
        print(f"Loaded {len(self.df)} microphones from {self.csv_path}")

    def _load_svg_as_image(self):
        """
        Convert SVG to PNG image for matplotlib background

        sesenta.svg dimensions: 179.781200mm (width) x 161.188400mm (height)
        The SVG is oriented with the longer dimension horizontal.

        CSV mic positions:
        - X range: -80 to 80 mm (160mm span)
        - Y range: -69.28 to 69.28 mm (138.56mm span)

        The SVG needs NO rotation - it's already in the correct orientation.
        The SVG center should map to CSV (0, 0).
        """
        if self.svg_path is None or not Path(self.svg_path).exists():
            print(f"Warning: SVG file not found at {self.svg_path}")
            return None, None
        try:
            # Convert SVG to PNG with high resolution
            png_data = cairosvg.svg2png(url=self.svg_path, scale=3.0)
            img = Image.open(io.BytesIO(png_data))

            # NO rotation needed for sesenta.svg - it's already correctly oriented
            # The SVG has width=179.78mm, height=161.19mm
            # which matches the mic array layout (wider than tall)

            return np.array(img), img.size
        except Exception as e:
            print(f"Warning: Could not load SVG: {e}")
            return None, None

    def plot_microphones(self, selected_mics, save_path="output/microphone_array.png",
                         title=None, show_svg_background=True):
        """
        Plot microphone array with PCB SVG background

        Args:
            selected_mics: List of microphone indices to highlight
            save_path: Output path for the plot
            title: Custom title
            show_svg_background: Whether to show SVG as background

        Returns:
            str: Path to saved plot
        """
        setup_matplotlib()

        if selected_mics is None:
            selected_mics = []

        # Create figure
        fig, ax = plt.subplots(1, 1, figsize=(14, 14))

        # Load and display SVG background
        if show_svg_background:
            result = self._load_svg_as_image()
            if result[0] is not None:
                svg_img, (img_width, img_height) = result

                # sesenta.svg viewBox: 0 0 179.781200 161.188400
                # SVG dimensions in mm
                svg_width_mm = 179.7812
                svg_height_mm = 161.1884

                # SVG center in SVG coordinates
                svg_center_x = svg_width_mm / 2   # 89.89
                svg_center_y = svg_height_mm / 2  # 80.59

                # The SVG center maps to CSV (0, 0)
                # So extent in CSV coordinates:
                # left = -svg_center_x, right = svg_width - svg_center_x
                # bottom = -svg_center_y, top = svg_height - svg_center_y

                # But matplotlib imshow expects [left, right, bottom, top]
                # and images are displayed with y=0 at top, so we need to flip

                left = -svg_center_x
                right = svg_width_mm - svg_center_x
                # For imshow with origin='upper' (default), bottom and top are swapped
                bottom = -(svg_height_mm - svg_center_y)
                top = svg_center_y

                extent = [left, right, bottom, top]

                ax.imshow(svg_img, extent=extent,
                          aspect='auto', alpha=0.85, zorder=0)

        # Create selection mask
        selected_mask = self.df.index.isin(selected_mics)

        # Plot unselected microphones
        unselected_df = self.df[~selected_mask]
        if not unselected_df.empty:
            ax.scatter(unselected_df['x'], unselected_df['y'],
                       c='cyan', s=100, alpha=0.7,
                       label=f'Unselected ({len(unselected_df)})',
                       edgecolors='blue', linewidth=1.5, zorder=2)

        # Plot selected microphones
        selected_df = self.df[selected_mask]
        if not selected_df.empty:
            ax.scatter(selected_df['x'], selected_df['y'],
                       c='red', s=150, alpha=0.9,
                       label=f'Selected ({len(selected_df)})',
                       edgecolors='darkred', linewidth=2, zorder=3)

        # Add labels for selected mics
        for idx, row in selected_df.iterrows():
            mic_name = row['mic']
            x, y = row['x'], row['y']
            mcu_pin = row['MCU_Pin']
            ax.annotate(f'{mic_name}\n{mcu_pin}',
                        (x, y),
                        xytext=(5, 5), textcoords='offset points',
                        fontsize=8, fontweight='bold', color='darkred',
                        bbox=dict(boxstyle='round,pad=0.2',
                                  facecolor='yellow', alpha=0.9),
                        zorder=4)

        # Add center marker
        ax.scatter([0], [0], c='lime', s=150, marker='+', linewidth=4,
                   label='Center', zorder=5)

        # Set labels and title
        ax.set_xlabel('X Position (mm)', fontsize=12)
        ax.set_ylabel('Y Position (mm)', fontsize=12)

        if title is None:
            title = f'Microphone Array - {len(selected_mics)} Selected'
        ax.set_title(title, fontsize=14, fontweight='bold')

        ax.set_aspect('equal')
        ax.legend(loc='upper right', fontsize=10)
        ax.grid(True, alpha=0.3, zorder=1)

        # Set axis limits based on data with margin
        margin = 15
        x_min, x_max = self.df['x'].min() - margin, self.df['x'].max() + margin
        y_min, y_max = self.df['y'].min() - margin, self.df['y'].max() + margin
        ax.set_xlim(x_min, x_max)
        ax.set_ylim(y_min, y_max)

        plt.tight_layout()

        # Save
        Path(save_path).parent.mkdir(parents=True, exist_ok=True)
        plt.savefig(save_path, dpi=300, bbox_inches='tight', facecolor='white')
        plt.close()

        print(f"Plot saved to: {save_path}")
        return save_path

    def generate_xdc(self, selected_mics, output_path="output/ports.xdc"):
        """
        Generate XDC constraint file for selected microphones.
        Groups mic pairs that share the same GPIO (rising/falling edge sampling).

        Each D_pin (D0, D2, D4...) handles 2 mics:
        - Even mic index: sampled on rising edge
        - Odd mic index: sampled on falling edge

        Args:
            selected_mics: List of microphone indices
            output_path: Output XDC file path

        Returns:
            str: Path to saved XDC file
        """
        selected_df = self.df.iloc[selected_mics] if selected_mics else pd.DataFrame(
        )

        # Group by D_pin (each D_pin handles a pair of mics)
        gpio_groups = {}
        for orig_idx, row in selected_df.iterrows():
            d_pin = row['D_pin']
            if d_pin not in gpio_groups:
                gpio_groups[d_pin] = {
                    'mcu_pin': row['MCU_Pin'],
                    'io_pin': row['io_pin'],
                    'mics': []
                }
            edge = "rising" if orig_idx % 2 == 0 else "falling"
            gpio_groups[d_pin]['mics'].append((row['mic'], edge))

        num_gpio = len(gpio_groups)

        xdc_lines = [
            "# XDC Constraints for Microphone Array",
            "# Generated by MicArrayTool",
            "#",
            "set_property IOSTANDARD LVCMOS33 [get_ports SYNC_IN]",
            "set_property PACKAGE_PIN U12 [get_ports SYNC_IN]",
            "# MCLK1 - IO_B34_LP14 (BANK 34)",
            "set_property IOSTANDARD LVCMOS33 [get_ports SYNC_OUT]",
            "set_property PACKAGE_PIN T12 [get_ports SYNC_OUT]",
            "# MCLK2 - IO_B34_LP11 (BANK 34)",
            "# MCLK0 - IO_B13_LP21 (BANK 13)",
            "set_property IOSTANDARD LVCMOS33 [get_ports M0_CLK]",
            "set_property PACKAGE_PIN V11 [get_ports M0_CLK]",
            "# MCLK1 - IO_B34_LP14 (BANK 34)",
            "set_property IOSTANDARD LVCMOS33 [get_ports M1_CLK]",
            "set_property PACKAGE_PIN N20 [get_ports M1_CLK]",
            "# MCLK2 - IO_B34_LP11 (BANK 34)",
            "set_property IOSTANDARD LVCMOS33 [get_ports M2_CLK]",
            "set_property PACKAGE_PIN U14 [get_ports M2_CLK]",
            "# LED_DI - IO_B34_LN23 (BANK 34)",
            "set_property IOSTANDARD LVCMOS33 [get_ports LEDS]",
            "set_property PACKAGE_PIN P18 [get_ports LEDS]",
            "set_property IOSTANDARD LVCMOS33 [get_ports {M_DATA[*]}]",
            f"# Total microphones: {len(selected_mics)}",
            f"# GPIO ports needed: {num_gpio} (each GPIO samples 2 mics: rising + falling edge)",
            "#",
            "# Sampling scheme:",
            "#   - Even mic index (M0, M2, M4...): sampled on RISING edge",
            "#   - Odd mic index (M1, M3, M5...): sampled on FALLING edge",
            "#",
            f"# Selected mics: {selected_mics}",
            ""
        ]

        # Sort by D_pin number for consistent ordering
        sorted_dpins = sorted(gpio_groups.keys(), key=lambda x: int(x[1:]))

        for port_idx, d_pin in enumerate(sorted_dpins):
            group = gpio_groups[d_pin]
            mcu_pin = group['mcu_pin']
            io_pin = group['io_pin']
            mics = group['mics']

            mic_info = ", ".join([f"{m}({e})" for m, e in mics])

            xdc_lines.append(f"# {d_pin} -> M_DATA[{port_idx}]")
            xdc_lines.append(f"# Mics: {mic_info}")
            xdc_lines.append(f"# IO: {io_pin}")
            xdc_lines.append(
                f"set_property PACKAGE_PIN {mcu_pin} [get_ports {{M_DATA[{port_idx}]}}]")
            xdc_lines.append("")

        Path(output_path).parent.mkdir(parents=True, exist_ok=True)
        with open(output_path, 'w') as f:
            f.write('\n'.join(xdc_lines))

        print(f"XDC saved to: {output_path}")
        print(f"  Microphones: {len(selected_mics)}")
        print(f"  GPIO ports: {num_gpio}")
        return output_path

    def calculate_delays(self, selected_mics):
        """
        Calculate delay matrix for beamforming :
        delay the signal that arrived first so that it aligns with the signal that arrived last.

        Args:
            selected_mics: List of microphone indices

        Returns:
            dict: All delay results for each source position
        """
        # Get positions for selected mics
        selected_df = self.df.iloc[selected_mics]
        mic_positions = selected_df[['x', 'y']
                                    ].values / 1000.0  # Convert to meters
        mic_ids = selected_mics

        all_results = {}

        for source_idx, source_mic_id in enumerate(mic_ids):
            # Source position: 15cm above the source mic
            source_x, source_y = mic_positions[source_idx]
            source_pos = (source_x, source_y, SOURCE_HEIGHT)

            # Calculate 3D distances to all mics
            distances = []
            for mic_pos in mic_positions:
                dist = np.sqrt((source_pos[0] - mic_pos[0])**2 +
                               (source_pos[1] - mic_pos[1])**2 +
                               (source_pos[2] - 0)**2)
                distances.append(dist)

            distances = np.array(distances)

            # Propagation times
            prop_times = distances / SOUND_SPEED

            # Reference time (shortest path)
            ref_time = np.max(prop_times)
            delays = ref_time - prop_times

            # Sample delays
            sample_delays = np.round(delays * SAMPLING_FREQ).astype(int)

            all_results[source_mic_id] = {
                'source_mic_id': source_mic_id,
                'distances': distances,
                'delays': delays,
                'sample_delays': sample_delays
            }

        return all_results

    def calculate_delays_method2(self, selected_mics):
        """
        Calculate delay matrix for beamforming

        Args:
            selected_mics: List of microphone indices

        Returns:
            dict: All delay results for each source position
        """
        # Get positions for selected mics
        selected_df = self.df.iloc[selected_mics]
        mic_positions = selected_df[['x', 'y']
                                    ].values / 1000.0  # Convert to meters
        mic_ids = selected_mics

        all_results = {}

        for source_idx, source_mic_id in enumerate(mic_ids):
            # Source position: 15cm above the source mic
            source_x, source_y = mic_positions[source_idx]
            source_pos = (source_x, source_y, SOURCE_HEIGHT)

            # Calculate 3D distances to all mics
            distances = []
            for mic_pos in mic_positions:
                dist = np.sqrt((source_pos[0] - mic_pos[0])**2 +
                               (source_pos[1] - mic_pos[1])**2 +
                               (source_pos[2] - 0)**2)
                distances.append(dist)

            distances = np.array(distances)

            # Propagation times
            prop_times = distances / SOUND_SPEED

            # Reference time (shortest path)
            ref_time = np.min(prop_times)

            # Delays relative to reference
            delays = prop_times - ref_time

            # Sample delays
            sample_delays = np.round(delays * SAMPLING_FREQ).astype(int)

            all_results[source_mic_id] = {
                'source_mic_id': source_mic_id,
                'distances': distances,
                'delays': delays,
                'sample_delays': sample_delays
            }

        return all_results

    def generate_delay_line(self, selected_mics, output_path="output/delay_line.v"):
        """Generate Verilog delay_line module"""
        all_results = self.calculate_delays(selected_mics)
        max_delay = max(max(r['sample_delays']) for r in all_results.values())
        delay_bits = max(4, int(np.ceil(np.log2(max_delay + 1))))

        v = []
        v.append(f"module delay_line (")
        v.append(f"    input wire clk,")
        v.append(f"    input wire rst,")
        v.append(f"    input wire pcm_valid,")
        v.append(f"    input wire [{delay_bits-1}:0] delay,")
        v.append(f"    input wire [15:0] pcm_data,")
        v.append(f"    output wire [15:0] delayed_pcm_data")
        v.append(f");")
        v.append(f"")
        v.append(f"  parameter MAX_DELAY = {max_delay};")
        v.append(f"  integer i;")
        v.append(f"  reg [15:0] buffer[MAX_DELAY:0];")
        v.append(f"  reg [{delay_bits-1}:0] delay_reg;")
        v.append(f"  reg [15:0] delayed_pcm_data_r; ")
        v.append(f"")
        v.append(f"  always @(posedge clk or posedge rst) begin")
        v.append(f"    if (rst) begin")
        v.append(f"      for (i = 0; i <= MAX_DELAY; i = i + 1) begin")
        v.append(f"        buffer[i] <= 16'h0000;")
        v.append(f"      end")
        v.append(f"      delay_reg <= {delay_bits}'h0;")
        v.append(f"      delayed_pcm_data_r <= 16'h0000;")
        v.append(f"    end else begin")
        v.append(f"      delay_reg <= delay;")
        v.append(f"      if (pcm_valid) begin")
        v.append(f"        for (i = 0; i < MAX_DELAY; i = i + 1) begin")
        v.append(f"          buffer[i+1] <= buffer[i];")
        v.append(f"        end")
        v.append(f"        buffer[0] <= pcm_data;")
        v.append(f"      end")
        v.append(f"      delayed_pcm_data_r <= buffer[delay_reg];")
        v.append(f"    end")
        v.append(f"  end")
        v.append(f"")
        v.append(f"  assign delayed_pcm_data = delayed_pcm_data_r;")
        v.append(f"")
        v.append(f"endmodule")

        Path(output_path).parent.mkdir(parents=True, exist_ok=True)
        with open(output_path, 'w') as f:
            f.write('\n'.join(v))

        print(f"Delay line saved to: {output_path}")
        return output_path

    def generate_verilog(self, selected_mics, output_path="output/delay_module.v"):
        """
        Generate Verilog delay module that uses delay_config for delays

        Args:
            selected_mics: List of microphone indices
            output_path: Output Verilog file path

        Returns:
            str: Path to saved Verilog file
        """
        num_mics = len(selected_mics)

        # Find max delay to determine bits
        all_results = self.calculate_delays(selected_mics)
        max_delay = 0
        for result in all_results.values():
            max_delay = max(max_delay, max(result['sample_delays']))
        delay_bits = max(4, int(np.ceil(np.log2(max_delay + 1))))
        total_bits = num_mics * delay_bits

        v = []
        v.append(f"module delay_module #(")
        v.append(f"    parameter DELAY_SELECT = 0,")
        v.append(f"    parameter NUM_CHANNELS = {num_mics}")
        v.append(f")(")
        v.append(f"    input wire clk,")
        v.append(f"    input wire rst,")
        v.append(f"    input wire pcm_valid,")
        v.append(f"    input wire [NUM_CHANNELS*16-1:0] pcm_data,")
        v.append(f"    output wire [NUM_CHANNELS*16-1:0] delayed_pcm_data")
        v.append(f");")
        v.append(f"")
        v.append(f"  // Get delays from config module")
        v.append(f"  wire [{total_bits-1}:0] selected_delays;")
        v.append(f"  ")
        v.append(f"  delay_config #(")
        v.append(f"    .DELAY_SELECT(DELAY_SELECT)")
        v.append(f"  ) config_inst (")
        v.append(f"    .delays(selected_delays)")
        v.append(f"  );")
        v.append(f"")
        v.append(f"  // Generate delay lines")
        v.append(f"  genvar i;")
        v.append(f"  generate")
        v.append(f"    for (i = 0; i < NUM_CHANNELS; i = i + 1) begin : delay_lines")
        v.append(f"      delay_line dl (")
        v.append(f"          .clk(clk),")
        v.append(f"          .rst(rst),")
        v.append(f"          .pcm_valid(pcm_valid),")
        v.append(
            f"          .delay(selected_delays[i*{delay_bits} +: {delay_bits}]),")
        v.append(f"          .pcm_data(pcm_data[i*16 +: 16]),")
        v.append(f"          .delayed_pcm_data(delayed_pcm_data[i*16 +: 16])")
        v.append(f"      );")
        v.append(f"    end")
        v.append(f"  endgenerate")
        v.append(f"")
        v.append(f"endmodule")

        # Save
        Path(output_path).parent.mkdir(parents=True, exist_ok=True)
        with open(output_path, 'w') as f:
            f.write('\n'.join(v))

        print(f"Verilog saved to: {output_path}")
        print(f"  Microphones: {num_mics}")
        print(f"  Delay bits: {delay_bits}")
        return output_path

    def generate_delay_config(self, selected_mics, output_path="output/delay_config.v"):
        """
        Generate Verilog delay config file with packed delays (localparam style)

        Args:
            selected_mics: List of microphone indices
            output_path: Output Verilog file path

        Returns:
            str: Path to saved Verilog file
        """
        all_results = self.calculate_delays(selected_mics)
        mic_ids = selected_mics
        num_mics = len(mic_ids)

        # Find max delay to determine bits needed
        max_delay = 0
        for result in all_results.values():
            max_delay = max(max_delay, max(result['sample_delays']))

        delay_bits = max(4, int(np.ceil(np.log2(max_delay + 1))))
        total_bits = num_mics * delay_bits

        v = []
        v.append(f"module delay_config #(")
        v.append(f"    parameter DELAY_SELECT = 0")
        v.append(f")(")
        v.append(
            f"    output wire [{total_bits-1}:0] delays  // {num_mics} x {delay_bits}-bit delays packed")
        v.append(f");")
        v.append(f"")

        # Generate pack_delays function
        d_inputs = ", ".join([f"d{i}" for i in range(num_mics)])
        v.append(
            f"  // Function to pack {num_mics} {delay_bits}-bit delays into {total_bits} bits")
        v.append(f"  function [{total_bits-1}:0] pack_delays;")

        # Split inputs into multiple lines if many mics
        half = num_mics // 2
        v.append(f"    input [{delay_bits-1}:0] " +
                 ", ".join([f"d{i}" for i in range(half)]) + ";")
        v.append(f"    input [{delay_bits-1}:0] " +
                 ", ".join([f"d{i}" for i in range(half, num_mics)]) + ";")
        v.append(f"    begin")

        # Pack in reverse order (d_n-1 ... d0)
        pack_list = ", ".join([f"d{i}" for i in range(num_mics-1, -1, -1)])
        v.append(f"      pack_delays = {{{pack_list}}};")
        v.append(f"    end")
        v.append(f"  endfunction")
        v.append(f"")

        # Generate header comment showing mic order
        mic_header = "  ".join([f"M{mid}" for mid in mic_ids])
        v.append(
            f"  // Delay configurations for all {num_mics} source directions")
        v.append(f"  // Mics: {mic_header}")

        # Generate DELAY_CONFIG localparams
        for case_idx, source_mic_id in enumerate(mic_ids):
            result = all_results[source_mic_id]
            sample_delays = result['sample_delays']
            delay_str = ",".join([str(d) for d in sample_delays])
            v.append(
                f"  localparam [{total_bits-1}:0] DELAY_CONFIG_{case_idx:<2} = pack_delays({delay_str});  // Source M{source_mic_id}")

        v.append(f"")

        # Generate select logic
        v.append(f"  // Select the appropriate delay configuration")
        v.append(f"  assign delays = ")

        for case_idx in range(num_mics):
            if case_idx < num_mics - 1:
                v.append(
                    f"    (DELAY_SELECT == {case_idx:<2}) ? DELAY_CONFIG_{case_idx:<2} :")
            else:
                v.append(
                    f"    (DELAY_SELECT == {case_idx:<2}) ? DELAY_CONFIG_{case_idx:<2} :")

        v.append(f"    {total_bits}'h0;")
        v.append(f"")
        v.append(f"endmodule")

        Path(output_path).parent.mkdir(parents=True, exist_ok=True)
        with open(output_path, 'w') as f:
            f.write('\n'.join(v))

        print(f"Delay config saved to: {output_path}")
        print(f"  Microphones: {num_mics}")
        print(f"  Max delay: {max_delay} samples ({delay_bits} bits)")
        return output_path

    def generate_delay_tap_lut(self, selected_mics, output_path="output/delay_tap_lut.v"):
        """
        Generate Verilog delay_tap_lut module using $readmemh with distributed ROM.
        Generates both the .v file and the .mem file.

        Args:
            selected_mics: List of microphone indices
            output_path: Output Verilog file path

        Returns:
            str: Path to saved Verilog file
        """
        all_results = self.calculate_delays(selected_mics)
        mic_ids = selected_mics
        num_mics = len(mic_ids)

        # Find max delay
        max_delay = 0
        for result in all_results.values():
            max_delay = max(max_delay, max(result['sample_delays']))

        # ROM size: 64 configs x 64 channels = 4096 entries
        rom_size = 4096

        # Generate .mem file with hex values
        mem_path = output_path.replace('.v', '.mem')
        mem_lines = []

        for config_idx in range(64):
            if config_idx < num_mics:
                source_mic_id = mic_ids[config_idx]
                result = all_results[source_mic_id]
                sample_delays = result['sample_delays']
            else:
                sample_delays = [0] * 64

            for ch_idx in range(64):
                if ch_idx < len(sample_delays):
                    delay_val = int(sample_delays[ch_idx]) & 0xF
                else:
                    delay_val = 0
                mem_lines.append(f"{delay_val:X}")

        # Generate Verilog module
        mem_filename = Path(mem_path).name
        v = []
        v.append(f"module delay_tap_lut (")
        v.append(f"    input wire clk,")
        v.append(f"    input wire [5:0] config_idx,")
        v.append(f"    input wire [5:0] channel_idx,")
        v.append(f"    output reg [3:0] delay_tap")
        v.append(f");")
        v.append(f"")
        v.append(f"    (* rom_style = \"distributed\" *)")
        v.append(f"    reg [3:0] rom [0:{rom_size-1}];")
        v.append(f"")
        v.append(f"    initial begin")
        v.append(f"        $readmemh(\"{mem_filename}\", rom);")
        v.append(f"    end")
        v.append(f"")
        v.append(f"    always @(posedge clk) begin")
        v.append(f"        delay_tap <= rom[{{config_idx, channel_idx}}];")
        v.append(f"    end")
        v.append(f"")
        v.append(f"endmodule")

        # Save files
        Path(output_path).parent.mkdir(parents=True, exist_ok=True)

        with open(output_path, 'w') as f:
            f.write('\n'.join(v))

        with open(mem_path, 'w') as f:
            f.write('\n'.join(mem_lines))

        print(f"Delay tap LUT saved to: {output_path}")
        print(f"Delay tap MEM saved to: {mem_path}")
        print(f"  Configs: {num_mics}")
        print(f"  Channels: {num_mics}")
        print(f"  ROM entries: {rom_size}")
        print(f"  Max delay: {max_delay} samples")
        return output_path

    def generate_delay_bank(self, selected_mics, output_path="output/delay_bank.v"):
        """Generate Verilog delay_bank module that instantiates all delay_modules"""
        num_mics = len(selected_mics)

        v = []
        v.append(f"module delay_bank #(")
        v.append(
            f"    parameter NUM_CONFIGS = {num_mics},   // Number of delay configurations (directions)")
        v.append(
            f"    parameter NUM_CHANNELS = {num_mics}   // Number of microphone channels")
        v.append(f")(")
        v.append(f"    input wire clk,")
        v.append(f"    input wire rst,")
        v.append(f"    input wire pcm_valid,")
        v.append(
            f"    input wire [NUM_CHANNELS*16-1:0] pcm_data,                      // Input: NUM_CHANNELS * 16 bits")
        v.append(
            f"    output wire [NUM_CONFIGS*NUM_CHANNELS*16-1:0] delayed_data      // Output: NUM_CONFIGS * NUM_CHANNELS * 16 bits")
        v.append(f");")
        v.append(f"")
        v.append(f"  // Each delay_module outputs NUM_CHANNELS*16 bits")
        v.append(f"  // Total output = NUM_CONFIGS * NUM_CHANNELS * 16 bits")
        v.append(f"  ")
        v.append(f"  genvar i;")
        v.append(f"  ")
        v.append(f"  generate")
        v.append(f"    for (i = 0; i < NUM_CONFIGS; i = i + 1) begin : gen_delay")
        v.append(f"      delay_module #(")
        v.append(f"          .DELAY_SELECT(i),")
        v.append(f"          .NUM_CHANNELS(NUM_CHANNELS)")
        v.append(f"      ) u_delay (")
        v.append(f"          .clk(clk),")
        v.append(f"          .rst(rst),")
        v.append(f"          .pcm_valid(pcm_valid),")
        v.append(f"          .pcm_data(pcm_data),")
        v.append(
            f"          .delayed_pcm_data(delayed_data[i*NUM_CHANNELS*16 +: NUM_CHANNELS*16])")
        v.append(f"      );")
        v.append(f"    end")
        v.append(f"  endgenerate")
        v.append(f"")
        v.append(f"endmodule")

        Path(output_path).parent.mkdir(parents=True, exist_ok=True)
        with open(output_path, 'w') as f:
            f.write('\n'.join(v))

        print(f"Delay bank saved to: {output_path}")
        return output_path

    def print_delay_matrix(self, selected_mics):
        """Print the delay matrix for verification"""
        all_results = self.calculate_delays(selected_mics)
        mic_ids = selected_mics

        print(f"\nSample Delay Matrix ({len(mic_ids)} mics):")
        print(f"{'Source':<8}", end="")
        for mid in mic_ids:
            print(f"M{mid:<4}", end="")
        print()

        for source_mic_id in mic_ids:
            print(f"M{source_mic_id:<7}", end="")
            delays = all_results[source_mic_id]['sample_delays']
            for d in delays:
                print(f"{d:5d}", end="")
            print()

    def generate_all(self, mics, output_dir="output"):
        """
        Generate all outputs: plot, XDC, and Verilog

        Args:
            mics: List of microphone indices
            output_dir: Output directory

        Returns:
            dict: Paths to all generated files
        """
        Path(output_dir).mkdir(parents=True, exist_ok=True)

        print(f"\n{'='*60}")
        print(f"Generating outputs for {len(mics)} microphones")
        print(f"Microphones: {mics}")
        print(f"{'='*60}\n")

        # Generate plot with SVG background
        plot_path = self.plot_microphones(
            mics,
            save_path=f"{output_dir}/microphone_array.png",
            title=f"Microphone Array - {len(mics)} Selected (Ring 3)"
        )

        # Generate XDC
        xdc_path = self.generate_xdc(mics, f"{output_dir}/ports.xdc")

        # Generate Verilog modules in dependency order:
        # 1. delay_line (base module)
        delay_line_path = self.generate_delay_line(
            mics, f"{output_dir}/delay_line.v")

        # 2. delay_config (delay matrix - function style)
        delay_config_path = self.generate_delay_config(
            mics, f"{output_dir}/delay_config.v")

        # 2b. delay_tap_lut (hex-packed LUT style - better for hardware)
        delay_tap_lut_path = self.generate_delay_tap_lut(
            mics, f"{output_dir}/delay_tap_lut.v")

        # 3. delay_module (uses delay_config and delay_line)
        delay_module_path = self.generate_verilog(
            mics, f"{output_dir}/delay_module.v")

        # 4. delay_bank (instantiates multiple delay_modules)
        delay_bank_path = self.generate_delay_bank(
            mics, f"{output_dir}/delay_bank.v")

        # Print delay matrix
        self.print_delay_matrix(mics)

        print(f"\n{'='*60}")
        print(f"All outputs generated in: {output_dir}/")
        print(f"{'='*60}")

        return {
            'plot': plot_path,
            'xdc': xdc_path,
            'delay_line': delay_line_path,
            'delay_config': delay_config_path,
            'delay_tap_lut': delay_tap_lut_path,
            'delay_module': delay_module_path,
            'delay_bank': delay_bank_path
        }


# Convenience function
def gen(mics):
    """Generate microphone list (for compatibility)"""
    return mics


if __name__ == "__main__":
    # Example: Ring 3 microphones (18 mics)
    # ring3_mics = [18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 34, 35]

    # ring4_mics= [37, 39, 41, 43, 45, 47, 49, 51, 53, 55, 57, 59]
    # all_rings= [i for i in range (38, 60)]
    all_rings = [0, 3, 47, 43, 39, 59, 55, 51]
    # all_rings = [i for i in range(0, 60)]
    # all_rings = [i for i in range(1, 60, 2)]

    # ring3_mics = [18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35]

    tool = MicArrayTool(
        csv_path="positions_with_mcu_pins.csv",
        svg_path="sesenta.svg"
    )

    tool.generate_all(all_rings, output_dir="output")
    # tool.generate_all(ring4_mics, output_dir="output")
