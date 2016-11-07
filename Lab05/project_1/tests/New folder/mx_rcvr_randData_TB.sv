`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/25/2016 01:11:29 PM
// Design Name: 
// Module Name: mx_rcvr_randData_TB
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


module mx_rcvr_randData_TB;

import check_p::*;

logic clk, rxd, reset, cardet, write, error;
logic [7:0] data;

mx_rcvr #(.BAUD(1_000_000)) U_MX_RCVR(.clk(clk), .reset(reset), .rxd(rxd), .cardet(cardet), .data(data), .write(write), .error(error));

always
    begin
        clk = 0; #5;
        clk = 1; #5;
    end

initial begin
    rxd = 0;
    reset=1;#1000;
    reset = 0;#1000;

    check_data_inbetween_random;  //This test produces errors every time cardet is falsly asserted

    check_summary();
    $stop();
end



//c

task check_data_inbetween_random;
    check_group_begin("Sends random data, one valid transmission, and more random data. This test checks to see that the correct data is received. It is expected that some test will fail due to the asserting of cardet with a false preamable signal.");

    repeat (15625)
        begin
            send32random;
        end
        
    send_Preamble_16;
    send_SFD;
    send_zero;
    send_cc;
    rxd = 1;
    #100;
    check_ok("data is cc when write is asserted", 8'hcc, data);
    check_ok("write is high at the end of the eight bit", 1, write);
    check_ok("error remains low during reception", 0, error);
    send_EOF;
    
    repeat (15625)
        begin
            send32random;
        end
    check_group_end();
endtask







logic [31:0] ranNum;

task send32random;
    ranNum = {$random} % 999999999;
    rxd = ranNum[0];#1000;check("cardet should not be asserted when random data is occuring", 0, cardet);
    rxd = ranNum[1];#1000; check("cardet should not be asserted when random data is occuring", 0, cardet);
    rxd = ranNum[2];#1000; check("cardet should not be asserted when random data is occuring", 0, cardet);
    rxd = ranNum[3];#1000;check("cardet should not be asserted when random data is occuring", 0, cardet);
    rxd = ranNum[4];#1000; check("cardet should not be asserted when random data is occuring", 0, cardet);
    rxd = ranNum[5];#1000; check("cardet should not be asserted when random data is occuring", 0, cardet);
    rxd = ranNum[6];#1000; check("cardet should not be asserted when random data is occuring", 0, cardet);
    rxd = ranNum[7];#1000; check("cardet should not be asserted when random data is occuring", 0, cardet);
    rxd = ranNum[8];#1000; check("cardet should not be asserted when random data is occuring", 0, cardet);
    rxd = ranNum[9];#1000; check("cardet should not be asserted when random data is occuring", 0, cardet);
    rxd = ranNum[10];#1000; check("cardet should not be asserted when random data is occuring", 0, cardet);
    rxd = ranNum[11];#1000; check("cardet should not be asserted when random data is occuring", 0, cardet);
    rxd = ranNum[12];#1000; check("cardet should not be asserted when random data is occuring", 0, cardet);
    rxd = ranNum[13];#1000; check("cardet should not be asserted when random data is occuring", 0, cardet);
    rxd = ranNum[14];#1000; check("cardet should not be asserted when random data is occuring", 0, cardet);
    rxd = ranNum[15];#1000;check("cardet should not be asserted when random data is occuring", 0, cardet);
    rxd = ranNum[16];#1000; check("cardet should not be asserted when random data is occuring", 0, cardet);
    rxd = ranNum[17];#1000; check("cardet should not be asserted when random data is occuring", 0, cardet);
    rxd = ranNum[18];#1000; check("cardet should not be asserted when random data is occuring", 0, cardet);
    rxd = ranNum[19];#1000;check("cardet should not be asserted when random data is occuring", 0, cardet); 
    rxd = ranNum[20];#1000; check("cardet should not be asserted when random data is occuring", 0, cardet);
    rxd = ranNum[21];#1000; check("cardet should not be asserted when random data is occuring", 0, cardet);
    rxd = ranNum[22];#1000; check("cardet should not be asserted when random data is occuring", 0, cardet);
    rxd = ranNum[23];#1000;check("cardet should not be asserted when random data is occuring", 0, cardet); 
    rxd = ranNum[24];#1000; check("cardet should not be asserted when random data is occuring", 0, cardet);
    rxd = ranNum[25];#1000; check("cardet should not be asserted when random data is occuring", 0, cardet);
    rxd = ranNum[26];#1000; check("cardet should not be asserted when random data is occuring", 0, cardet);
    rxd = ranNum[27];#1000;check("cardet should not be asserted when random data is occuring", 0, cardet);
    rxd = ranNum[28];#1000; check("cardet should not be asserted when random data is occuring", 0, cardet);
    rxd = ranNum[29];#1000; check("cardet should not be asserted when random data is occuring", 0, cardet);
    rxd = ranNum[30];#1000; check("cardet should not be asserted when random data is occuring", 0, cardet);
    rxd = ranNum[31];#1000;check("cardet should not be asserted when random data is occuring", 0, cardet);    
endtask






task send_EOF;
    rxd = 1;#3000;
endtask

task send_one;
    rxd = 1;#500;
    rxd = 0;#500;
endtask

task send_zero;
    rxd = 0;#500;
    rxd = 1;#500;
endtask


task send_Preamble_16;
    repeat(4)
begin
    send_one;
    send_zero;
end
    check_ok("cardet asserted after first 8 bits of preamble", 1, cardet);
    
    repeat(4)
begin
send_one;
send_zero;
end
endtask

task send_SFD;
    send_one;
    send_one;
    send_zero;
    send_one;
    send_zero;
    send_zero;
    send_zero;
    send_zero;
endtask


task send_cc;

    //send_zero;
    send_zero;
    send_one;
    send_one; 
    send_zero;
    send_zero;
    send_one;
    send_one;


endtask





endmodule
