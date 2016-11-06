`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/30/2016 09:05:14 PM
// Design Name: 
// Module Name: FIFO_ASYC_TRAN
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


module FIFO_ASYC_TRAN;
       parameter BAUD = 25_000_000;
       parameter numBits = 4;
       parameter DIVBITS = $clog2(numBits);
       
     // signals for connecting the nexys4DDR top module      
     
      logic [7:0] data;
      logic clk, rst;
      logic send;
      logic txd;
      logic rdy, empty, full, clr;
      logic we, re;

      logic [3:0] temp_led = {full, empty, rdy, 1'b0};

      
      // instantiate device under verification (counter)        
      nexys4DDR #(.BAUD(25_000_000), .numBits(4), .DIVBITS($clog2(4))) NEXYS(.CLK100MHZ(clk), .SW(data), .BTNC(rst), .BTNU(we), .BTNL(clr), .BTNR(re), .BTND(send), .LED(temp_led), .UART_RXD_OUT(txd));
     
     import check_p::*;

     // clock generator with period=20 time units
      always
            begin
           clk = 0;
           #5 clk = 1;
           #5 ;
      end
      
       task check_add_0x30;
            
         rst = 0; 
         we = 0; 
         clr = 0; 
         re = 0; 
         we = 1;
         send = 0; 
         data = 8'b00110000; 
         
         @(posedge clk) begin rst = 1; re = 1; send = 1; end
           check("fifo empty", empty, 1'b1);
           check("tran rdy", rdy, 1'b1);
           check("fifo ~full", full, 1'b0);
           
        repeat (36) @(posedge clk) begin rst = 0;  end
        check("rdy high", rdy, 1'h1); 
            
        @(posedge clk) check("txd gets data", txd, data[0]); 
        @(posedge clk) check("txd gets data", txd, data[1]); 
        @(posedge clk) check("txd gets data", txd, data[2]); 
        @(posedge clk) check("txd gets data", txd, data[3]); 
        @(posedge clk) check("txd gets data", txd, data[4]); 
        @(posedge clk) check("txd gets data", txd, data[5]); 
        @(posedge clk) check("txd gets data", txd, data[6]); 
        @(posedge clk) check("txd gets data", txd, data[7]);  
          
           rst = 1'h1; we = 1'h0; re = 1'h0;  
        endtask
         
      
      task check_add_0xe3;
        check_add_0x30;
        
        data = 8'b11100011;

        send = 1;
        we = 1'h1;
        clr = 1'h0;
        
         @(posedge clk) begin rst = 1; re = 1'h1; end
         check("fifo ~empty", empty, 1'b0);
         check("tran rdy", rdy, 1'b1);
         check("fifo ~full", full, 1'b0);
         
         repeat (36) @(posedge clk) rst = 0;
         check("rdy low", rdy, 1'h1);
          @(posedge clk) check("txd gets data", txd, data[0]); 
         @(posedge clk) check("txd gets data", txd, data[1]); 
         @(posedge clk) check("txd gets data", txd, data[2]); 
         @(posedge clk) check("txd gets data", txd, data[3]); 
         @(posedge clk) check("txd gets data", txd, data[4]); 
         @(posedge clk) check("txd gets data", txd, data[5]); 
         @(posedge clk) check("txd gets data", txd, data[6]); 
         @(posedge clk) check("txd gets data", txd, data[7]); 
         rst = 1'h1; we = 1'h0; re = 1'h0; clr = 1'h1; 
        
      endtask
      
      task check_add_0x33;
      
      check_add_0xe3;
      
      data = 8'b00110011;

      send = 1;
      we = 1'h1;
      clr = 1'h0;
      
       @(posedge clk) begin rst = 1'h1; re = 1'h1; end
       check("fifo ~empty", empty, 1'b0);
       check("tran rdy", rdy, 1'b1);
       check("fifo ~full", full, 1'b0);
       
       repeat (36) @(posedge clk) rst = 0;
       check("rdy low", rdy, 1'h1);
       @(posedge clk) check("txd gets data", txd, data[0]); 
       @(posedge clk) check("txd gets data", txd, data[1]); 
       @(posedge clk) check("txd gets data", txd, data[2]); 
       @(posedge clk) check("txd gets data", txd, data[3]); 
       @(posedge clk) check("txd gets data", txd, data[4]); 
       @(posedge clk) check("txd gets data", txd, data[5]); 
       @(posedge clk) check("txd gets data", txd, data[6]); 
       @(posedge clk) check("txd gets data", txd, data[7]); 
       rst = 1'h1; we = 1'h0; re = 1'h0; clr = 1'h1;
      endtask
      
      task check_add_0xff;
      
        check_add_0x33;
        
        data = 8'b11111111;

        send = 1;
        we = 1'h1;
        clr = 1'h0;
        
        @(posedge clk) begin rst = 1; re = 1'h1; end
        check("fifo ~empty", empty, 1'b0);
        check("tran rdy", rdy, 1'b1);
        check("fifo full", full, 1'b1);
        
        repeat (36) @(posedge clk) rst = 0;
        check("rdy low", rdy, 1'h1);
        @(posedge clk) check("txd gets data", txd, data[0]); 
        @(posedge clk) check("txd gets data", txd, data[1]); 
        @(posedge clk) check("txd gets data", txd, data[2]); 
        @(posedge clk) check("txd gets data", txd, data[3]); 
        @(posedge clk) check("txd gets data", txd, data[4]); 
        @(posedge clk) check("txd gets data", txd, data[5]); 
        @(posedge clk) check("txd gets data", txd, data[6]); 
        @(posedge clk) check("txd gets data", txd, data[7]); 
    
        rst = 1'h1; we = 1'h0; re = 1'h0; clr = 1'h1;
      endtask
        
      initial begin
        data = 8'b00000000;
        send = 0;
        rst = 1;
        we = 0;
        re = 0;
        clr = 1'h0;
        
        check_add_0x30;
        check_add_0xe3;
        check_add_0x33;
        check_add_0xff;
        check_summary_stop;
        end
endmodule
