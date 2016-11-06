`timescale 1ns / 1ps
module p_fifo(
    input logic clk, rst, clr, we, re,
    input logic [7:0] din,
    output logic full, empty,
    output logic [7:0] dout);

parameter BAUD = 50000;

clkenb #(.DIVFREQ(BAUD)) CLKENB(.clk(clk), .reset(rst), .enb(BaudRate));
clkenb #(.DIVFREQ(BAUD/10)) CLKENBEIGHT(.clk(clk), .reset(rst), .enb(BaudRateeight));

parameter numBits = 32;
parameter DIVBITS = $clog2(numBits);

////////////////////////////////////////////////////////////////////
//
// Local Wires
//

logic   [7:0] mem[0:numBits-1];
logic   [DIVBITS-1:0]   wp;
logic   [DIVBITS-1:0]   rp;
logic   [DIVBITS-1:0]   wp_p1;
logic   [DIVBITS-1:0]   wp_p2;
logic   [DIVBITS-1:0]   rp_p1;
logic   gb;

////////////////////////////////////////////////////////////////////
//
// Misc Logic
//

always @(posedge BaudRate or posedge rst)
        if(rst) wp <= #1 2'h0;
        else
        if(clr)         wp <= #1 2'h0;
        else
        if(we)
        begin
            if(full == 1)
            begin
               wp <= wp;
            end
            else
            begin
                wp <= #1 wp_p1;
            end
        end

assign wp_p1 = wp + 2'h1;
assign wp_p2 = wp + 2'h2;

always @(posedge BaudRateeight or posedge rst)
        if(rst) rp <= #1 2'h0;
        else
        if(clr)         rp <= #1 2'h0;
        else
        if(re)
        begin
            if(empty == 1)
            begin
                rp <= rp;
            end
            else
            begin
                rp <= #1 rp_p1;
            end
        end

assign rp_p1 = rp + 2'h1;


// Fifo Output

// always_ff@(posedge clk)
// begin
//     if(BaudRateeight)
//         dout <= mem [ rp ];
//     else
//         dout <= dout;
// end

assign  dout = mem[ rp ];

// Fifo Input
always @(posedge BaudRate)
        if(we)
        begin
            if(full == 0)
            begin
                mem[ wp ] <= #1 din;
            end
        //mem[ wp ] <= #1 din;
        end

// Status
assign empty = (wp == rp) & !gb;
assign full  = (wp == rp) &  gb;

// Guard Bit ...
always @(posedge BaudRateeight)
        if(rst)                 gb <= #1 1'b0;
        else
        if(clr)                         gb <= #1 1'b0;
        else
        if((wp_p1 == rp) & we)          gb <= #1 1'b1;
        else
        if(re)                          gb <= #1 1'b0;

endmodule