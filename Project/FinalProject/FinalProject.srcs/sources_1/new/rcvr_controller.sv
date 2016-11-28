`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/26/2016 11:56:32 PM
// Design Name: 
// Module Name: rcvr_controller
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


module rcvr_controller(
	input logic rxd,
	input logic rrd,
	input logic mac,
	input logic clk,
	input logic rst,
	output logic cardet,
	output logic rrdy,
	output logic rerrcnt,
	output logic [7:0] rdata
    );

	parameter BAUD = 50000;
	parameter OUTPUTBAUD = 9600;

    mx_rcvr2 #(.BAUD(BAUD)) RCVR(
    .rxd(rxd),
    .clk(clk), 
    .rst(rst),
    .button(0),
    .data(rdata),
    .cardet(cardet), 
    .write(write), 
    .error(error)
   );
      
    rcvr_bram_controller BRAM(
	.write(write),
	.read(rrd),
	.clk_system(clk),
	.clk_in(clk_in),
	.clk_out(clk_out),
	.rst(rst),
	.data_in(data_in)
	);

   clkenb #(.DIVFREQ(BAUD)) CLKENB(.clk(clk), .reset(rst), .enb(clk_in));
   clkenb #(.DIVFREQ(OUTPUTBAUD)) CLKENB2(.clk(clk), .reset(rst), .enb(clk_out));


   logic [7:0] data_counter;

   always_ff @(posedge clk_in) begin
   	if(rst) begin
   		data_counter <= 0;
   	end else if(write) begin
   		data_counter <= data_counter + 1;
   	end
   end



endmodule
