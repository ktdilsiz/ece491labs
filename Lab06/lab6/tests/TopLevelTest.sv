`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/01/2016 11:18:44 PM
// Design Name: 
// Module Name: TopLevelTest
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


module TopLevelTest();

	logic clk, btnc, btnu, btnl, btnr, btnd, jardy, jawrite, jacardet, jaerror, jatxen, dp;
	logic [15:0] switches;
	logic [7:0] leds = 8'b00000000;
	logic [6:0] segs
;	logic [7:0] an;

    parameter BAUD = 50000;

	topmodule #(.BAUD(BAUD)) toplevel(
          .CLK100MHZ(clk),
		  .SW(switches),
		  .BTNC(btnc),
		  .BTNU(btnu), 
		  .BTNL(btnl), 
		  .BTNR(btnr),
		  .BTND(btnd),
		  .SEGS(segs),
		  .AN(an),
		  .DP(dp),
		  .LED(leds),	  
		  .UART_RXD_OUT(outdata),
		  .UART_RXD_OUT_copy(outdata_copy),
		  .JAtxd(jardy),
		  .JAtxen(jatxen),
		  .JAcardet(jacardet),
		  .JAwrite(jawrite),
		  .JAerror(jaerror)  
            );

	always
    begin
     clk = 1;
     #5 clk = 0;
     #5 ;
    end

    clkenb #(.DIVFREQ(BAUD)) CLKENB3(.clk(clk), .reset(1'b0), .enb(BaudRate));


    logic [7:0] data_in;

    logic [4:0] length;

    logic mxtest_input;

    logic clr;

    logic re_fifo;

    assign switches = {re_fifo, clr, mxtest_input, length, data_in};


    initial 
    	begin

    		btnu = 0;
    		mxtest_input = 1;
    		clr = 0;
    		re_fifo = 0;

    		btnl= 0;
    		btnd = 0;
    		btnr = 1;

	   		length = 5'b11111;
    		data_in = 8'b10110110;

            //repeat(300) @(posedge BaudRate) #5;

    		@(posedge BaudRate) btnc = 1;
    		@(posedge BaudRate) btnc = 0;


    		@(posedge BaudRate)

    		@(posedge BaudRate) mxtest_input = 1;

            //repeat (400) @(posedge BaudRate) #5;
    		repeat(2) @(posedge BaudRate) btnu = 1;

    		@(posedge BaudRate) btnu = 1;

    		

    		repeat (300) @(posedge BaudRate) #5;

    		@(posedge BaudRate) //re_fifo = 1;
            btnu = 1;

            repeat (400) @(posedge BaudRate) #5;
            btnu = 1;

            repeat (150) @(posedge BaudRate) #5;
            btnu = 1;

            //@(posedge BaudRate) re_fifo = 0;



    	end


endmodule
