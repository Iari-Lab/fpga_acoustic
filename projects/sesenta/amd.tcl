# Global flag to enable or disable ILA-related commands
set enable_ila 1
set enable_cic 0

# Create the CIC Compiler IP
if {$enable_cic} {
create_ip -name cic_compiler -vendor xilinx.com -library ip -version 4.0 -module_name cic_compiler_0
}

# Create the ILA IP only if enabled
if {$enable_ila} {
    create_ip -name ila -vendor xilinx.com -library ip -version 6.2 -module_name ila_0
    # create_ip -name ila -vendor xilinx.com -library ip -version 6.2 -module_name ila_1
}

if {$enable_cic} {
# Set properties for cic_compiler_0
set_property -dict [list \
    CONFIG.Filter_Type {Decimation} \
    CONFIG.Number_Of_Stages {5} \
    CONFIG.Fixed_Or_Initial_Rate {64} \
    CONFIG.Input_Sample_Frequency {3.072} \
    CONFIG.Clock_Frequency {125.0} \
    CONFIG.Minimum_Rate {4} \
    CONFIG.Maximum_Rate {512} \
    CONFIG.Response_Magnitude {Full_Precision} \
    CONFIG.Quantization {Truncation} \
    CONFIG.Input_Data_Width {2} \
    CONFIG.Sample_Rate_Changes {Programmable} \
    CONFIG.Input_Sample_Frequency {3.072} \
    CONFIG.Clock_Frequency {125.0} \
    CONFIG.SamplePeriod {1} \
    CONFIG.Stopband_Min {0.38} \
    CONFIG.Passband_Max {0.38} \
    CONFIG.Stopband_Max {1.0} \
    CONFIG.Output_Data_Width {32} \
] [get_ips cic_compiler_0]

}
# Only configure ILA if enabled
if {$enable_ila} {
#  set_property -dict [ list \
#         CONFIG.C_NUM_OF_PROBES {10} \
#         CONFIG.C_PROBE0_WIDTH {1} \
#         CONFIG.C_PROBE1_WIDTH {1} \
#         CONFIG.C_PROBE2_WIDTH {32} \
#         CONFIG.C_PROBE3_WIDTH {32} \
#         CONFIG.C_PROBE4_WIDTH {32} \
#         CONFIG.C_PROBE5_WIDTH {32} \
#         CONFIG.C_PROBE6_WIDTH {32} \
#         CONFIG.C_PROBE7_WIDTH {32} \
#         CONFIG.C_PROBE8_WIDTH {32} \
#         CONFIG.C_PROBE9_WIDTH {32} \
#         CONFIG.C_DATA_DEPTH {16384}  \
#         CONFIG.C_EN_STRG_QUAL {1} \
#         CONFIG.C_ADV_TRIGGER {true} \
#         CONFIG.ALL_PROBE_SAME_MU_CNT {2} \
#     ] [get_ips ila_0]
    # set_property -dict [ list \
    #     CONFIG.C_NUM_OF_PROBES {1} \
    #     CONFIG.C_PROBE0_WIDTH {21} \
    #     CONFIG.C_DATA_DEPTH {8192}  \
    #     CONFIG.C_EN_STRG_QUAL {1} \
    #     CONFIG.C_ADV_TRIGGER {true} \
    #     CONFIG.ALL_PROBE_SAME_MU_CNT {2} \
    # ] [get_ips ila_1]

    set_property -dict [ list \
        CONFIG.C_NUM_OF_PROBES {3} \
        CONFIG.C_PROBE0_WIDTH {8} \
        CONFIG.C_PROBE1_WIDTH {32} \
        CONFIG.C_PROBE2_WIDTH {1} \
        CONFIG.C_DATA_DEPTH {16384}  \
        CONFIG.C_EN_STRG_QUAL {1} \
        CONFIG.C_ADV_TRIGGER {true} \
        CONFIG.ALL_PROBE_SAME_MU_CNT {2} \
    ] [get_ips ila_0]
}

# # Generate targets for CIC Compiler
# generate_target all [get_ips cic_compiler_0]
# update_ip_catalog

# Get the list of all IPs in the project
set ip_list [get_ips *]
set cic_xci ""
set ila_xci ""
set ila_xci1 ""
# Loop through the IPs
foreach ip $ip_list {
    puts [get_property NAME $ip]
    if {[get_property NAME $ip] eq "cic_compiler_0"} {
        set cic_xci [get_property IP_FILE $ip]
        puts [get_property IP_FILE $ip]
    }
    if {[get_property NAME $ip] eq "ila_0"} {
        set ila_xci [get_property IP_FILE $ip]
        puts [get_property IP_FILE $ip]
    }
    if {[get_property NAME $ip] eq "ila_1"} {
        set ila_xci1 [get_property IP_FILE $ip]
        puts [get_property IP_FILE $ip]
    }
}

if {$enable_ila} {
    puts $ila_xci
    puts $ila_xci1
    report_property [get_ips ila_0]
    set_property GENERATE_SYNTH_CHECKPOINT false [get_files $ila_xci]
    set_property IS_GLOBAL_INCLUDE true [get_files $ila_xci]

    # report_property [get_ips ila_1]
    # set_property GENERATE_SYNTH_CHECKPOINT false [get_files $ila_xci1]
    # set_property IS_GLOBAL_INCLUDE true [get_files $ila_xci1]
}

if {$enable_cic} {
    puts $cic_xci
    report_property [get_ips cic_compiler_0]
    set_property GENERATE_SYNTH_CHECKPOINT false [get_files $cic_xci]
    set_property IS_GLOBAL_INCLUDE true [get_files $cic_xci]
}

if {$enable_cic} {
    generate_target all [get_ips cic_compiler_0]
}
if {$enable_ila} {
    generate_target all [get_ips ila_0]
    # generate_target all [get_ips ila_1]
}
update_ip_catalog

# Set properties of the cic_compiler_0 IP core
# set_property -dict [
#     list \
#         CONFIG.Filter_Type {Decimation} \
#         CONFIG.Number_Of_Stages {5} \
#         CONFIG.Sample_Rate_Changes {Fixed} \
#         CONFIG.RateSpecification {Frequency Specification} \
#         CONFIG.Fixed_Or_Initial_Rate {64} \
#         CONFIG.Minimum_Rate {64} \
#         CONFIG.Maximum_Rate {64} \
#         CONFIG.Input_Sample_Frequency {2.4} \
#         CONFIG.Clock_Frequency {125.0} \
#         CONFIG.SamplePeriod {1} \
#         CONFIG.Output_Data_Width {32} \
#         CONFIG.Input_Data_Width {2} \
#         CONFIG.Quantization {Full Precision}
    
# ] \
# [get_ips cic_compiler_0]
# set_property -dict [list \
#     CONFIG.Filter_Type {Decimation} \
#     CONFIG.Number_Of_Stages {5} \
#     CONFIG.Fixed_Or_Initial_Rate {64} \
#     CONFIG.Input_Sample_Frequency {3.072} \
#     CONFIG.Clock_Frequency {125.0} \
#     CONFIG.Minimum_Rate {4} \
#     CONFIG.Maximum_Rate {512} \
#     CONFIG.Response_Magnitude {Full_Precision} \
#     CONFIG.Quantization {Truncation} \
#     CONFIG.Input_Data_Width {2} \
#     CONFIG.Sample_Rate_Changes {Programmable} \
#     CONFIG.Input_Sample_Frequency {3.072} \
#     CONFIG.Clock_Frequency {125.0} \
#     CONFIG.SamplePeriod {1} \
#     CONFIG.Stopband_Min {0.38} \
#     CONFIG.Passband_Max {0.38} \
#     CONFIG.Stopband_Max {1.0} \
#     CONFIG.Output_Data_Width {28} \
# ] [get_ips cic_compiler_0]

# set_property -dict [list \
#     CONFIG.Filter_Type {Decimation} \
#     CONFIG.Number_Of_Stages {5} \
#     CONFIG.Fixed_Or_Initial_Rate {64} \
#     CONFIG.Input_Sample_Frequency {3.072} \
#     CONFIG.Clock_Frequency {125.0} \
#     CONFIG.Response_Magnitude {Full_Precision} \
#     CONFIG.Stopband_Min {0.2} \
#     CONFIG.Passband_Max {0.2} \
#     CONFIG.Stopband_Max {0.7} \
#     CONFIG.Input_Data_Width {2} \
#     CONFIG.Minimum_Rate {64} \
#     CONFIG.Maximum_Rate {64} \
#     CONFIG.Input_Sample_Frequency {3.072} \
#     CONFIG.Clock_Frequency {125.0} \
#     CONFIG.SamplePeriod {1} \
#     CONFIG.Output_Data_Width {32} \
# ] [get_ips cic_compiler_0]