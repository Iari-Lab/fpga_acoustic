# list CONFIG.Number_Of_Channels {64} CONFIG.Input_Sample_Frequency {2.4} CONFIG.Clock_Frequency {153.6000000}
# list CONFIG.Number_Of_Channels {64} CONFIG.Input_Sample_Frequency {2.4} CONFIG.Clock_Frequency {153.6000000}

# list CONFIG.Number_Of_Channels {64} CONFIG.Input_Sample_Frequency {2.4} CONFIG.Clock_Frequency {153.6000000}
create_ip -name cic_compiler -vendor xilinx.com -library ip -version 4.0 -module_name cic_compiler_0
create_ip -name ila -vendor xilinx.com -library ip -version 6.2 -module_name ila_0
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

set_property -dict [ list \
    CONFIG.C_NUM_OF_PROBES {10} \
    CONFIG.C_PROBE0_WIDTH {1} \
    CONFIG.C_PROBE1_WIDTH {32} \
    CONFIG.C_PROBE2_WIDTH {32} \
    CONFIG.C_PROBE3_WIDTH {32} \
    CONFIG.C_PROBE4_WIDTH {32} \
    CONFIG.C_PROBE5_WIDTH {32} \
    CONFIG.C_PROBE6_WIDTH {32} \
    CONFIG.C_PROBE7_WIDTH {32} \
    CONFIG.C_PROBE8_WIDTH {32} \
    CONFIG.C_PROBE9_WIDTH {32} \
    CONFIG.C_DATA_DEPTH {8192}  \
    CONFIG.C_EN_STRG_QUAL {1} \
    CONFIG.C_ADV_TRIGGER {true} \
    CONFIG.ALL_PROBE_SAME_MU_CNT {2}
    ] \  [get_ips ila_0]

generate_target all [get_ips cic_compiler_0]
update_ip_catalog

# Get the list of all IPs in the project
set ip_list [get_ips *]
set cic_xci ""
set ila_xci ""
# Loop through the IPs
foreach ip $ip_list {
    # If the IP name matches "IQ_Multiplier", store the IP definition file (.xci file) in a variable
    puts [get_property NAME $ip]
    if {[get_property NAME $ip] eq "cic_compiler_0"} {
        set cic_xci [get_property IP_FILE $ip]
        puts [get_property IP_FILE $ip]
    }
    if {[get_property NAME $ip] eq "ila_0"} {
        set ila_xci [get_property IP_FILE $ip]
        puts [get_property IP_FILE $ip]
    }
}
puts $ila_xci
report_property [get_ips ila_0]
set_property GENERATE_SYNTH_CHECKPOINT false [get_files $ila_xci]
set_property IS_GLOBAL_INCLUDE	true  [get_files $ila_xci]
puts $cic_xci
report_property [get_ips cic_compiler_0]
set_property GENERATE_SYNTH_CHECKPOINT false [get_files $cic_xci]
set_property IS_GLOBAL_INCLUDE	true  [get_files $cic_xci]

generate_target all [get_ips cic_compiler_0]
generate_target all [get_ips ila_0]
update_ip_catalog
