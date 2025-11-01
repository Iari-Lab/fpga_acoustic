
# create_bd_port -dir O -from 31 -to 0 rst_regs
# create_bd_port -dir I -from 511 -to 0 mics
# create_bd_port -dir I -from 511 -to 0 mics2

create_bd_port -dir I -from 255 -to 0 mics
create_bd_port -dir I -from 255 -to 0 mics2
# create_bd_port -dir I -from 255 -to 0 mics
create_bd_port -dir I mics_data_valid
create_bd_port -dir O reset
create_bd_port -dir O -from 6 -to 0 mic_sel
create_bd_port -dir O FCLK_CLK0
# create_bd_port -dir O FCLK_CLK1