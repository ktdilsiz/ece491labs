`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/20/2016 02:03:46 PM
// Design Name: 
// Module Name: mx_rcvr_testbench
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


module mx_rcvr_testbench();
    import check_p1::*; 
    
    integer i = 0;
    
    parameter BIT_RATE = 50_000;
    parameter N = 2; // Length of end of frame (in bit periods) 
    parameter BD_CLK_LEN = (100_000_000 / BIT_RATE) / 2;
    parameter ERROR_RATE = 50; // % prob. of error
    
    logic bit_clk, clk; 
    logic reset; 
    logic rxd; 
    logic cardet; 
    logic [7:0] data_out;
    logic write; 
    logic error;
    
    logic [7:0] temp_data, data_in;
    logic rxd_noisy, rxd_in;
    logic noise_error, noise_on; 
    
    mx_rcvr2 #(.BIT_RATE(BIT_RATE), .BAUD(BIT_RATE) ) 
            DUV (.clk(clk), .rst(reset), .rxd(rxd_in), .cardet(cardet), .data(data_out), .write(write), .error(error));
    
    // simulation clk = 100MHz.
    always begin
        clk = 0; 
        #5; clk = 1; 
        #5;
    end
    
    always begin
        bit_clk = 0; 
        #(BD_CLK_LEN); bit_clk = 1; 
        #(BD_CLK_LEN);
    end
    
    always @(posedge bit_clk) begin
        #1; // inject error (if any) after clock edge
        if ($urandom_range(100,1) <= ERROR_RATE) noise_error = 1;
        else noise_error = 0;
    end
    
    assign rxd_noisy = rxd ^ noise_error; 
    assign rxd_in = (noise_on) ? rxd_noisy : rxd;
    
    initial begin
        noise_on = 1'b0;
        rxd = 1'b1; 
        repeat(1*BD_CLK_LEN) @(posedge clk);
        reset = 1'b1; 
        repeat(10*BD_CLK_LEN) @(posedge clk); 
        reset = 1'b0;
        repeat(5*BD_CLK_LEN) @(posedge clk); 
        
        test_10a();
        repeat(20*BD_CLK_LEN) @(posedge clk);
        test_10b();
        repeat(20*BD_CLK_LEN) @(posedge clk);
        // test_10c();
        // repeat(20*BD_CLK_LEN) @(posedge clk);
        test_10d();
        repeat(20*BD_CLK_LEN) @(posedge clk);
        test_10e();
        repeat(20*BD_CLK_LEN) @(posedge clk);
        
        check_summary();                   
        $stop;
    end
    
    task send_mx_bit(input val);
        rxd = val; 
        repeat(BD_CLK_LEN) @(posedge clk); 
        rxd = ~val; 
        repeat(BD_CLK_LEN) @(posedge clk);
    endtask
    
    task send_EOF_bit();
         rxd = 1'b1;
         repeat(2*BD_CLK_LEN) @(posedge clk);
    endtask
    
    task send_low_error();
        rxd = 1'b0;
        repeat(2*BD_CLK_LEN) @(posedge clk);
    endtask
    
    task send_mx_byte(input[7:0] data);
        check("cardet, pre-byte", cardet, 1);
        check("error, pre-byte", error, 0);
        send_mx_bit(data[0]); 
        send_mx_bit(data[1]); 
        send_mx_bit(data[2]); 
        send_mx_bit(data[3]); 
        send_mx_bit(data[4]); 
        send_mx_bit(data[5]); 
        send_mx_bit(data[6]); 
        send_mx_bit(data[7]);
        temp_data = data;
        fork
        begin 
//            repeat (5) @(posedge clk); #1;
            @(write); @(posedge clk); #1;
            check("cardet, post-byte", cardet, 1); 
            check("error, post-byte", error, 0);
            check("data, post-byte", data_out, temp_data);
            check("write, post-byte", write, 1);
        end
        join_none
    endtask
    
    task send_mx_byte_expect_fail(input[7:0] data);
        check("cardet, pre-byte", cardet, 0);
        check("error, pre-byte", error, 1);
        send_mx_bit(data[0]); 
        send_mx_bit(data[1]); 
        send_mx_bit(data[2]); 
        send_mx_bit(data[3]); 
        send_mx_bit(data[4]); 
        send_mx_bit(data[5]); 
        send_mx_bit(data[6]); 
        send_mx_bit(data[7]);
        check("cardet, post-byte", cardet, 0); 
        check("error, post-byte", error, 1);
    endtask
        
    task send_preamble_bit_pair();
        send_mx_bit(1'b1); 
        send_mx_bit(1'b0); 
    endtask
    
    task send_SFD();
         check("cardet, pre-SFD", cardet, 1);
         send_mx_bit(1'b0); 
         send_mx_bit(1'b0);
         send_mx_bit(1'b0); 
         send_mx_bit(1'b0);
         send_mx_bit(1'b1); 
         send_mx_bit(1'b0);
         send_mx_bit(1'b1); 
         send_mx_bit(1'b1);
         check("cardet, post-SFD", cardet, 1);
    endtask
    
    task send_EOF(input integer n);
        repeat(n) send_EOF_bit(); 
        check("cardet, pre-EOF", cardet, 0);
    endtask
    
    // 24-bit preamble/SFD, single byte, rxd high before/after
    task test_10a();
        check_group_begin("Requirement test 10a - 24-bit preamble/SFD, single byte, rxd high before/after");
        reset = 1'b1;
        @(posedge clk);
        reset = 1'b0;
        @(posedge clk);
        noise_on = 1'b0;
        rxd = 1'b1;
        repeat(10) @(posedge clk);
        repeat(8) send_preamble_bit_pair();
        send_SFD();
        send_mx_byte(8'h33);
        send_EOF(N);
        rxd = 1'b1;
        repeat(10) @(posedge clk);
        check_group_end();
    endtask
    
    // 24-bit preamble/SFD, 24 (or more) bytes, rxd high before/after
    task test_10b();
        check_group_begin("Requirement test 10b - 24-bit preamble/SFD, 24 (or more) bytes, rxd high before/after");
        reset = 1'b1;
        @(posedge clk);
        reset = 1'b0;
        @(posedge clk);
        noise_on = 1'b0;
        rxd = 1'b1;
        repeat(2*BD_CLK_LEN) @(posedge clk);
        repeat(8) send_preamble_bit_pair();
        send_SFD();
        for (i=0; i<24; i++) begin
            data_in = {$random } % 255;
            send_mx_byte(data_in);
        end
        send_EOF(N);
        rxd = 1'b1;
        repeat(2*BD_CLK_LEN) @(posedge clk);
        check_group_end();
    endtask
    
    // 24-bit preamble/SFD, one byte, rxd random before/after
    task test_10c();
        check_group_begin("Requirement test 10c - 24-bit preamble/SFD, single byte, rxd random before/after");
        reset = 1'b1;
        @(posedge clk);
        reset = 1'b0;
        @(posedge clk);
        noise_on = 1'b1;
        rxd = 1'b1;
        repeat(1000000) begin
            repeat(BD_CLK_LEN) @(posedge clk);
//            data_in = {$random } % 1;
//            send_mx_bit(data_in);
        end
        noise_on = 1'b0;
        repeat(8) send_preamble_bit_pair();
        send_SFD();
        send_mx_byte(8'h33);
        send_EOF(N);
        noise_on = 1'b1;
        rxd = 1'b1;
        repeat(1000000) begin
           repeat(BD_CLK_LEN) @(posedge clk);
//            data_in = {$random } % 1;
//            send_mx_bit(data_in);
        end
        noise_on = 1'b0;
        check_group_end();
    endtask
    
    // erroneous full low bit within frame
    task test_10d();
        check_group_begin("Requirement test 10d - erroneous full low bit within frame");
        reset = 1'b1;
        @(posedge clk);
        reset = 1'b0;
        @(posedge clk);
        noise_on = 1'b0;
        rxd = 1'b1;
        repeat(2*BD_CLK_LEN) @(posedge clk);
        repeat(8) send_preamble_bit_pair();
        send_SFD();
        for (i=0; i<24; i++) begin
            data_in = {$random } % 255;
            if (i < 12) send_mx_byte(data_in);
            else if (i == 12) begin
                check("cardet, pre-byte", cardet, 1);
                check("error, pre-byte", error, 0);
                send_mx_bit(data_in[0]);
                send_low_error();
                check("cardet, post-low", cardet, 0);
                check("error, post-low", error, 1);
                send_mx_bit(data_in[2]); 
                send_mx_bit(data_in[3]); 
                send_mx_bit(data_in[4]); 
                send_mx_bit(data_in[5]); 
                send_mx_bit(data_in[6]); 
                send_mx_bit(data_in[7]);
            end
            else send_mx_byte_expect_fail(data_in);
        end
        send_EOF(N);
        rxd = 1'b1;
        repeat(2*BD_CLK_LEN) @(posedge clk);
        check_group_end();
    endtask
    
    // erroneous byte ends early
    task test_10e();
        check_group_begin("Requirement test 10e - erroneous byte ends early");
        reset = 1'b1;
        @(posedge clk);
        reset = 1'b0;
        @(posedge clk);
        noise_on = 1'b0;
        rxd = 1'b1;
        repeat(2*BD_CLK_LEN) @(posedge clk);
        repeat(8) send_preamble_bit_pair();
        send_SFD();
        for (i=0; i<24; i++) begin
            data_in = {$random } % 255;
            if (i == 23) begin
                check("cardet, pre-byte", cardet, 1);
                check("error, pre-byte", error, 0);
                send_mx_bit(data_in[0]);
                send_mx_bit(data_in[1]);
                send_mx_bit(data_in[2]); 
                send_mx_bit(data_in[3]); 
                send_mx_bit(data_in[4]); 
                send_mx_bit(data_in[5]); 
                send_EOF_bit();
                check("cardet, post-early end", cardet, 0);
                check("error, post-early end", error, 1);
                send_EOF_bit();
            end
            else send_mx_byte(data_in);
        end
        send_EOF(N);
        rxd = 1'b1;
        repeat(2*BD_CLK_LEN) @(posedge clk);
        check_group_end();
    endtask
    
endmodule
