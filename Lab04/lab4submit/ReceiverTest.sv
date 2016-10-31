`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/11/2016 03:49:20 PM
// Design Name: 
// Module Name: TransmitterTest
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


module ReceiverTest();
    
      // signals for connecting the counter      
       logic rxd, clk, rst, ferr, rdy;
       logic [7:0] data;
       
       
     // instantiate device under verification (        
         receiver #(.BAUD(2_500_0000 / 16)) RECEV(
                 .rxd(rxd),
                 .clk(clk), 
                 .rst(rst),
                 .ferr(ferr),
                 .rdy(rdy),
                 .data
               );

      always
         begin
        clk = 0;
        #5 clk = 1;
        #5 ;
         end
             
       // initial block generates stimulus
       initial begin
       
       #5;
       rst = 1;
       #5;
       rst = 0;
       #30;       
              
       repeat (2) @(posedge clk)
        begin
          rxd = 1'b0;
          #160;
          rxd = 1'b1;
          #160;
            rxd = 1'b0;
          #160;
            rxd = 1'b1;
          #160;
            rxd = 1'b0;
          #160;
            rxd = 1'b1;
          #160;
            rxd = 1'b0;
          #160;
            rxd = 1'b1;
          #160;
            rxd = 1'b0;
          #160;
            rxd = 1'b1;
          #320;
        end
        
        repeat (1) @(posedge clk)
        begin
            //16/5 = 3.2 times clk enable from 16*baudrate in receiver
            //therefore, 2 nano seconds mean 6.4 clk enables
            //we check the middle error when our clk enable count is 7
            //meaning that we will always land on the error and
            //this will give us ferr = 1, for five times
            rxd = 1'b0;
            #64;                    //64
            rxd = 1'b1;
            #96;                    //96
            rxd = 1'b0;
            #128;              
            rxd = 1'b1;
            #168;         //192
        end
        
        #320;
        
       repeat (2) @(posedge clk)
         begin
           rxd = 1'b0;
           #160;
           rxd = 1'b1;
           #160;
             rxd = 1'b1;
           #160;
             rxd = 1'b1;
           #160;
             rxd = 1'b0;
           #160;
             rxd = 1'b0;
           #160;
             rxd = 1'b1;
           #160;
             rxd = 1'b1;
           #160;
             rxd = 1'b0;
           #160;
             rxd = 1'b1;
           #320;
         end
        
       
          $stop();  // all done - suspend simulation
       end // initial
       
endmodule 

