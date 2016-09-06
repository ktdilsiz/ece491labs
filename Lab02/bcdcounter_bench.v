//-----------------------------------------------------------------------------
// Title         : bcdcounter_bench - stimulus-only testbench for BCD Counter
// Project       : ECE 491 - Senior Design I
//-----------------------------------------------------------------------------
// File          : bcdcounter_bench.v
// Author        : John Nestor
// Created       : 03.09.2009
// Last modified : 03.09.2009
//-----------------------------------------------------------------------------
// Description :
// This file provides stimulus input to verify the operation of the BCD counter.
// It uses an always block to generate a clock signal and an initial block to
// provide input stimulus.  Note that the code in the initial block uses the
// delay operator "#" to delay by a fixed number of time units and the
// @(posedge clk); statement to delay until the next clock edge.
//
// This testbench only generates stimulus - it is up to the user to verify that
// the resulting simulation waveform is correct.
//-----------------------------------------------------------------------------
// Modification history :
// 03.09.2009 : created
//-----------------------------------------------------------------------------

module bcdcounter_bench;

  // signals for connecting the counter
   reg        clk;
   reg        reset;
   reg        enb;
   wire [3:0] Q;
   wire       carry;
   
   // testbench variables;
   integer    i;
   
   // instantiate device under verification (counter)
   bcdcounter DUV(.clk(clk),.reset(reset),.enb(enb),
                  .Q(Q),.carry(carry));

  // clock generator with period=20 time units
  always
     begin
	clk = 0;
	#10 clk = 1;
	#10 ;
     end


   // initial block generates stimulus
   initial begin
      reset = 0;
      enb = 0;
      @(posedge clk);
      // do a reset and check that it worked
      reset = 1;
      @(posedge clk);
      
      #1 reset = 0;  // reset and count through complete sequence
      #1 enb = 1;
      repeat(14) @(posedge clk);
      #1 enb = 0;
      repeat(2) @(posedge clk);
      #1 enb = 1;
      repeat(4) @(posedge clk);
      #1 reset = 1;  // show reset on partially complete count
      @(posedge clk);
      #1 reset = 0;
      repeat(5) @(posedge clk);
      $stop();  // all done - suspend simulation
   end // initial
endmodule    

