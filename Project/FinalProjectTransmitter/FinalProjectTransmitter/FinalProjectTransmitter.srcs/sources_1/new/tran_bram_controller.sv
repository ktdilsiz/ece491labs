`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/28/2016 09:01:24 PM
// Design Name: 
// Module Name: tran_bram_controller
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


module tran_bram_controller(
    input logic write,
	input logic [7:0] data_in,
	input logic read,
	input logic clk_system,
	input logic clk_in,
	input logic clk_out,
	input logic rst,
	output logic full,
	output logic empty,
	output logic [7:0] data_out
    );
    
    logic [7:0] pointer_read = 8'd0;
        logic [7:0] pointer_write = 8'd0;
    
        mem #(.RAM_WIDTH(8), .RAM_DEPTH(256)) 
        BRAM_TRAN(
            .clk_a(clk_in), 
            .addr_a(pointer_write), 
            .dati_a(data_in), 
            .we_a(write && ~full), 
            .clk_b(clk_out), 
            .addr_b(pointer_read), 
            .dato_b(data_out)
            );
    
        logic [7:0] pointer_write_next;
    
        assign pointer_write_next = pointer_write + 1;
    
    
        always_ff @(posedge clk_system) begin
    
            if(rst) begin
                pointer_read <= 8'd0;
                pointer_write <= 8'd0;
            end
    
            else if(write && read && clk_in && clk_out && ~full)
            begin
                pointer_write <= pointer_write + 1;
                pointer_read <= pointer_read + 1;
            end
    
            else if(write && clk_in && ~full)
                pointer_write <= pointer_write + 1;
    
            else if(read && clk_out && ~empty)
            begin
                pointer_read <= pointer_read + 1;
    
                if(pointer_write == pointer_read && pointer_write != 8'd0) 
                begin
                    pointer_read <= 8'd0;
                    pointer_write <= 8'd0;
                end
    
            end
        end
    
        logic guard_bit;
    
        always_ff @(posedge clk_system)
        begin
            if(rst)
                guard_bit <= 1'b0;
            else if((pointer_write_next == pointer_read) && write)
                guard_bit <= 1'b1;
            else if(read)
                guard_bit <= 1'b0;
        end
    
        assign full = (pointer_write == pointer_read && guard_bit) ? 1 : 0;
        assign empty = (pointer_write == pointer_read && ~guard_bit) ? 1 : 0;

endmodule
