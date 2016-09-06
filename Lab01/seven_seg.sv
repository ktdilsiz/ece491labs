//-----------------------------------------------------------------------------
// Title         : Seven segment decoder
// Project       : ECE 491 - Senior Design Project 1
//-----------------------------------------------------------------------------
// File          : seven_seg.sv
// Author        : John Nestor  <johnnest@localhost>
// Created       : 21.08.2006
// Last modified : 22.07.2016
//-----------------------------------------------------------------------------
// Description
// BCD Seven Segement decoder adapted from David Harris' Verilog tutorial
// Outputs are active low.  Segments have been modified to follow the
// bit ordering of the Nexsys2 board segments[6]=g, segments[0]=a
//
//-----------------------------------------------------------------------------

module seven_seg(
		 input logic [3:0]  data,
		 output logic [6:0] segments  // ordered g(6) - a(0)
		 );
   
   // Output patterns:  gfe_dcba
   parameter BLANK = 7'b111_1111;
   parameter ZERO  = 7'b100_0000;
   parameter ONE   = 7'b111_1001;
   parameter TWO   = 7'b010_0100;
   parameter THREE = 7'b011_0000;
   parameter FOUR  = 7'b001_1001;
   parameter FIVE  = 7'b001_0010;
   parameter SIX   = 7'b000_0010;
   parameter SEVEN = 7'b111_1000;
   parameter EIGHT = 7'b000_0000;
   parameter NINE  = 7'b001_0000;
   
   always_comb
     case (data)
       4'd0: segments = ZERO;
       4'd1: segments = ONE;
       4'd2: segments = TWO;
       4'd3: segments = THREE;
       4'd4: segments = FOUR;
       4'd5: segments = FIVE;
       4'd6: segments = SIX;
       4'd7: segments = SEVEN;
       4'd8: segments = EIGHT;
       4'd9: segments = NINE;
       default: segments = BLANK;
     endcase
endmodule
