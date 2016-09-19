//-----------------------------------------------------------------------------
// Title         : clkenb - parameterized clock enable generator
// Project       : ECE 491 - Senior Design 1
//-----------------------------------------------------------------------------
// File          : clkenb.sv
// Author        : John Nestor
// Created       : 08.14.2015
// Last modified : 07.22.2015n
//-----------------------------------------------------------------------------
// Description :
// This module divides the 100MHz clock on the Nexys3DDR board down to a lower
// frequency and outputs an enable pulse at that clock frequency.  Note that
// this circuit is NOT a clock divider but is intended to enable logic connected 
// to the system clock to perform a periodic fcn.  
// To use, instantaite with the DIVFREQ parameter set to the desired frequency in Hz.
// DO NOT CONNECT THE ENB OUTPUT OF THIS TO MODULE TO A CLOCKED INPUT!
//
//-----------------------------------------------------------------------------

module clkenb(input logic clk, reset, output logic enb);
   parameter DIVFREQ = 100;  // desired frequency in Hz (change as needed)
   parameter CLKFREQ = 100_000_000;
   parameter DIVAMT = (CLKFREQ / DIVFREQ);
   parameter DIVBITS = $clog2(DIVAMT);   // enough bits to represent DIVAMT
   
   logic [DIVBITS-1:0] q;
   
   always @(posedge clk)
     if (reset)
       begin
	  q <= 0;
	  enb <= 0;
       end
     else if (q == DIVAMT-1)
       begin
	  q <= 0;
	  enb <= 1;  // note it will be delayed by 1 clock, but so what?
       end
     else
       begin
	  q <= q + 1;
	  enb <= 0;
       end
   
endmodule // clken



   
  