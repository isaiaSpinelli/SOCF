/*
Copyright (C) 2014 John Leitch (johnleitch@outlook.com)

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/
`timescale 1ns / 1ns

`include "Md5CoreTestMacros.v"

module Md5CoreTest;

reg clk, reset, test_all;
wire valid_out;
reg valid_in = 0;
wire [127:0] footprint_out;
reg [31:0] count = 0;
reg [511:0] chunk;

Md5Core m (
  .clk_i(clk), 
  .rst_i(reset), 
  .en_i(1'b1), 
  .valid_i(valid_in), 
  .wb_i(chunk), 
  .init_val_i('h67452301efcdab8998badcfe10325476),
  .valid_o(valid_out), 
  .footprint_o(footprint_out)
);

initial
  begin
    clk = 0;
    forever #10 clk = !clk;
  end
  
initial
  begin
    reset = 0;
    #5 reset = 1;
    #4 reset = 0;
  end
 
`include "Md5CoreTestCases.v"
    
always @(posedge clk) count <= count + 1;
always @(posedge clk) if (count == `DoneCount) test_all <= `TestAllExp;
    
endmodule  

 

