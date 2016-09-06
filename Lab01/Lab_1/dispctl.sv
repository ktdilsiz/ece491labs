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

   logic 			enb; 
   logic            [7:0] y;
   logic            [3:0] charles;
   logic            [2:0] q;
   logic            [7:0] an_n;
   
   clkenb #(.DIVFREQ(1000)) U_CLKENB(clk,reset, enb);
   
   counter_parm #(.W(3)) COUNTER(.clk(clk),.reset(reset),.enb(enb),.q(q),.carry());
   
   decoder_3_8_en DECODE(.a(q),.enb(1),.y(an_n));
   
   mux8_parm #(.W(4)) MUX1(.d0(d0),.d1(d1),.d2(d2),.d3(d3),.d4(d4),.d5(d5),.d6(d6),.d7(d7),.sel(q),.y(charles));
   
   mux8_parm #(.W(1)) MUX2(.d0(dp0),.d1(dp1),.d2(dp2),.d3(dp3),.d4(dp4),.d5(dp5),.d6(dp6),.d7(dp7),.sel(q),.y(dp));
   
   seven_seg SEG(.data(charles),.segments(seg));
   
   //d is 5 bits, same as switch 
   //reg_parm  REGPARAMS(.clk(clk), .reset(reset), .Iden(), .d(), .q());
   
   assign an[7:0] = ~an_n; 
  // assign enb = 1;

endmodule // dispctl

   