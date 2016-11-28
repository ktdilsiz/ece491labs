//-----------------------------------------------------------------------------
// Title         : 8-Bit Dallas/Maxim CRC
// Project       : ECE 491
//-----------------------------------------------------------------------------
// File          : crc.v
// Author        : John Nestor
// Created       : 03.11.2006
// Last modified : 03.11.2006
//-----------------------------------------------------------------------------
// Description : Peforms an 8-bit CRC using the polynomial
//    x^8 + x^5 + x^4 + 1
// Source: Dallas/Maxim 1-Wire bus interface
//-----------------------------------------------------------------------------
// Modification history :
// 03.11.2006 : created
//-----------------------------------------------------------------------------

module crc(clk, rst, d, x);
   input clk, rst, d;
   output [8:1] x;
   reg [8:1] 	x;
   
   wire 	x0;
   
   assign 	x0 = x[8] ^ d;
   
   always @(posedge clk)
     begin
	if (rst) x <= 8'd0;
	else
          begin
             x[8] <= x[7];
             x[7] <= x[6];
             x[6] <= x[5] ^ x0;
             x[5] <= x[4] ^ x0;
             x[4] <= x[3];
             x[3] <= x[2];
             x[2] <= x[1];
             x[1] <= x0;
          end
     end
   
endmodule
