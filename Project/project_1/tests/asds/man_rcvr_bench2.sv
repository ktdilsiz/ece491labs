`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/22/2016 02:13:58 PM
// Design Name: 
// Module Name: man_rcvr_bench2
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


module man_rcvr_bench2;

    import check_p::*;
    
    parameter SAMP_PER_BIT = 64;
    parameter BIT_RATE = 50_000;
    parameter SAMP_RATE = SAMP_PER_BIT * BIT_RATE;
    parameter MX_BIT_WIDTH = 100_000_000/BIT_RATE;
    
    
    // Input Logic
    logic clk, rst, rxd;
    
    // Output Logic
    logic cardet, write, err;
    logic[7:0] data;
    
    //Intermediate Values
    logic [7:0] message;
    
    // Receiver Module Instantiation
    // Change parameter names above and here to match those in your own module
    mx_rcvr2 #(.BAUD(BIT_RATE)) U_RCVR(.clk, .rst, .rxd, .cardet, .write, .error(err), .data);
    
    // Used to create random data when no active transmission is occuring
    logic rand_data;
    always @(posedge clk) begin
      #1; // toggle data after clock edge
      if ($urandom_range(100,1) <= 50) rand_data = 1;
      else rand_data = 0;
    end
    
    // Random data when not actively receiving data
    // Input: Number of clock cycles of no data desired
    task noTransmission(input integer rand_cycles);
        begin
            integer i;
            for(i=0;i<rand_cycles;i++)
                begin
                    rxd = rand_data;
                    @(posedge clk) #1;
                end
        end
    endtask
    
  // Manchester Zero bit
      task zero;
          begin
              rxd = 0;
              repeat (MX_BIT_WIDTH/2) @(posedge clk) #1;
              rxd = 1;
              repeat (MX_BIT_WIDTH/2) @(posedge clk) #1;
          end
      endtask
      
      // Manchester One bit
      task one;
          begin
              rxd = 1;
              repeat (MX_BIT_WIDTH/2) @(posedge clk) #1;
              rxd = 0;
              repeat (MX_BIT_WIDTH/2) @(posedge clk) #1;
          end
      endtask
    
    // Reset the system after every test
    task resetSystem;
        begin
            rst = 1;
            repeat (10) @(posedge clk) #1;
            rst = 0;
            repeat (10) @(posedge clk) #1;
        end
    endtask
    
    //Generates the manchester bits of a provided message
    task produceBits(input logic bit_val);
        begin
            if(bit_val == 1) one;
            else zero;
        end
    endtask
    
    //Generate 1-Byte Preamble signal beginning with a 1
    task genPreambleHigh;
        begin
            integer i;
            for(i = 0; i < 4; i++)
                begin
                    one;
                    zero;
                end
        end
    endtask
    
    //Generate 1-Byte Preamble signal beginning with a 0
    task genLowPreamble;
        begin
            integer i;
            for(i = 0; i < 4; i++)
                begin
                    zero;
                    one;
                end
        end
    endtask
    
    //Generate SFD signal
    task genSFD;
        begin
            repeat (4) zero;                                    
            one;
            zero;
            repeat (2) one;
        end
    endtask
    
    //Generate 1-Byte EOF signal
    task genEOF;
        begin
            rxd = 1;
            repeat (MX_BIT_WIDTH) @(posedge clk) #1;
        end
    endtask
    
    //Generate a signal that is low for entire bit to cause ERROR
    task genLowError;
        begin
            rxd = 0;
            repeat (MX_BIT_WIDTH) @(posedge clk) #1;
        end
    endtask
    
    //Send one valid byte of data
    task oneByte(input logic [7:0] msg);
        begin
            integer i;
            for(i = 0; i < 8; i++)
                begin
                    produceBits(msg[i]);
                end
        end
    endtask
    
    //Send six bits to receiver
    task sixBit(input logic [5:0] msg);
        begin
        integer i;
        for(i = 0; i < 6; i++)
            begin
                produceBits(msg[i]);
            end
        end
    endtask
            
    
    //Check for transmission of one valid byte beginning and ending with constant high
    task checkOneByte(input logic [7:0] msg);
        begin
            message = msg;
            rxd = 1;
            repeat (1000) @(posedge clk) #1;
            check_ok("cardet LOW before synchronization pattern. Module Function Test 2.0.m", cardet, 0);
            genPreambleHigh;
            check_ok("cardet HIGH after 8 bits of preamble. Module Function Test 2.0.a.", cardet, 1);
            genPreambleHigh;
            check_ok("cardet HIGH after 16 bits of preamble. Module Function Test 2.0.b.", cardet, 1);
            genSFD;
            check_ok("cardet HIGH after SFD. Module Function Test 2.0.b.", cardet, 1);
            oneByte(msg);
            //check_ok("write HIGH after 8-bits of data received. Module Function Test 2.0.e.", write, 1);
            check_ok("cardet HIGH after valid byte. Module Function Test 2.0.b.", cardet, 1);
            check_ok("data matches message provied to receiver when all bits received. Module Function Test 2.0.i.", data, msg);
            genEOF;
            genEOF;
            check_ok("data matches message provided to receiver. Module Function Test 2.0.k.", data, msg);
            check_ok("cardet LOW after EOF. Module Function Test 2.0.d.", cardet, 0);
            rxd = 1;
            repeat (1000) @(posedge clk) #1;
            check_ok("data matches message provided to receiver. Module Function Test 2.0.m.", data, msg);
            check_ok("cardet LOW after EOF pattern. Module Function Test 2.0.m", cardet, 0);
            noTransmission(1000);
            check_ok("EOF is properly recognized by receiver. Module Function Test 2.0.l", data, msg);
            check_ok("data matches last data transmitted to receiver. Module Function Test 2.0.j.", data, msg);         
        end
    endtask
    
    //Check transmission of 6-bits and EOF
    task checkSixBits(input logic [5:0] msg);
        begin
            message = {2'b00,msg};
            genPreambleHigh;
            genPreambleHigh;
            check_ok("cardet HIGH after 8 bits of preamble. Module Function Test 2.0.a.", cardet, 1);
            genPreambleHigh;
            check_ok("cardet HIGH after 16 bits of preamble. Module Function Test 2.0.b.", cardet, 1);
            genSFD;
            check_ok("cardet HIGH after SFD. Module Function Test 2.0.b.", cardet, 1);
            sixBit(msg);
            genEOF;
            genEOF;
            check_ok("error HIGH after EOF. Module Function Test 2.0.g.", err, 1);
            genPreambleHigh;
            genPreambleHigh;
            genSFD;
            check_ok("error LOW after valid synchronization pattern received. Module Function Test 2.0.h.", err, 0);
        end
    endtask
    
    //Check cardet deactivates if preamble is not followed by SFD
    task checkSFD;
        begin
            genPreambleHigh;
            check_ok("cardet HIGH after 8-bits of preamble detected. Module Function Test 2.0.a.", cardet, 1);
            genPreambleHigh;
            noTransmission(50000);
            check_ok("cardet LOW when SFD not received after preamble. Module Function Test 2.0.c.", cardet, 0);
        end
    endtask
    
    //Check error triggered when both halved of bit are low
    task checkErrLow;
        begin
            genPreambleHigh;
            genPreambleHigh;
            genSFD;
            genLowError;
            check_ok("err HIGH when rxd is low for both halves of bit. Module Function Test 2.0.f.", err, 1);
        end
    endtask
    
    //Check transmission of 24 Bytes
    task check24Bytes;
        begin
            integer i;
            rxd = 1;
            repeat (1000) @(posedge clk) #1;
            genPreambleHigh;
            genPreambleHigh;
            genSFD;
            for(i = 0; i < 24; i++)
                begin
                    message = i;
                    oneByte(message);
                    //check_ok("write HIGH after every byte received. Module Function Test 2.0.n.", write, 1);
                end
            genEOF;
            genEOF;
            rxd = 1;
            repeat (1000) @(posedge clk) #1;
            check_ok("data matches last byte transmitted. Module Function Test 2.0.n.", data, i-1);
        end
    endtask
    
    //Check transmission of 1 Byte of data with 10^6 random cycles before and after data
    task checkLargeRandom(input logic [7:0] msg, input logic [7:0] msg1);
        begin
            message = msg;
            genPreambleHigh;
            genPreambleHigh;
            genSFD;
            oneByte(msg);
            genEOF;
            genEOF;
            noTransmission(1_000_000 * SAMP_RATE * 2);
            check_ok("data matches first msg provided. Module Function Test 2.0.o.", data, msg);
            message = msg1;
            genPreambleHigh;
            check_ok("cardet HIGH after 8-bits of valid preamble. Module Function Test 2.0.a.", cardet, 1);
            genPreambleHigh;
            genSFD;
            oneByte(msg1);
            genEOF;
            genEOF;
            noTransmission(1_000_000 * SAMP_RATE);
            check_ok("data matches second msg provided. Module Function Test 2.0.o.", data, msg1);
        end
    endtask
    
    // clock generator
    always
        begin
            clk = 0;
            #5 clk = 1;
            #5;
        end
        
    initial
        begin
            resetSystem;
            checkOneByte(8'haa);
            resetSystem;
            checkSixBits(6'b111111);
            resetSystem;
            checkSFD;
            resetSystem;
            checkErrLow;
            resetSystem;
            check24Bytes;
            resetSystem;
//            checkLargeRandom(8'h55, 8'h10);
            check_summary_stop;            
        end

endmodule
