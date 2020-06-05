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
`define Stages 65

`define TestCase(__number, __passed, __a, __b, __c, __d, __chunk)                           \
reg __passed;                                                                               \
always @(posedge clk)                                                                       \
  begin                                                                                     \
    chunk = 0;                                                                              \
    valid_in = 1'b0;                                                                        \
    if (count == __number)                                                                  \
      begin                                                                                 \
        chunk <= __chunk;                                                                   \
        valid_in <= 1'b1;                                                                   \
      end                                                                                   \
                                                                                            \
    if (count == __number + `Stages)                                                        \
      __passed <=                                                                           \
        footprint_out[127:96] + 'h67452301 == __a &&                                        \
        footprint_out[95:64]  + 'hefcdab89 == __b &&                                        \
        footprint_out[63:32]  + 'h98badcfe == __c &&                                        \
        footprint_out[31:0]   + 'h10325476 == __d;                                          \
  end                                                                                       \
  
  
