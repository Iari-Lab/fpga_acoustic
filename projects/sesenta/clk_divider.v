(* \amaranth.hierarchy  = "dmic_cic.clk_divider" *)
(* generator = "Amaranth" *)
module clk_divider(clock_out, rst, clk, clock_enable_in);
  reg \$auto$verilog_backend.cc:2184:dump_module$33  = 0;
  wire \$1 ;
  wire \$3 ;
  wire \$5 ;
  wire [5:0] \$7 ;
  wire [5:0] \$8 ;
  input clk;
  wire clk;
  reg [4:0] clock_counter = 5'h00;
  reg [4:0] \clock_counter$next ;
  input clock_enable_in;
  wire clock_enable_in;
  output clock_out;
  reg clock_out = 1'h0;
  reg \clock_out$next ;
  input rst;
  wire rst;
  assign \$1  = clock_counter >= 5'h13;
  assign \$3  = ~ clock_out;
  assign \$5  = clock_counter >= 5'h13;
  assign \$8  = clock_counter + 1'h1;
  always @(posedge clk)
    clock_counter <= \clock_counter$next ;
  always @(posedge clk)
    clock_out <= \clock_out$next ;
  always @* begin
    if (\$auto$verilog_backend.cc:2184:dump_module$33 ) begin end
    \clock_out$next  = clock_out;
    casez (\$1 )
      /* src = "/home/tucanae47/gitprojects/V122/python/mic_characterization/test/clockdivider.py:20" */
      1'h1:
          (* full_case = 32'd1 *)
          casez (clock_enable_in)
            /* src = "/home/tucanae47/gitprojects/V122/python/mic_characterization/test/clockdivider.py:21" */
            1'h1:
                \clock_out$next  = \$3 ;
            /* src = "/home/tucanae47/gitprojects/V122/python/mic_characterization/test/clockdivider.py:23" */
            default:
                \clock_out$next  = 1'h0;
          endcase
    endcase
    casez (rst)
      1'h1:
          \clock_out$next  = 1'h0;
    endcase
  end
  always @* begin
    if (\$auto$verilog_backend.cc:2184:dump_module$33 ) begin end
    (* full_case = 32'd1 *)
    casez (\$5 )
      /* src = "/home/tucanae47/gitprojects/V122/python/mic_characterization/test/clockdivider.py:20" */
      1'h1:
          \clock_counter$next  = 5'h00;
      /* src = "/home/tucanae47/gitprojects/V122/python/mic_characterization/test/clockdivider.py:28" */
      default:
          \clock_counter$next  = \$8 [4:0];
    endcase
    casez (rst)
      1'h1:
          \clock_counter$next  = 5'h00;
    endcase
  end
  assign \$7  = \$8 ;
endmodule