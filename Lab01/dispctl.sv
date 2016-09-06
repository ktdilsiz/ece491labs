//-----------------------------------------------------------------------------
// Title         : 7-Segment Display Controller
// Project       : ECE 491 - Senior Design Project 1
//-----------------------------------------------------------------------------
// File          : dispctl.sv
// Author        : John Nestor
// Created       : 08.08.2011
// Last modified : 07.22.2015
//-----------------------------------------------------------------------------
// Description :
// Control circuit that handles time-multiplexing of eight different 4-bit binary
// inputs to the time-multiplexed seven-segment display on the Nexys4DDR board.
// Output seg[6:0] connects to the seven-segment output to the display, while
// output an[7:0] enables whichever digits are held low.  This circuit must be
// clocked at a relatively low frequency for the time-multiplexing to work
// properly.
//-----------------------------------------------------------------------------
// Modification history :
// 08.08.2011 : created (original Verilog version)
// 07.22.2015 : ported to SystemVerilog and expanded to 8 digits for nexys4ddr
//-----------------------------------------------------------------------------

module dispctl (
		input logic 	   clk,
		input logic 	   reset,
		input logic [3:0]  d7, d6, d5, d4, d3, d2, d1, d0,
		input logic 	   dp7, dp6, dp5, dp4, dp3, dp2, dp1, dp0,
		output logic [6:0] seg,
		output logic dp,
		output logic [7:0] an
		);

   // generate clock enable to drive time-multiplexing counter
   // (you may need to adjust the frequency!)

   logic 			   enb;

   clkenb #(.DIVFREQ(1000)) U_CLKENB(clk, enb);



endmodule // dispctl

   