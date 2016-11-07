`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Greg
// 
// Create Date: 10/24/2016 05:35:18 PM
// Design Name: 
// Module Name: tx_rx_test.sv
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

module tx_rx_test();
	
	// Connections
	// Inputs
	logic clk_1 = 0;
	logic clk_2 = 0;
	logic reset = 0;
	logic send = 0;

	// Outputs
	logic rdy;

	// Internal connection
	logic rxd, txd;
	assign rxd = txd;

	// Useful for debugging
	typedef enum logic [2:0] {
		IDLE = 3'h0,
		PREAMBLE = 3'h1,
		SFD = 3'h2,
		DATA = 3'h3
	} states;

	states state;

	

	logic cardet, write, error;
	logic [7:0] data_out;
	logic [7:0] data_in;
	
	// Start the two clocks
	jitteryclock #(.SEED(4321)) U_CLK1 (.clk(clk_1));
	jitteryclock #(.SEED(1234)) U_CLK2 (.clk(clk_2));

	task reset_systems();
		state = IDLE;
		reset = 1;
		repeat(10) @(posedge clk_1);
		reset = 0;
		repeat(10) @(posedge clk_1); // get into known state
	endtask

	// Send a byte of data
	// This sends LSB first
	task send_byte(input logic [7:0] data_byte);
		data_in = data_byte;
		send = 1;
		@(negedge rdy) send = 0; #1;
		@(posedge rdy); // Wait for byte tx to happen
	endtask


	task send_random_byte;
		send_byte($urandom_range(8'h00,8'hFF));
	endtask

	// Send preamble
	task send_preamble();
		state = PREAMBLE;
		send_byte(8'h55);
	endtask

	// Send SFD
	task send_SFD();
		state = SFD;
		send_byte(8'hD0);
	endtask

	// This checks for cardet rise and fall with no data and a clean line
	task check_preamble_clean();
		// Start up clean preamble
		send_preamble(); 
		check("Clean preamble cardet trigger", cardet, 1'b1); // The cardet should go high
		send_preamble(); 
		check("Clean preamble cardet stay trigger", cardet, 1'b1); // The cardet should go high
		check("Cardet fell on loss of preamble", cardet, 1'b0); // No one talking, cardet should be low
		// TODO check if we even pass this, I don't think we will.  Should we?
	endtask

	// Tx 1 byte correctly framed
	task send_clean_byte();
		send_preamble(); // Should only need one byte of preamble
		send_SFD(); // SFD should trigger
		send_byte(8'h55);
		check("Cardet high with data", cardet, 1'b1);
		check("Data matches expected value", data_out, 8'h55);
		check("No error", error, 1'b0);
		check("Write pulsed", write, 1'b1);
		repeat(2000) @(posedge clk_1); // Idle here for EOF
		check("No error after EOF detected", error, 1'b0);
		check("Cardet fell after EOF", cardet, 1'b0);
	endtask

	// Create a module to test and connect every wire
	// This will check that there are only the ports assigned
	mx_rcvr DUV_RX (.clk(clk_1), .reset, .rxd, .cardet, .data(data_out), .write, .error);

	manchester_tx DUV_TX (.clk(clk_1), .reset, .send, .data(data_in), .rdy, .txd);

	task preamble_tests;
		check_group_begin("2.1 Check response to preamble");
		check_preamble_clean;
		check_group_end();
	endtask

	// Send 0 bytes test
	task test_just_SFD;
		check_group_begin("Check no byte");
		rxd = 1;
		reset_systems;
		send_preamble();
		check("Cardet high", cardet, 1'b1);
		send_SFD();
		state = IDLE;
		repeat(4000) @(posedge clk_1); // wait for EOF
		check("Error low", error, 1'b0);
		check("Cardet low", cardet, 1'b0);
		check_group_end;
	endtask

	// 10a test
	task test_10a;
		check_group_begin("10a check one byte");
		repeat(2) send_preamble;
		send_byte(8'hD0);
		send_byte(8'h5F);
		@(edge data_out) // wait until data changes
			check("Verify data", data_out, 8'h5F);
		send_byte(8'h83);
		@(edge data_out) // wait until data changes
			check("Verify data", data_out, 8'h83);
		check_group_end;
	endtask


	task test_10f_random_bytes;
		logic [7:0] byte_to_send;
		check_group_begin("10f check random bytes");
		rxd = 1;
		reset_systems;
		repeat(2) send_preamble;
		send_byte(8'hD0);
		// Send random frames 10 times
		repeat(10)
			begin
			repeat($urandom_range(256,1)) // send a random amount of bytes
				begin
					byte_to_send = $urandom_range(8'hFF,8'h00);
					send_byte(byte_to_send);
					@(posedge write); // wait for the tx to get to the last bit
					// The data should be correct when the write happens
					check("Error low", error, 1'b0);
					check("Data received", data_out, byte_to_send);
				end
			check_ok("Data received for random duration", data_out, byte_to_send);
			end
		repeat(2000) @(posedge clk_1); // Idle here for EOF
		check_group_end;
	endtask
		
	task test_10f_1frame;
		logic [7:0] byte_to_send;
		check_group_begin("10f check one byte");
		rxd = 1;
		reset_systems;
		repeat(2) send_preamble;
		send_byte(8'hD0);
		// Send random byte once
		byte_to_send = $urandom_range(8'hFF,8'h00);
		send_byte(byte_to_send);
		@(posedge write); // wait for the tx to get to the last bit
		// The data should be correct when the write happens
		check("Error low", error, 1'b0);
		check("Data received", data_out, byte_to_send);
		repeat(2000) @(posedge clk_1); // Idle here for EOF
		check_group_end;
	endtask

	task test_10f_256frame;
		logic [7:0] byte_to_send;
		check_group_begin("10f check 256 bytes");
		rxd = 1;
		reset_systems;
		repeat(2) send_preamble;
		send_byte(8'hD0);
		repeat(256) // send 256 bytes
		begin
			byte_to_send = $urandom_range(8'hFF,8'h00);
			send_byte(byte_to_send);
			@(posedge write); // wait for the tx to get to the last bit
			// The data should be correct when the write happens
			check("Error low", error, 1'b0);
			check("Data received", data_out, byte_to_send);
		end
		repeat(2000) @(posedge clk_1); // Idle here for EOF
		check_group_end;
	endtask

	// Test a-e and g are in another bench

	initial
	begin
		reset_systems;
		#100;
		repeat(20000) @(posedge clk_1);
		test_10f_1frame;
		repeat(20000) @(posedge clk_1);
		test_10f_256frame;
		repeat(20000) @(posedge clk_1);
		test_10f_random_bytes;
		check_summary_stop;
		$finish();
	end

endmodule
