`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/06/2016 01:58:06 PM
// Design Name: 
// Module Name: trans_control_test
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


module trans_control_test( );

	logic clk, rst, rxd, txd;

	trans_controller_2 #(.BAUD(50000), .OUTPUTBAUD(9600)) TRAN_TEST(
		.rxd_a_rcvr_in(rxd),
		.clk(clk),
		.rst(rst),
		.txd_m_trans_out(txd)
		);

    logic BaudRate;
      clkenb #(.DIVFREQ(9600)) CLKENB3(.clk(clk), .reset(rst), .enb(BaudRate));

	always
    begin
     clk = 1;
     #5; clk = 0;
     #5;
    end

  task check_input;
     
//transmit dest     
  	@(posedge BaudRate) rxd = 0; 

	@(posedge BaudRate) rxd = 0; 
	@(posedge BaudRate) rxd = 0; 
	@(posedge BaudRate) rxd = 0; 
	@(posedge BaudRate) rxd = 0; 

	@(posedge BaudRate) rxd = 0; 
	@(posedge BaudRate) rxd = 0; 
	@(posedge BaudRate) rxd = 1; 
	@(posedge BaudRate) rxd = 0; 

    @(posedge BaudRate) rxd = 1; 
   
//////////////////////////////////////
//transmit source
   @(posedge BaudRate) rxd = 0; 

	@(posedge BaudRate) rxd = 0; 
	@(posedge BaudRate) rxd = 1; 
	@(posedge BaudRate) rxd = 1; 
	@(posedge BaudRate) rxd = 0; 

	@(posedge BaudRate) rxd = 1; 
	@(posedge BaudRate) rxd = 1; 
	@(posedge BaudRate) rxd = 1; 
	@(posedge BaudRate) rxd = 0; 

    @(posedge BaudRate) rxd = 1; 


//////////////////////////////////////
//transmit type
   @(posedge BaudRate) rxd = 0; 

	@(posedge BaudRate) rxd = 0; 
	@(posedge BaudRate) rxd = 0; 
	@(posedge BaudRate) rxd = 0; 
	@(posedge BaudRate) rxd = 0; 

	@(posedge BaudRate) rxd = 1; 
	@(posedge BaudRate) rxd = 1; 
	@(posedge BaudRate) rxd = 0; 
	@(posedge BaudRate) rxd = 0; 

    @(posedge BaudRate) rxd = 1;     

///////////////////////////////////////////
//transmit data
    repeat(2) begin
    @(posedge BaudRate) rxd = 0; 

	@(posedge BaudRate) rxd = 0; 
	@(posedge BaudRate) rxd = 0; 
	@(posedge BaudRate) rxd = 1; 
	@(posedge BaudRate) rxd = 0; 

	@(posedge BaudRate) rxd = 1; 
	@(posedge BaudRate) rxd = 1; 
	@(posedge BaudRate) rxd = 0; 
	@(posedge BaudRate) rxd = 0; 

    @(posedge BaudRate) rxd = 1;  
	end

	repeat(2) begin
    @(posedge BaudRate) rxd = 0; 

	@(posedge BaudRate) rxd = 0; 
	@(posedge BaudRate) rxd = 0; 
	@(posedge BaudRate) rxd = 1; 
	@(posedge BaudRate) rxd = 0; 

	@(posedge BaudRate) rxd = 1; 
	@(posedge BaudRate) rxd = 1; 
	@(posedge BaudRate) rxd = 0; 
	@(posedge BaudRate) rxd = 1; 

    @(posedge BaudRate) rxd = 1;  
	end

	repeat(2) begin
    @(posedge BaudRate) rxd = 0; 

	@(posedge BaudRate) rxd = 0; 
	@(posedge BaudRate) rxd = 0; 
	@(posedge BaudRate) rxd = 1; 
	@(posedge BaudRate) rxd = 0; 

	@(posedge BaudRate) rxd = 1; 
	@(posedge BaudRate) rxd = 1; 
	@(posedge BaudRate) rxd = 1; 
	@(posedge BaudRate) rxd = 0; 

    @(posedge BaudRate) rxd = 1;  
	end

    repeat(2) begin
    @(posedge BaudRate) rxd = 0; 

	@(posedge BaudRate) rxd = 0; 
	@(posedge BaudRate) rxd = 0; 
	@(posedge BaudRate) rxd = 1; 
	@(posedge BaudRate) rxd = 0; 

	@(posedge BaudRate) rxd = 1; 
	@(posedge BaudRate) rxd = 1; 
	@(posedge BaudRate) rxd = 1; 
	@(posedge BaudRate) rxd = 1; 

    @(posedge BaudRate) rxd = 1;  
	end	

  endtask

  initial begin

  	rst = 1;

  	#200;

  	rst = 0;

  	repeat(10) @(posedge BaudRate) rxd = 1;

  	check_input;

  	repeat(100) @(posedge BaudRate) rxd = 1;

  	check_input;

  end


endmodule
