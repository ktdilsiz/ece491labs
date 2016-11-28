`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/22/2016 04:55:46 PM
// Design Name: 
// Module Name: mx_rcvr_transmitter_tb
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


module mx_rcvr_transmitter_tb;


import check_p::*;

logic clk, rxd, reset, cardet, write, error;
logic send;
logic [7:0] dataIn, dataOut, count=0;

//Set EOF to 3 bit periods

mx_rcvr #(.BAUD(1_000_000)) U_MX_RCVR(.clk(clk), .reset(reset), .rxd(rxd), .cardet(cardet), .data(dataOut), .write(write), .error(error));
Transmitter #(.BAUD(1_000_000), .EOFNUM(3),.PACKETLENGTH(8)) U_Transmitter(.data(dataIn),.send(send),.rdy(),.txd(rxd),.txen(),.reset(reset), .clk100MHz(clk));

always
    begin
        clk = 0; #5;
        clk = 1; #5;
    end


initial begin
    send=0;
    dataIn=0;
    reset=1;#1000;
    reset = 0;#1000;
    
    check_one_byte;
    check_256_bytes;
    
    repeat(10)
    begin
    
    check_random_number_of_bytes;   
    #10000;
    end
    
    check_summary();
    $stop();
end


    task check_one_byte;
     check_group_begin("Verification of error, write, data, and cardet with a single byte from Manchester transmitter");
    
    send_preamble_SFD;
    dataIn=8'hff; #2000;
    
    send=0; #7100;
    check("received 8'hff after it was transmitted", 8'hff, dataOut);
    check("write goes high after receiving a bit", 1, write);
    #3000;
    check("error remains low on successful recpection", 0, error); #3900;
    check("Cardet returns low after EOF", 0, cardet);
    check_group_end();
    endtask
    
    
    task check_256_bytes;
        count=0;
        check_group_begin("Verification of error, write, data, and cardet with a 256 bytes from Manchester transmitter");
        send_preamble_SFD;
        #1000;       
        dataIn=8'h11; #7000; 
        repeat(16)
        begin
        count=count+1;
        dataIn=8'h22; #1100;
        check("received 8'h11 after it was transmitted", 8'h11, dataOut);
        check("write goes high after receiving a bit", 1, write);
        check("error remains low on successful recpection", 0, error);
        check("Cardet remains high during reception", 1, cardet);
        #6900
        dataIn=8'h33; #1100;
        check("received 8'h22 after it was transmitted", 8'h22, dataOut);
        check("write goes high after receiving a bit", 1, write);
        check("error remains low on successful recpection", 0, error);
        check("Cardet remains high during reception", 1, cardet);
        #6900
        dataIn=8'h44; #1100;
        check("received 8'h33 after it was transmitted", 8'h33, dataOut);
        check("write goes high after receiving a bit", 1, write);
        check("error remains low on successful recpection", 0, error);
        check("Cardet remains high during reception", 1, cardet);
        #6900
        dataIn=8'h55; #1100;
        check("received 8'h44 after it was transmitted", 8'h44, dataOut);
        check("write goes high after receiving a bit", 1, write);
        check("error remains low on successful recpection", 0, error);
        check("Cardet remains high during reception", 1, cardet);
        #6900
        dataIn=8'h66; #1100;
        check("received 8'h55 after it was transmitted", 8'h55, dataOut);
        check("write goes high after receiving a bit", 1, write);
        check("error remains low on successful recpection", 0, error);
        check("Cardet remains high during reception", 1, cardet);
        #6900
        dataIn=8'h77; #1100;
        check("received 8'h66 after it was transmitted", 8'h66, dataOut);
        check("write goes high after receiving a bit", 1, write);
        check("error remains low on successful recpection", 0, error);
        check("Cardet remains high during reception", 1, cardet);
        #6900
        dataIn=8'h88; #1100;
        check("received 8'h77 after it was transmitted", 8'h77, dataOut);
        check("write goes high after receiving a bit", 1, write);
        check("error remains low on successful recpection", 0, error);
        check("Cardet remains high during reception", 1, cardet);
        #6900
        dataIn=8'h99; #1100;
        check("received 8'h88 after it was transmitted", 8'h88, dataOut);
        check("write goes high after receiving a bit", 1, write);
        check("error remains low on successful recpection", 0, error);
        check("Cardet remains high during reception", 1, cardet);
        #6900
        dataIn=8'haa; #1100;
        check("received 8'h99 after it was transmitted", 8'h99, dataOut);
        check("write goes high after receiving a bit", 1, write);
        check("error remains low on successful recpection", 0, error);
        check("Cardet remains high during reception", 1, cardet);
        #6900
        dataIn=8'hbb; #1100;
        check("received 8'haa after it was transmitted", 8'haa, dataOut);
        check("write goes high after receiving a bit", 1, write);
        check("error remains low on successful recpection", 0, error);
        check("Cardet remains high during reception", 1, cardet);
        #6900
        dataIn=8'hcc; #1100;
        check("received 8'hbb after it was transmitted", 8'hbb, dataOut);
        check("write goes high after receiving a bit", 1, write);
        check("error remains low on successful recpection", 0, error);
        check("Cardet remains high during reception", 1, cardet);
        #6900
        dataIn=8'hdd; #1100;
        check("received 8'hcc after it was transmitted", 8'hcc, dataOut);
        check("write goes high after receiving a bit", 1, write);
        check("error remains low on successful recpection", 0, error);
        check("Cardet remains high during reception", 1, cardet);
        #6900
        dataIn=8'hee; #1100;
        check("received 8'hdd after it was transmitted", 8'hdd, dataOut);
        check("write goes high after receiving a bit", 1, write);
        check("error remains low on successful recpection", 0, error);
        check("Cardet remains high during reception", 1, cardet);
        #6900
        dataIn=8'hff; #1100;
        check("received 8'hee after it was transmitted", 8'hee, dataOut);
        check("write goes high after receiving a bit", 1, write);
        check("error remains low on successful recpection", 0, error);
        check("Cardet remains high during reception", 1, cardet);
        #6900
        dataIn=8'h00; #1100;
        check("received 8'hff after it was transmitted", 8'hff, dataOut);
        check("write goes high after receiving a bit", 1, write);
        check("error remains low on successful recpection", 0, error);
        check("Cardet remains high during reception", 1, cardet);
        #6900;
        if(count<16) begin
        dataIn=8'h11; #1100;
        check("received 8'h00 after it was transmitted", 8'h00, dataOut);
        check("write goes high after receiving a bit", 1, write);
        check("error remains low on successful recpection", 0, error);
        check("Cardet remains high during reception", 1, cardet);
        #6900;
        end
        end
       send = 0;
       #4000;
       check("Cardet remains high in EOF", 1, cardet);
       check("write goes low after EOF", 0, write);
       check("error remains low on successful recpection", 0, error);
       #4000;
       check("Cardet goes low after EOF", 0, cardet);
       check_group_end();
    endtask
       
    logic [7:0] ranNum = 1;

    
    
    task check_random_number_of_bytes;
        check_group_begin("Verifications reception of a random number of bytes from Manchester transmitter");
        ranNum = {$random + 1} % 255;
        send_preamble_SFD;
        #1000;       
        dataIn=8'h11; #7000;
        repeat(ranNum)
        begin
            dataIn=8'h11; #1100;

            check("received 8'h11 after it was transmitted", 8'h11, dataOut);
            check("write goes high after receiving a bit", 1, write);
            check("error remains low on successful recpection", 0, error);
            check("Cardet remains high during reception", 1, cardet);
            #6900;

         end
         
         send = 0;
         #4000;
         check("Cardet remains high in EOF", 1, cardet);
         check("write goes low after EOF", 0, write);
         check("error remains low on successful recpection", 0, error);
         #4000;
         check("Cardet goes low after EOF", 0, cardet);
         check_group_end();       
         
    check_group_end();
    
    endtask
    

    task send_preamble_SFD;
    dataIn=8'h55;
    send=1; #8000;
    check("Cardet was asserted after first eight bits of preamble", 1, cardet); #7000;
    dataIn=8'b00001011; #1000;
    #7000;
    endtask
    
    



endmodule
