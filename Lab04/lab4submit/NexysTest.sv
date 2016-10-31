`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/03/2016 03:49:20 PM
// Design Name: 
// Module Name: NexysTest
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


module NexysTest();
    
      // signals for connecting the nexys      
       
       logic [8:0] data;
       logic [7:0] AN;
       logic [6:0] seg;
       logic send;
       logic clk, rst;
       logic txd;
       logic rdy; 
       logic [2:0] led;
       logic switch;
	   logic rxd, ferr;
 
       
       // instantiate device under verification (nexys4DDR)        

        nexys4DDR #(.BAUD(25_000_000 / 16)) NEXYS(
                   .CLK100MHZ(clk),
                   .SW(data),
                   .BTNC(rst),
                   .BTNL(switch), 
                   .BTNR(send),
                   .SEGS(seg),
                   .AN(AN),
                   .DP(dp),
                   .LED(led),          
                   .UART_RXD_OUT(rxd),
                   .UART_RXD_OUT_copy(txd),             //multiple concurrent drivers for rxd, commented out JAferr = LED[1]
                   .JArdy(rdy),
                   .JAferr(ferr)
                        );


      // clock generator with period=20 time units
      always
         begin
        clk = 0;
        #5 clk = 1;
        #5 ;
         end
    
    
       // initial block generates stimulus
       initial begin
        
        #16
        rst = 1;
        #16
        rst = 0;
        #16

        //clk = 0;
        repeat (1) @(posedge clk) 
        begin
        send = 1;
        data = 9'b101010101;
        #7200;
        send = 0;
        #1600;
        end
        
        repeat (1) @(posedge clk) 
        begin
        send = 1;
        data = 9'b111001100;
        #7200;
        send = 0;
        #1600;
        end
        
        
//        @(posedge clk) send = 1;
//        @(posedge clk); repeat(20*16)
        
//        @(posedge clk) data = 9'b100001111;
//        @(posedge clk) send = 1;
//        @(posedge clk); repeat(20*16)
        
//        @(posedge clk) data = 9'b111001100;
//        @(posedge clk) send = 1;
//        @(posedge clk); repeat(20*16)
        
        #50;
          $stop();  // all done - suspend simulation
       end // initial
       
endmodule 

