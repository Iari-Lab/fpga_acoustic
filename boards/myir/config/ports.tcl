
# create_bd_port -dir O -from 31 -to 0 rst_regs
# create_bd_port -dir I -from 511 -to 0 mics
# create_bd_port -dir I -from 511 -to 0 mics2


# Parameters
set NUM_CHANNELS 60
set BITS_PER_CHANNEL 17
set NUM_CONFIGS 60

# Calculate width (NUM_CONFIGS * NUM_CHANNELS * BITS_PER_CHANNEL - 1)
set port_width [expr { $NUM_CHANNELS * $BITS_PER_CHANNEL - 1}]
# set port_width [expr {$NUM_CONFIGS * $NUM_CHANNELS * $BITS_PER_CHANNEL - 1}]

# Create port
create_bd_port -dir I -from $port_width -to 0 mics
# create_bd_port -dir I -from $NUM_CONFIGS -to 0 beam_valid
# create_bd_port -dir I -from 630 -to 0 mics
# create_bd_port -dir I -from 255 -to 0 mics2
# create_bd_port -dir I -from 255 -to 0 mics
# create_bd_port -dir I mics_data_valid
create_bd_port -dir I beam_valid
create_bd_port -dir O reset
create_bd_port -dir O -from 7 -to 0 led_sel
create_bd_port -dir O FCLK_CLK0
create_bd_port -dir O start
# create_bd_port -dir O FCLK_CLK1