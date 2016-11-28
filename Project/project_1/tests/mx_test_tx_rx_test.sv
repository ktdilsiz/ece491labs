`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/28/2016 10:13:22 AM
// Design Name: 
// Module Name: mx_test_tx_rx_test
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

module mx_test_tx_rx_test();

	// Internal connections
	logic data_line, cardet, write, error, send, rdy, run;
	logic [7:0] data_out, data_in; // 8 bit data connections
	// 3 = no data, just pre and sfd
	// 2 = no sfd just pre
	logic [5:0] length = 6'd32; // How many bytes to send (including 2x pre + 1x SFD)


	// reset
	logic reset = 1; // start the sim resetting everything
	
	logic clk = 0;
	// Get a clock going
	always
		#5 clk = ~clk;

	// Modules to connect
	// receiver
	mx_rcvr DUV_RX (.clk, .rst(reset), .rxd(data_line), .cardet, .data(data_out), .write, .error);

	// transmitter
	m_transmitter DUV_TX (.clk, .rst(reset), .send, .data(data_in), .rdy, .txd(data_line));

	// mx_test, ROM to send bytes
	mxtest_2 DUV_MXTEST (.clk, .reset(reset), .run, .length, .send, .data(data_in), .ready(rdy));

	// Send one byte
	task check_one_byte;
		check_group_begin("mxTest send 1 byte");
		length = 4; // 2 pre 1 sfd 1 byte
		#100 run = 1;
		@(posedge write) check("Verify 1 byte match", data_out, DUV_MXTEST.byterom[3]);
		run = 0;
		check_group_end;
	endtask


	task check_many_byte;
		int i = 0;
		check_group_begin("mxTest send 29 byte");
		length = 32; // 2 pre 1 sfd 29 byte
		#100 run = 1;
		for(i=3; i<32; i++)
			@(posedge write) check("Verify byte match", data_out, DUV_MXTEST.byterom[i]);
		run = 0;
		check_group_end;
	endtask

	task check_preamble;
		check_group_begin("Checking preamble");
		length = 2; // just the pre
		#100 run = 1;
		// Watch cardet but timeout 
		fork : cardet_detect
			@(posedge cardet) disable cardet_detect;
			@(posedge rdy) disable cardet_detect;
			#10_000_000 disable cardet_detect;
		join
		check("Preamble detected", cardet, 1);
		check_group_end;
	endtask


	initial
	begin
		#100;
		reset = 0;
		check_preamble;
		check_one_byte;
		#10_000; // wait a little
		reset = 0;
		#100 reset = 0;
		// Reset the system
		check_many_byte;
		check_summary_stop;
		$finish; // sometimes it falls through the last task
	end

	
endmodule
