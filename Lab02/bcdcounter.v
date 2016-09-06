//-----------------------------------------------------------------------------
// Title         : bcdcounter
// Project       : ECE 491 - Senior Design 1
//-----------------------------------------------------------------------------
// File          : bcdcounter.v
// Author        : John Nestor
// Created       : 03.09.2009
// Last modified : 03.09.2009
//-----------------------------------------------------------------------------
// Description : A radix-10 counter with synchronous reset.
// 
//-----------------------------------------------------------------------------
// Modification history :
// 03.09.2009 : created
//-----------------------------------------------------------------------------

module bcdcounter(clk, reset, enb, Q, carry);
   input        clk, reset, enb;
   output [3:0] Q;
   output 	carry;
   
   reg [3:0] 	Q; // a signal that is assigned a value

   assign 	carry = (Q == 9) & enb;
   
   always @( posedge clk )
     begin
	if (reset) Q <= 0;
	else if (enb) 
	  begin
	     if (carry) Q <= 0;
	     else Q <= Q + 1;
	  end
     end
endmodule

