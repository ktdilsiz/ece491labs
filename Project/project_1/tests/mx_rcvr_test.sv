`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Greg
// 
// Create Date: 10/22/2016 05:35:18 PM
// Design Name: 
// Module Name: mx_rcvr_test
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


import check_p::*;

module mx_rcvr_test();
	
	// This is the chance of a bit getting noise
	parameter NOISE = 8; // Set between 0 and 100.

	// Connections
	// Inputs
	logic clk = 0;
	logic reset = 0;
	logic rxd = 0;

	typedef enum logic [3:0]{
		IDLE = 4'h0,
		PREAMBLE = 4'h1,
		SFD = 4'h2,
		DATA = 4'h3,
		EOF = 4'h4,
		ERROR = 4'h5
	} states;

	logic cardet, write, error;
	logic [7:0] data;

	// Use this to clearly display on the waveform what is happening
	states state;
	
	// Start the clock
	always
		#5 clk = ~clk;

	task reset_systems();
		state = IDLE;
		reset = 1;
		repeat(10000) @(posedge clk);
		reset = 0;
		repeat(10000) @(posedge clk); // get into known state
	endtask

	// Return interfearance on the input
	function interfear(input logic rxd_clean);
		if ($urandom_range(100,1) <= NOISE) interfear = ~rxd_clean;
		else interfear = rxd_clean; 
	endfunction

	// Send a manchester bit
	task send_bit(input logic data_bit, input logic noise);
		rxd = data_bit;
		repeat(1_000) @(posedge clk) // 1000 clock cycles @10ns = 100kBaud
			rxd = noise ? interfear(data_bit) : data_bit;
		repeat(1_000) @(posedge clk) // 1000 clock cycles @10ns = 100kBaud
			rxd = noise ? interfear(~data_bit) : ~data_bit;
	endtask

	// Send a byte of data
	// This sends LSB first
	task send_byte(input logic [7:0] data_byte, input logic noise);
		int i;
		for (i=0;i<8;i++)
			send_bit(data_byte[i], noise);
	endtask

	// Hold the rxd line for both bauds
	task send_EOF(input logic noise);
		state = EOF;
		rxd = 1;
		repeat(2_000) @(posedge clk);
	endtask

	// Send preamble
	task send_preamble(input logic noise);
		state = PREAMBLE;
		repeat(2) send_byte(8'h55, noise);
	endtask

	// Send SFD
	task send_SFD(input logic noise);
		state = SFD;
		send_byte(8'hD0, noise);
		state = DATA;
	endtask

	// Hold rxd line low for both baud
	task send_error(input logic noise);
		state = ERROR;
		repeat(2_000) @(posedge clk) rxd = noise ? interfear(1'b0) : 0;
	endtask

	// Generate random noise on rxd
	task noise();
		// set to 50% so it is 50/50 noise
		if ($urandom_range(100,1) <= 50)
			rxd = 0;
		else
			rxd = 1;
	endtask

	// This checks for cardet rise and fall with no data and a clean line
	task check_preamble_clean();
		// Start up clean preamble
		send_preamble(.noise(1'b0)); // no noise
		check("Clean preamble cardet trigger", cardet, 1'b1); // The cardet should go high
		send_preamble(.noise(1'b0)); // no noise
		check("Clean preamble cardet stay trigger", cardet, 1'b1); // The cardet should go high
		send_EOF(.noise(1'b0));
		check("Cardet fell on clean EOF", cardet, 1'b0); // No one talking, cardet should be low
		// TODO check if we even pass this, I don't think we will.  Should we?
	endtask

	// This checks for cardet rise and fall with no data and a noisy line
	task check_preamble_noise();
		// Start up clean preamble
		send_preamble(.noise(1'b1)); // no noise
		check("Noisy preamble cardet trigger", cardet, 1'b1); // The cardet should go high
		send_preamble(.noise(1'b1)); // no noise
		check("Clean preamble cardet stay trigger", cardet, 1'b1); // The cardet should go high
		send_EOF(.noise(1'b1));
		check("Cardet fell on noisy EOF", cardet, 1'b0); // No one talking, cardet should be low
		// TODO check if we even pass this, I don't think we will.  Should we?
	endtask

	// Tx 1 byte correctly framed
	task send_clean_byte();
		send_preamble(.noise(1'b0)); // Should only need one byte of preamble
		send_SFD(.noise(1'b0)); // SFD should trigger
		send_byte(8'h55, 1'b0);
		check("Cardet high with data", cardet, 1'b1);
		check("Data matches expected value", data, 8'h55);
		check("No error", error, 1'b0);
		check("Write pulsed", write, 1'b1);
		send_EOF(.noise(1'b0));
		check("No error after EOF detected", error, 1'b0);
		check("Cardet fell after EOF", cardet, 1'b0);
	endtask

	// Tx 1 byte correctly framed with noise
	task send_noise_byte();
		send_preamble(.noise(1'b1)); // Should only need one byte of preamble
		send_SFD(.noise(1'b1)); // SFD should trigger
		send_byte(8'h55, .noise(1'b1));
		check("Cardet high with data", cardet, 1'b1);
		check("Data matches expected value", data, 8'h55);
		check("No error", error, 1'b0);
		check("Write pulsed", write, 1'b1);
		send_EOF(.noise(1'b1));
		check("No error after EOF detected", error, 1'b0);
		check("Cardet fell after EOF", cardet, 1'b0);
	endtask

	// Tx 1 byte with error in the middle clean
	task tx_error;
		reset_systems;
		send_preamble(1'b0);
		send_SFD(1'b0);
		send_bit(1'b1,.noise(1'b0));
		send_bit(1'b1,.noise(1'b0));
		send_bit(1'b1,.noise(1'b0));
		send_error(1'b0); // one bit is actually an error
		send_bit(1'b1,.noise(1'b0));
		send_bit(1'b1,.noise(1'b0));
		send_bit(1'b1,.noise(1'b0));
		send_bit(1'b1,.noise(1'b0));
		check("Error triggered", error, 1'b1);
		check("Carrier detect dropped", cardet, 1'b0);
		// Who cares what the data output is doing
	endtask

	// Tx 1 byte with error in the middle noisy
	task tx_error_noise;
		reset = 1;
		repeat(10) @(posedge clk);
		reset = 0;
		repeat(1000) @(posedge clk);
		send_preamble(1'b1);
		send_SFD(1'b0);
		state = DATA;
		send_bit(1'b1,.noise(1'b1));
		send_bit(1'b1,.noise(1'b1));
		send_bit(1'b1,.noise(1'b1));
		state = ERROR;
		send_error(1'b1); // one bit is actually an error
		state = DATA;
		send_bit(1'b1,.noise(1'b1));
		send_bit(1'b1,.noise(1'b1));
		send_bit(1'b1,.noise(1'b1));
		send_bit(1'b1,.noise(1'b1));
		send_EOF(.noise(1'b1));
		check("Error triggered with noise", error, 1'b1);
		check("Carrier detect dropped with noise", cardet, 1'b0);
		// Who cares what the data output is doing
	endtask

	// Tx 1 byte but stop halfway through
	task tx_short;
		reset = 1;
		repeat(10) @(posedge clk);
		reset = 0;
		repeat(10) @(posedge clk);
		send_preamble(1'b0);
		send_SFD(1'b0);
		send_bit(1'b1,.noise(1'b0));
		send_bit(1'b1,.noise(1'b0));
		send_bit(1'b1,.noise(1'b0));
		send_EOF(1'b0);
		check("Error triggered", error, 1'b1);
		check("Carrier detect dropped", cardet, 1'b0);
		// Who cares what the data output is doing
	endtask

	// Tx 1 byte but stop halfway through
	task tx_short_noise;
		reset = 1;
		repeat(10) @(posedge clk);
		reset = 0;
		repeat(10) @(posedge clk);
		send_preamble(1'b1);
		send_SFD(1'b1);
		send_bit(1'b1,.noise(1'b1));
		send_bit(1'b1,.noise(1'b1));
		send_bit(1'b1,.noise(1'b1));
		send_EOF(1'b1);
		check("Error triggered with noise", error, 1'b1);
		check("Carrier detect dropped", cardet, 1'b0);
		// Who cares what the data output is doing
	endtask

	// Create a module to test and connect every wire
	// This will check that there are only the ports assigned
	mx_rcvr DUV (.clk, .reset, .rxd, .cardet, .data, .write, .error);

	task preamble_tests;
		check_group_begin("2.1 Check response to preamble");
		check_preamble_clean;
		check_preamble_noise;
		check_group_end();
	endtask

	task one_byte_test;
		send_clean_byte;
		send_noise_byte;
	endtask

	// Send 0 bytes test
	task test_just_SFD;
		check_group_begin("Check no byte");
		rxd = 1;
		reset_systems;
		send_preamble(.noise(1'b0));
		check("Cardet high", cardet, 1'b1);
		send_SFD(.noise(1'b0));
		send_EOF(.noise(1'b0));
		check("Error low", error, 1'b0);
		check("Cardet low", cardet, 1'b0);
		check_group_end;
	endtask

	// 10a test
	task test_10a;
		check_group_begin("10a check one byte");
		rxd = 1;
		reset_systems;
		send_preamble(.noise(1'b0));
		check("Cardet high", cardet, 1'b1);
		send_SFD(.noise(1'b0));
		send_byte(8'h55, .noise(1'b0));
		send_EOF(.noise(1'b0));
		check("Error low", error, 1'b0);
		check("Data received", data, 8'h55);
		check_group_end;
	endtask


	task send_two_bytes;
		logic [7:0] byte_to_send = 8'h00;
		check_group_begin("2 byte tx");
		rxd = 1;
		reset_systems;
		repeat(2)
		begin
			send_preamble(.noise(1'b0));
			check("Cardet high", cardet, 1'b1);
			send_SFD(.noise(1'b0));
			send_byte(byte_to_send, .noise(1'b0));
			send_EOF(.noise(1'b0));
			check("Error low", error, 1'b0);
			check("Data received", data, byte_to_send);
			check("Carrier detect dropped", cardet, 1'b0);
			byte_to_send = 8'hF0;
		end
		repeat(1000) @(posedge clk); // spin for a little
		check_group_end;

	endtask

	// 10b test
	task test_10b;
		logic [7:0] byte_to_send;
		check_group_begin("10b check 24 bytes");
		rxd = 1;
		reset_systems;
		send_preamble(.noise(1'b0));
		check("Cardet high", cardet, 1'b1);
		send_SFD(.noise(1'b0));
		repeat(24)  // send 24 bytes
		begin
			byte_to_send = $urandom_range(8'hFF,8'h00);
			//byte_to_send = 8'h00;
			send_byte(byte_to_send, .noise(1'b0));
			check("Error low", error, 1'b0);
			check("Data received", data, byte_to_send);
		end
		send_EOF(.noise(1'b0));
		check_group_end;
	endtask
		
	// 10c test
	task test_10c;
		check_group_begin("10c test");
		reset_systems;
		// repeat 10e6 for bits then 2000 for each clock in a bit period
		repeat(10e6) repeat(2000) @(posedge clk) noise();
		send_noise_byte;
		repeat(10e6) repeat(2000) @(posedge clk) noise();
		check_group_end;
	endtask

	task test_10d;
		check_group_begin("10d test");
		tx_error;
		#1000;
		tx_error_noise;
		check_group_end;
	endtask

	task test_10e;
		check_group_begin("10e test");
		tx_short;
		repeat(1000) @(posedge clk);
		tx_short_noise;
		check_group_end;
	endtask
	
	// Test 10f/g are in a different test bench

	initial
	begin
		reset_systems;
		#100;
		//send_two_bytes;
		test_10a; // The most basic test send 1 byte clean.
		test_10b; // Sending a frame of 24 random bytes.
		//test_10c; // 10e6 bit periods of random noise followed by a noisy byte, then more noise
		test_10d; // Sending a byte with an error in the middle
		test_10e; // Sending short byte, should be an error
		check_summary_stop();
		$stop();// this shouldn't be needed
	end

endmodule
