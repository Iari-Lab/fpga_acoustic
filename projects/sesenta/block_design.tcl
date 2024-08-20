# required TCL dependencies
source $board_path/config/ports.tcl
source $board_path/base_system.tcl
source $sdk_path/fpga/lib/bram.tcl
connect_port_pin led [get_slice_pin [ctl_pin led] 0 0]



create_ip -name cic_compiler -vendor xilinx.com -library ip -version 4.0 -module_name cic_compiler_0

# Set properties of the cic_compiler_0 IP core
set_property -dict [
    list \
        CONFIG.Filter_Type {Decimation} \
        CONFIG.Number_Of_Stages {5} \
        CONFIG.Sample_Rate_Changes {Fixed} \
        CONFIG.RateSpecification {Frequency Specification} \
        CONFIG.Fixed_Or_Initial_Rate {64} \
        CONFIG.Minimum_Rate {64} \
        CONFIG.Maximum_Rate {64} \
        CONFIG.Input_Sample_Frequency {2.4} \
        CONFIG.Clock_Frequency {125.0} \
        CONFIG.SamplePeriod {1} \
        CONFIG.Output_Data_Width {32} \
        CONFIG.Input_Data_Width {2} \
        CONFIG.Quantization {Full Precision}
] \
[get_ips cic_compiler_0]

generate_target all [get_ips cic_compiler_0]
update_ip_catalog

# Get the list of all IPs in the project
set ip_list [get_ips *]
set cic_xci ""

# Loop through the IPs
foreach ip $ip_list {
    # If the IP name matches "IQ_Multiplier", store the IP definition file (.xci file) in a variable
    puts [get_property NAME $ip]
    if {[get_property NAME $ip] eq "cic_compiler_0"} {
        set cic_xci [get_property IP_FILE $ip]
        puts [get_property IP_FILE $ip]
    }
}
puts $cic_xci
report_property [get_ips cic_compiler_0]
set_property GENERATE_SYNTH_CHECKPOINT false [get_files $cic_xci]
set_property IS_GLOBAL_INCLUDE	true  [get_files $cic_xci]

generate_target all [get_ips cic_compiler_0]

update_ip_catalog

add_bram mic

# Add a counter for BRAM addressing
cell koheron:user:address_counter:1.0 address_counter_0 {
  COUNT_WIDTH [get_memory_addr_width mic]
} {
  rst [get_slice_pin [ctl_pin trig0] 0 0]
  clk $eclk
}
cell sesenta:user:pdm_mic:1.0 mic_0 {} {
    clk $eclk
    rst [get_slice_pin [ctl_pin trig1] 0 0]
    M_DATA M1_DATA
}

cell sesenta:user:buffer:1.0 buff_0 {
} {
    clk $eclk
    input_signal2 mic_0/M_CLK
    input_signal1 mic_0/mic_data
    output_signal2 M1_CLK
}


cell xilinx.com:ip:system_ila:1.1 sila_2 {
    C_PROBE0_WIDTH 32 
    C_PROBE1_WIDTH 1
    C_PROBE2_WIDTH 32 
    C_PROBE3_WIDTH 4
    C_DATA_DEPTH 4096
    C_NUM_OF_PROBES 4
    C_EN_STRG_QUAL 1 
    C_ADV_TRIGGER true
    ALL_PROBE_SAME_MU_CNT 2 
    C_MON_TYPE NATIVE 
    C_PROBE_WIDTH_PROPAGATION MANUAL 
} {
    clk $ps_name/FCLK_CLK0
    probe0 buff_0/output_signal3
    probe1 buff_0/output_signal4
    probe2 address_counter_0/address_dbg
    probe3 address_counter_0/wen_dbg
}

connect_cell blk_mem_gen_mic {
  addrb address_counter_0/address
  clkb $eclk
  dinb buff_0/output_signal1
  enb [get_constant_pin 1 1]
  rstb [get_constant_pin 0 1]
  web address_counter_0/wen
}