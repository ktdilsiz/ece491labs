`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/29/2016 10:33:37 AM
// Design Name: 
// Module Name: correlatortest
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


module correlatortest();

    logic clk, rst, enb, d_in, h_out, l_out;
    logic [$clog2(8):0] csum;
 
    correlator #(.LEN(8), .PATTERN(8'b10101010), .HTHRESH(6), .LTHRESH(2)) 
    CORRTEST( 
    .clk(clk), 
    .reset(rst), 
    .enb(enb), 
    .d_in(d_in), 
    .csum(csum), 
    .h_out(h_out), 
    .l_out(l_out));
    
    logic rst_sfd, enb_sfd, d_in_sfd, h_out_sfd, l_out_sfd;
    logic [$clog2(8):0] csum_sfd;
    
    correlator #(.LEN(8), .PATTERN(8'b00001011), .HTHRESH(6), .LTHRESH(2))
    CORRTEST_SFD( 
    .clk(clk), 
    .reset(rst_sfd), 
    .enb(enb_sfd), 
    .d_in(d_in_sfd), 
    .csum(csum_sfd), 
    .h_out(h_out_sfd), 
    .l_out(l_out_sfd));
    
    logic rst_bit, enb_bit, d_in_bit, h_out_bit, l_out_bit;
    logic [$clog2(8):0] csum_bit;
    
    correlator #(.LEN(8), .PATTERN(8'b11110000), .HTHRESH(6), .LTHRESH(2)) 
    CORRTEST_BIT( 
    .clk(clk), 
    .reset(rst_bit), 
    .enb(enb_bit), 
    .d_in(d_in_bit), 
    .csum(csum_bit), 
    .h_out(h_out_bit), 
    .l_out(l_out_bit));
    
    import check_p1::*;
  
    // clock generator
    always
    begin
     clk = 1;
     #5 clk = 0;
     #5 ;
    end

    task check_preamble;
    d_in = 1;
    enb = 0;
        
    @(posedge clk) d_in = 1; enb = 1;
    repeat (9) @(posedge clk) d_in = ~d_in ;    
    
    #1;
    
    check("preamble end high", h_out, 1'b1);
    check("preamble end low", l_out, 1'b0);
    
    repeat (9) @(posedge clk) d_in = ~d_in ;  
    
    enb = 0;
    
    endtask
    
    
    task check_sfd;
    
    //correlator CORRTEST #(.PATTERN(8'b00001011));
    
    d_in_sfd = 1;
    enb_sfd = 0;
        
    @(posedge clk) d_in_sfd = 0; enb_sfd = 1;
    repeat (3) @(posedge clk) d_in_sfd = 0;  
    @(posedge clk) d_in_sfd = 1;  
    @(posedge clk) d_in_sfd = 0; 
    @(posedge clk) d_in_sfd = 1; 
    @(posedge clk) d_in_sfd = 1;
    
    repeat(5) @(posedge clk) d_in_sfd = 0; 
    
    check("sfd end", h_out_sfd, 1'b1);
    check("sfd end", l_out_sfd, 1'b0);
    
    enb_sfd = 0;
    
    endtask
    
    
    task check_bit;
    
    //CORRTEST #(.PATTERN(8'b11110000));
    
    d_in_bit = 1;
    enb_bit = 0;
        
    @(posedge clk) d_in_bit = 1; enb_bit = 1;
    repeat (3) @(posedge clk) d_in_bit = 1;
    repeat (4) @(posedge clk) d_in_bit = 0; 
    repeat (4) @(posedge clk) d_in_bit = 1;    
    
    check("bit end", h_out_bit, 1'b1);
    check("bit end", l_out_bit, 1'b0);
    
    enb_bit = 0;
    
    endtask
    
    initial begin
    rst = 0;
    
    check_preamble;
    check_sfd;
    check_bit;
    
    end

endmodule
