//-----------------------------------------------------------------------------
// Title         : single_pulser - detects a rising edge and outputs a single pulse
// Project       : ECE 491 - Senior Design I
//-----------------------------------------------------------------------------
// File          : single_pulser.v
// Author        : John Nestor
// Created       : 02.09.2009
// Last modified : 02.09.2009
//-----------------------------------------------------------------------------
// Description :
// This circuit detects a rising edge on the input din.  WHen the rising edge occurs, 
// it outputs a single pulse one clock period in length.  It is based on the
// single pulser circuit described in Prosser & Winkel's book "The Art of Digital Design
//-----------------------------------------------------------------------------
// Modification history :
// 02.09.2009 : created
//-----------------------------------------------------------------------------

module single_pulser(input logic clk, din, output logic d_pulse);
   logic dq1 = 0;
   logic dq2 = 0;

   //clkenb #(.DIVFREQ(9600)) CLKENB(.clk(clk), .reset(rst), .enb(BaudRate));

   logic dtemp = 0;

   always_ff @(posedge clk)
     begin
    if(clk)
    begin
    	//dtemp <= din;
		dq1 <= din;
		dq2 <= dq1;
	end

	// else 
	// begin
	// 	dtemp <= dtemp;
	// 	dq1 <= dq1;
	// 	dq2 <= dq2;
	// end

     end

   //assign d_pulse = dq1 & ~dq2;
   assign d_pulse = dq2;
endmodule // single_pulser
