`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/30/2016 01:51:35 PM
// Design Name: 
// Module Name: clkenbTEST
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


module clkenbTEST();

	logic clk = 0;
	logic rst;

	logic SixteenBaudRate;
    clkenb #(.DIVFREQ(25000000)) CLKENB3(.clk(clk), .reset(rst), .enb(SixteenBaudRate));
    
    always
    	#5 clk = ~clk;



   	initial
   		begin
   			//rst = 1;
   			#10;
   			rst = 0;

   			#10000
   			$stop();
   		end

endmodule
