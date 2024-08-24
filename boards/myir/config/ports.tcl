
### LED
# create_bd_port -dir O M1_CLK
# create_bd_port -dir O M2_CLK
# create_bd_port -dir O M0_CLK
# create_bd_port -dir I M0_DATA
# create_bd_port -dir I M1_DATA
# create_bd_port -dir I M2_DATA
# create_bd_port -dir I M4_DATA
# create_bd_port -dir I M6_DATA
# create_bd_port -dir I M8_DATA
# create_bd_port -dir I M10_DATA
# create_bd_port -dir I M12_DATA

# create_bd_port -dir I M14_DATA
# create_bd_port -dir I M16_DATA
# create_bd_port -dir I M18_DATA
# create_bd_port -dir I M20_DATA
# create_bd_port -dir I M22_DATA
# create_bd_port -dir I M24_DATA
# create_bd_port -dir I M26_DATA
# create_bd_port -dir I M28_DATA
# create_bd_port -dir I M30_DATA
# create_bd_port -dir I M32_DATA
# create_bd_port -dir I M34_DATA
# create_bd_port -dir I M36_DATA
# create_bd_port -dir I M38_DATA
# create_bd_port -dir I M40_DATA
# create_bd_port -dir I M42_DATA
# create_bd_port -dir I M44_DATA
# create_bd_port -dir I M46_DATA
# create_bd_port -dir I M48_DATA
# create_bd_port -dir I M50_DATA
# create_bd_port -dir I M52_DATA
# create_bd_port -dir I M54_DATA
# create_bd_port -dir I M56_DATA
# create_bd_port -dir I M58_DATA


create_bd_port -dir O -from 31 -to 0 trig1
create_bd_port -dir O -from 31 -to 0 trig0
create_bd_port -dir I -from 31 -to 0 addrb
create_bd_port -dir I -from 31 -to 0 dinb1
create_bd_port -dir I -from 31 -to 0 dinb2
create_bd_port -dir I -from 31 -to 0 dinb3
create_bd_port -dir I -from 31 -to 0 dinb4
create_bd_port -dir I -from 31 -to 0 dinb5
create_bd_port -dir I -from 31 -to 0 dinb6
create_bd_port -dir I -from 31 -to 0 dinb7
create_bd_port -dir I -from 31 -to 0 dinb8
create_bd_port -dir I -from 3 -to 0 web
create_bd_port -dir O peripheral_aresetn
create_bd_port -dir O FCLK_CLK0