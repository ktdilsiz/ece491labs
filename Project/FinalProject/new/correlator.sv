`timescale 1ns / 1ps
//-----------------------------------------------------------------------------
// Title         : Correlator
// Project       : ECE 491 Senior Design 1
//-----------------------------------------------------------------------------
// File          : correlator.sv
// Author        : John Nestor  <nestorj@nestorj-mbpro-15>
// Created       : 22.09.2016
// Last modified : 22.09.2016
//-----------------------------------------------------------------------------
// Description :
// Inputs a sequence of bits on d_in and computes the number matching bits a sequence
// of LEN most recent bits with a PATTERN of the same length.
// Asserts h_out true when the number of matching bits equals or exceeds
// threshold value HTHRESH.
// Asserts l_out true when the number of matching equals or is less than LTHRESH.
//-----------------------------------------------------------------------------
// Modification history :
// 22.09.2016 : created
//-----------------------------------------------------------------------------



module correlator #(parameter LEN=16, PATTERN=16'b0000000011111111, HTHRESH=13, LTHRESH=3, W=$clog2(LEN)+1)
          (
	      input logic 	   clk,
	      input logic 	   reset,
	      input logic 	   enb,
	      input logic 	   d_in,
        input logic [LEN-1:0]replace,
	      output logic [W-1:0] csum,
	      output logic 	   h_out,  
	      output logic 	   l_out
	      );


   logic [LEN-1:0] 		   shreg, match;
   

   // shift register shifts from right to left so that oldest data is on
   // the left and newest data is on the right
   always_ff  @(posedge clk)
   begin
     if (reset) shreg <= 16'b0000000000000000;
     else if (replace == 8'b10101010)
      begin
          shreg <= replace;
      end
     else if (enb) shreg <= { shreg[LEN-2:0], d_in };

    end
   
   assign match = shreg ^ ~PATTERN;

   assign csum = countones(match);
   //assign csum = match[0] + match[1] + match[2] + match[3] + match[4] + match[5] + match[6] + match[7] + match[8];

   assign h_out = csum >= HTHRESH;
   
   assign l_out = csum <= LTHRESH;

   function logic [W-1:0] countones (logic [LEN-1:0] a); 

    integer i;
    logic [W-1:0] y;

      y = 0;
      for (i=0; i<LEN; i++)
        //y = y + a[i];
        begin
        if(a[i] == 1'b1) y = y + 1'b1;
        end

    return y;
    
  endfunction

endmodule


			       