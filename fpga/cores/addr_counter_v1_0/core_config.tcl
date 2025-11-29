set display_name {Address counter}

set core [ipx::current_core]

set_property DISPLAY_NAME $display_name $core
set_property DESCRIPTION $display_name $core

set_property VENDOR {iari} $core
set_property VENDOR_DISPLAY_NAME {void} $core


