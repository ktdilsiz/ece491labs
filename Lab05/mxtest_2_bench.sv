`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: Lafayette College
// Engineer: John Nestor
//
// Create Date:   14:00:36 09/16/2016
// Design Name:   mxtest
// Module Name:   C:/mxtest_new/mxtest_bench.v
// Project Name:  mxtest_new
// Target Device:  
// Tool versions:  
// Description: 
//
// SystemVerilog stimulus-only testbench for mxtest_2
//
// 
////////////////////////////////////////////////////////////////////////////////

module mxtest_bench;

	// Inputs
	logic clk;
	logic reset;
	logic run;
	logic ready;
	logic [5:0] length;

	// Outputs
	logic send;
	logic [7:0] data;
	logic txen;
	logic txd;

    assign length = 15;
    
	// Instantiate the Unit Under Test (UUT)
	mxtest_2 #(.WAIT_TIME(50)) U_MXTEST (
		.clk(clk), 
		.reset(reset), 
		.run(run), 
		.send(send),
		.length(length), 
		.data(data), 
		.ready(ready)
	);

	
// Instantiate transmitter
		transmitter #(.BAUD(25000000)) U_TRANS (
		.data(data), 
		.send(send), 
		.clk(clk), 
		.rst(reset), 
		.switch(0),
		.txd(txd),
		.rdy(ready),
		.txen(txen)
	);
 
 

  // clock oscillator
	always begin
	   clk = 0; #5;
		clk = 1; #5;
	end

   // stimulus
	initial begin
	   // Initialize Inputs
	   clk = 0;
	   reset = 1;
	   run = 0;
	   
	   // Wait 100 ns for global reset to finish
		#100;
	   @(posedge clk) #1;
	   reset = 0;
	   run = 1;
	   repeat (400) @(posedge clk) #1;
	   $stop;
	end
   
endmodule

