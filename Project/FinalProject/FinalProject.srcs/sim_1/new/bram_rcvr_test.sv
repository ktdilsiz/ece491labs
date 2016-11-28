`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/27/2016 04:19:18 PM
// Design Name: 
// Module Name: bram_rcvr_test
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


module bram_rcvr_test();

logic write, read, clk, clk_in, clk_out, rst;
logic [7:0] data_in;

rcvr_bram_controller BRAM_TEST(
	.write(write),
	.read(read),
	.clk_system(clk),
	.clk_in(clk_in),
	.clk_out(clk_out),
	.rst(rst),
	.data_in(data_in)
	);

always
	begin
	clk = 1; 
	#5;
	clk = 0; 
	#5;
end

always
begin
	clk_in = 1;
	#5;
	clk_in = 0;
	#15;
end

always
begin
	clk_out = 1;
	#5;
	clk_out = 0;
	#35;
end

task check_simple;
	rst = 1; data_in = 8'd0;

	write = 1;
	read = 0;
	
	@(posedge clk) rst = 1;
	@(posedge clk) rst = 0;

	repeat(512)
	begin
	@(posedge clk)
	write = 1;
		if(clk_in) begin
			data_in = data_in + 1;
			//write = 1;
		end
		else begin
			//write = 0;
		end		
	end

	write = 0;

	repeat(10) @(posedge clk);

	repeat(20)
	begin
	@(posedge clk)
	write = 1;
		if(clk_in) begin
			data_in = data_in + 1;
			//write = 1;
		end
		else begin
			//write = 0;
		end		
	end

	write = 0;

	repeat(10) @(posedge clk);

	repeat(257)
	begin
	@(posedge clk_out)
	read = 1;
		if(clk_out) begin
			//data_in = data_in + 1;
			//write = 1;
		end
		else begin
			//write = 0;
		end		
	end

	read = 0;

endtask

initial begin

	data_in = 8'd0;

	#100;

	check_simple;

	data_in = 8'd0;

	#50;

	check_simple;

end

endmodule
