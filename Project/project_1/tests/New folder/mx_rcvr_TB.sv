`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/22/2016 12:54:50 PM
// Design Name: 
// Module Name: mx_rcvr_TB
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


module mx_rcvr_TB;

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
    
    check_short_data_frame;    
    check_long_data_frame;
    check_receive_rxd_low_error;
    check_receive_rxd_high_error;

    check_summary();
    $stop();
end



//a
task check_short_data_frame;
    check_group_begin("Verification of error, write, data, and cardet with a single byte");


    rxd = 1;#5000; //start high
    
    send_Preamble_16;
    send_SFD;
    //sending 00
    send_ff;
    send_one;
    #100
    
    check_ok("write is high at the end of the eight bit", 1, write);
    check_ok("data is ff when write is asserted", 8'hff, data);
    check_ok("error remains low after successful transmission", 0, error);
    
    rxd = 1; #50000; // end high
    check_ok("write is low after EOF", 0, write);
    check_ok("cardet is low after EOF", 0, cardet);
    check_ok("error remains low after successful transmission", 0, error);
    check_group_end();
    
endtask

//b
task check_long_data_frame;
    check_group_begin("Verification of error, write, data, and cardet with a 24 bytes");
    rxd = 1;#5000; //start high

    send_Preamble_16;
    send_SFD;
    send_one;
    send_11;
    rxd = 0; #100;
    check_ok("data is 11 when write is asserted", 8'h11, data);
    check_ok("write is high at the end of the eight bit", 1, write);
    check_ok("error remains low during reception", 0, error);
    check_ok("cardet stays high when changing bytes during reception", 1, cardet);
    #400;
    rxd = 1; #500;   
    send_22;
    rxd = 1; #100;
    check_ok("data is 22 when write is asserted", 8'h22, data);
    check_ok("write is high at the end of the eight bit", 1, write);
    check_ok("error remains low during reception", 0, error);
    check_ok("cardet stays high when changing bytes during reception", 1, cardet);
    #400;
    rxd = 0; #500;
    send_33;
    rxd = 0; #100;    
    check_ok("data is 33 when write is asserted", 8'h33, data);
    check_ok("write is high at the end of the eight bit", 1, write);
    check_ok("error remains low during reception", 0, error);
    check_ok("cardet stays high when changing bytes during reception", 1, cardet);
    #400;
    rxd = 1; #500;
    send_44;
    rxd = 1; #100;
    check_ok("data is 44 when write is asserted", 8'h44, data);
    check_ok("write is high at the end of the eight bit", 1, write);
    check_ok("error remains low during reception", 0, error);
    check_ok("cardet stays high when changing bytes during reception", 1, cardet);
    #400;
    rxd = 0; #500;      
    send_55;
    rxd = 0; #100;    
    check_ok("data is 55 when write is asserted", 8'h55, data);
    check_ok("write is high at the end of the eight bit", 1, write);
    check_ok("error remains low during reception", 0, error);
    check_ok("cardet stays high when changing bytes during reception", 1, cardet);
    #400;
    rxd = 1; #500;  
    send_66;
    rxd = 1; #100;    
    check_ok("data is 66 when write is asserted", 8'h66, data);
    check_ok("write is high at the end of the eight bit", 1, write);
    check_ok("error remains low during reception", 0, error);
    check_ok("cardet stays high when changing bytes during reception", 1, cardet);
    #400;
    rxd = 0; #500;  
    send_77;
    rxd = 0; #100;    
    check_ok("data is 77 when write is asserted", 8'h77, data);
    check_ok("write is high at the end of the eight bit", 1, write);
    check_ok("error remains low during reception", 0, error);
    check_ok("cardet stays high when changing bytes during reception", 1, cardet);
    #400;
    rxd = 1; #500;  
    send_88;
    rxd = 1; #100;    
    check_ok("data is 88 when write is asserted", 8'h88, data);
    check_ok("write is high at the end of the eight bit", 1, write);
    check_ok("error remains low during reception", 0, error);
    check_ok("cardet stays high when changing bytes during reception", 1, cardet);
    #400;
    rxd = 0; #500;  
    send_99;
    rxd = 0; #100;    
    check_ok("data is 99 when write is asserted", 8'h99, data);
    check_ok("write is high at the end of the eight bit", 1, write);
    check_ok("error remains low during reception", 0, error);
    check_ok("cardet stays high when changing bytes during reception", 1, cardet);
    #400;
    rxd = 1; #500;  
    send_aa;
    rxd = 1; #100;    
    check_ok("data is aa when write is asserted", 8'haa, data);
    check_ok("write is high at the end of the eight bit", 1, write);
    check_ok("error remains low during reception", 0, error);
    check_ok("cardet stays high when changing bytes during reception", 1, cardet);
    #400;
    rxd = 0; #500;  
    send_bb;
    rxd = 0; #100;    
    check_ok("data is bb when write is asserted", 8'hbb, data);
    check_ok("write is high at the end of the eight bit", 1, write);
    check_ok("error remains low during reception", 0, error);
    check_ok("cardet stays high when changing bytes during reception", 1, cardet);
    #400;
    rxd = 1; #500;  
    send_cc;
    rxd = 1; #100;    
    check_ok("data is cc when write is asserted", 8'hcc, data);
    check_ok("write is high at the end of the eight bit", 1, write);
    check_ok("error remains low during reception", 0, error);
    check_ok("cardet stays high when changing bytes during reception", 1, cardet);
    #400;
    rxd = 0; #500;  
    send_dd;
    rxd = 0; #100;    
    check_ok("data is dd when write is asserted", 8'hdd, data);
    check_ok("write is high at the end of the eight bit", 1, write);
    check_ok("error remains low during reception", 0, error);
    check_ok("cardet stays high when changing bytes during reception", 1, cardet);
    #400;
    rxd = 1; #500;  
    send_ee;
    rxd = 1; #100;
    check("data is ee when write is asserted", 8'hee, data);
    check_ok("write is high at the end of the eight bit", 1, write);
    check_ok("error remains low during reception", 0, error);
    check_ok("cardet stays high when changing bytes during reception", 1, cardet);
    #400;
    rxd = 0; #500;  
    send_ff;
    rxd = 0; #100;    
    check_ok("data is ff when write is asserted", 8'hff, data);
    check_ok("write is high at the end of the eight bit", 1, write);
    check_ok("error remains low during reception", 0, error);
    check_ok("cardet stays high when changing bytes during reception", 1, cardet);
    #400;
    rxd = 1; #500;  
    send_00;
    rxd = 1; #100;    
    check_ok("data is 00 when write is asserted", 8'h00, data);
    check_ok("write is high at the end of the eight bit", 1, write);
    check_ok("error remains low during reception", 0, error);
    check_ok("cardet stays high when changing bytes during reception", 1, cardet);    
    #400;
    rxd = 0; #500;
    send_11;
    rxd = 0; #100;
    check_ok("data is 11 when write is asserted", 8'h11, data);
    check_ok("write is high at the end of the eight bit", 1, write);
    check_ok("error remains low during reception", 0, error);
    check_ok("cardet stays high when changing bytes during reception", 1, cardet);
    #400;
    rxd = 1; #500;   
    send_22;
    rxd = 1; #100;
    check_ok("data is 22 when write is asserted", 8'h22, data);
    check_ok("write is high at the end of the eight bit", 1, write);
    check_ok("error remains low during reception", 0, error);
    check_ok("cardet stays high when changing bytes during reception", 1, cardet);
    #400;
    rxd = 0; #500;
    send_33;
    rxd = 0; #100;    
    check_ok("data is 33 when write is asserted", 8'h33, data);
    check_ok("write is high at the end of the eight bit", 1, write);
    check_ok("error remains low during reception", 0, error);
    check_ok("cardet stays high when changing bytes during reception", 1, cardet);
    #400;
    rxd = 1; #500;
    send_44;
    rxd = 1; #100;
    check_ok("data is 44 when write is asserted", 8'h44, data);
    check_ok("write is high at the end of the eight bit", 1, write);
    check_ok("error remains low during reception", 0, error);
    check_ok("cardet stays high when changing bytes during reception", 1, cardet);
    #400;
    rxd = 0; #500;      
    send_55;
    rxd = 0; #100;    
    check_ok("data is 55 when write is asserted", 8'h55, data);
    check_ok("write is high at the end of the eight bit", 1, write);
    check_ok("error remains low during reception", 0, error);
    check_ok("cardet stays high when changing bytes during reception", 1, cardet);
    #400;
    rxd = 1; #500;  
    send_66;
    rxd = 1; #100;    
    check_ok("data is 66 when write is asserted", 8'h66, data);
    check_ok("write is high at the end of the eight bit", 1, write);
    check_ok("error remains low during reception", 0, error);
    check_ok("cardet stays high when changing bytes during reception", 1, cardet);
    #400;
    rxd = 0; #500;  
    send_77;
    rxd = 0; #100;    
    check_ok("data is 77 when write is asserted", 8'h77, data);
    check_ok("write is high at the end of the eight bit", 1, write);
    check_ok("error remains low during reception", 0, error);
    check_ok("cardet stays high when changing bytes during reception", 1, cardet);
    #400;
    rxd = 1; #500;  
    send_88;
    rxd = 1; #100;    
    check_ok("data is 88 when write is asserted", 8'h88, data);
    check_ok("write is high at the end of the eight bit", 1, write);
    check_ok("error remains low during reception", 0, error);
    check_ok("cardet stays high when changing bytes during reception", 1, cardet);
    #400;
    rxd = 0; #500;  
    send_99;
    rxd = 0; #100;    
    check_ok("data is 99 when write is asserted", 8'h99, data);
    check_ok("write is high at the end of the eight bit", 1, write);
    check_ok("error remains low during reception", 0, error);
    check_ok("cardet stays high when changing bytes during reception", 1, cardet);
    #400;
    rxd = 1; #500;  
    send_aa;
    rxd = 1; #100;    
    check_ok("data is aa when write is asserted", 8'haa, data);
    check_ok("write is high at the end of the eight bit", 1, write);
    check_ok("error remains low during reception", 0, error);
    check_ok("cardet stays high when changing bytes during reception", 1, cardet);
    #400;
    rxd = 0; #500;  
    send_bb;
    rxd = 0; #100;    
    check_ok("data is bb when write is asserted", 8'hbb, data);
    check_ok("write is high at the end of the eight bit", 1, write);
    check_ok("error remains low during reception", 0, error);
    check_ok("cardet stays high when changing bytes during reception", 1, cardet);
    #400;
    rxd = 1; #500;  
    send_cc;
    rxd = 1; #100;    
    check_ok("data is cc when write is asserted", 8'hcc, data);
    check_ok("write is high at the end of the eight bit", 1, write);
    check_ok("error remains low during reception", 0, error);
    check_ok("cardet stays high when changing bytes during reception", 1, cardet);
    #400;
    rxd = 0; #500;  
    send_dd;
    rxd = 0; #100;    
    check_ok("data is dd when write is asserted", 8'hdd, data);
    check_ok("write is high at the end of the eight bit", 1, write);
    check_ok("error remains low during reception", 0, error);
    check_ok("cardet stays high when changing bytes during reception", 1, cardet);
    #400;
    rxd = 1; #500;  
    send_ee;
    rxd = 1; #100;
    check_ok("data is ee when write is asserted", 8'hee, data);
    check_ok("write is high at the end of the eight bit", 1, write);
    check_ok("error remains low during reception", 0, error);
    check_ok("cardet stays high when changing bytes during reception", 1, cardet);
    #400;
    rxd = 0; #500;  
    send_ff;
    rxd = 0; #100;    
    check_ok("data is ff when write is asserted", 8'hff, data);
    check_ok("write is high at the end of the eight bit", 1, write);
    check_ok("error remains low during reception", 0, error);
    check_ok("cardet stays high when changing bytes during reception", 1, cardet);
    #400;
    rxd = 1; #500;  
    send_00;
    rxd = 1; #100;    
    check_ok("data is 00 when write is asserted", 8'h00, data);
    check_ok("write is high at the end of the eight bit", 1, write);
    check_ok("error remains low during reception", 0, error);
    check_ok("cardet stays high when changing bytes during reception", 1, cardet);    
    
    rxd = 1;#4900; //EOF
    check_ok("cardet is low after EOF", 0, cardet);
    check_ok("write is low after EOF", 0, write);
    check_ok("error is low after successful transmission", 0, error);

    check_group_end();
endtask



//d
task check_receive_rxd_low_error;
    check_group_begin("Checks receiver functionality when an error in manchester encoding is received (all low bit)");
    rxd = 1;#5000; //start high
    send_Preamble_16;
    send_SFD;
    
    //sending B2 with error
    send_one;
    send_zero;
    send_one;
    send_one;
    rxd = 0;#1000; //Error in bit, reads a allow low for entire bit period
    send_zero;
    send_one;
    send_zero;
    check_ok("write did not get asserted after receiving byte with an entirely low bit", 0, write);
    check_ok("error was asserted after receiving byte with an entirely low bit", 1, error);
    check_ok("cardet is low after error of receiving byte with an entirely low bit", 0, cardet);
    check_group_end();
endtask

//e 
task check_receive_rxd_high_error;
    check_group_begin("Checks receiver functionality when an error in manchester encoding is received (all high bit)");
    rxd = 1;#5000; //start high
    send_Preamble_16;
    send_SFD;
    
    //sending B2 with error
    send_one;
    send_zero;
    send_one;
    send_one;
    rxd = 1;#1000; //Error in bit, reads a allow low for entire bit period
    send_zero;
    send_one;
    send_zero;
    check_ok("write did not get asserted after receiving byte with an entirely high bit", 0, write);
    check_ok("error was asserted after receiving byte with an entirely high bit", 1, error);
    check_ok("cardet is low after error of receiving byte with an entirely high bit", 0, cardet);
    check_group_end();
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

task send_00;
   // send_zero;
    send_zero;
    send_zero;
    send_zero;
    send_zero;
    send_zero;
    send_zero;
    send_zero;
    
endtask

task send_11;
    //send_one;
    send_zero;
    send_zero;
    send_zero;
    send_one;
    send_zero;
    send_zero;
    send_zero;


endtask

task send_22;
    //send_zero;
    send_one;
    send_zero;
    send_zero;
    send_zero;
    send_one;
    send_zero;
    send_zero;
    

endtask

task send_33;
    //send_one;
    send_one;
    send_zero;
    send_zero;
    send_one;
    send_one;
    send_zero;
    send_zero;

endtask

task send_44;
    //send_zero;
    send_zero;
    send_one;
    send_zero;
    send_zero;
    send_zero;
    send_one;    
    send_zero;


endtask

task send_55;
    //send_one;
    send_zero;
    send_one;
    send_zero;
    send_one;
    send_zero;
    send_one;
    send_zero;

endtask

task send_66;
    //send_zero;
    send_one;
    send_one;
    send_zero;
    send_zero;
    send_one;
    send_one;
    send_zero;



endtask

task send_77;
    //send_one;
    send_one;
    send_one;
    send_zero;
    send_one;
    send_one;
    send_one;
    send_zero;
    

endtask

task send_88;
    //send_zero;
    send_zero;
    send_zero;
    send_one;
    send_zero;
    send_zero;
    send_zero;
    send_one;



endtask

task send_99;
    //send_one;
    send_zero;
    send_zero;
    send_one;
    send_one;
    send_zero;
    send_zero;
    send_one;


endtask

task send_aa;
    //send_zero;
    send_one;
    send_zero;
    send_one;
    send_zero;
    send_one;
    send_zero;    
    send_one;  
    

endtask

task send_bb;
    //send_one;
    send_one;
    send_zero;
    send_one;
    send_one;
    send_one;   
    send_zero;    
    send_one;
    

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

task send_dd;
    //send_one;
    send_zero;
    send_one;
    send_one;
    send_one;    
    send_zero;   
    send_one;
    send_one;


endtask

task send_ee;
    //send_zero;
    send_one;
    send_one;    
    send_one;
    send_zero;    
    send_one;
    send_one;
    send_one;


endtask

task send_ff;
    //send_one;
    send_one;
    send_one;
    send_one;
    send_one;
    send_one;    
    send_one;
    send_one;
 
endtask

endmodule
