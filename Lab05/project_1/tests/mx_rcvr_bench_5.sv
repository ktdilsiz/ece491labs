`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Lafayette College, ECE 491, Lab 5
// Engineer: Meridith Guro, Emilie Grybos
// 
// Create Date: 10/22/2016 10:29:39 AM
// Module Name: mx_rcvr_bench_5
// Project Name: Lab_5
// Target Devices: Nexys4DDR
// Tool Versions: Vivado 2016.2
// Description: In this testbench, we repeat the the tests from mx_rcvr_bench_4 
// with the transmitter and receiver operating at slightly different clock 
// frequencies. Thus, this test measures the frequency error percentage that our 
// Manchester receiver can tolerate. To do so, we multiply the clk of the 
// transmitter by a fraction as defined within the parameter CLK_ADJUST.
// 
// Dependencies: mx_rcvr, transmitter (Lab 3)
//////////////////////////////////////////////////////////////////////////////////


module mx_rcvr_bench_5();
    parameter BIT_TIME = 20_000; //in ns 
    parameter BAUD_TIME = BIT_TIME/2;
    parameter EOF_LEN = 2;
    parameter CLK_ADJUST = 0.05;

    import check_p::*;
    
    integer i;
    logic [7:0] rand_num;
    
    // Receiver Signals
    logic clk, reset, rxd, cardet, write, error;
    logic [7:0] data_out;
    
    // Transmitter Signals
    logic send, rdy, txd, txen;
    logic [7:0] data_in;
    
    mx_rcvr #(.EOF_LEN(EOF_LEN), .BIT_FREQ(20000)) DUV_rcvr( .clk(clk), .reset(reset),
        .rxd(rxd), .cardet(cardet), .data(data_out), .write(write), .error(error) );
    transmitter #(.BIT_RATE(20000), .N(EOF_LEN)) DUV_trsm( .clk(clk*CLK_ADJUST), .reset(reset), 
        .send(send), .data(data_in), .rdy(rdy), .txd(txd), .txen(txen) );
    
    always begin
        clk = 0;
        #5 clk = 1;
        #5;
    end
     
    /*
     * Function called generateByte() that, when called, generates a random data byte.
     */
    function [7:0] generateByte();
        logic [7:0] data;
        data = { $random } % 8'hff;        
        return data;
    endfunction
    
    /*
     * Function called generateManchesterByte() that, when called, manchesterizes the 
     * input data byte.
     */
    function [15:0] generateManchesterByte(input logic [7:0] data);
        logic [15:0] m_data;
        
        for( i = 0; i <= 7; i=i+1 ) begin
            if(data_in[i] == 1) begin
                m_data[i*2] = 1'b0; 
                m_data[i*2+1] = 1'b1;
            end
            else begin
                m_data[i*2] = 1'b1;
                m_data[i*2+1] = 1'b0;
            end
        end
        
        return m_data;
    endfunction
    
    /*
     * Task called check_reset() that verifies that the receiver and transmitter both 
     * output the expected values for each output upon the assertion of reset. 
     */
    task check_reset();
        reset = 0;
        rxd = 1'b1;
        repeat(BIT_TIME) @(posedge clk);
        
        reset = 1;
        rxd = 1'b1;
        repeat(BIT_TIME) @(posedge clk);
        
        check("Check reset - Receiver, rdy", rdy, 1);
        check("Check reset - Receiver, txen", txen, 0);
        check("Check reset - Receiver, txd", txd, 1);
        check("Check reset - Transmitter, cardet", cardet, 0);
        check("Check reset - Transmitter, data", data_out, 0);    
        check("Check reset - Transmitter, write", write, 0);  
        check("Check reset - Transmitter, error", error, 0);  
        repeat(BIT_TIME) @(posedge clk);
        
        reset = 0;
        repeat(BIT_TIME) @(posedge clk);
    endtask
    
    /* 
     * Task called check_sendFrame that sends num_bytes worth of data via our 
     * manchester transmitter and then receives that via the manchester receiver. 
     * Verifies sending and receiving of 16 bits of preamble, SFD, num_bytes of 
     * data, then EOF.
     */
    task check_sendFrame( input logic [9:0] num_bytes );
        integer i, j, y, m, n, x;
        logic [7:0] data, preamble, sfd;
        logic [15:0] m_data, m_preamble, m_sfd;
        
        preamble = 8'b01010101;
        m_preamble = generateManchesterByte(preamble);
        
        sfd = 8'b11010000;
        m_sfd = generateManchesterByte(sfd);
        
        // Preamble (16 bits)
        for( m=0; m<2; m=m+1 ) begin
            for( n=0; n<8; n=n+1 ) begin
                if( j==0 ) begin
                    data_in = preamble;
                    send = 1'b1;
                    repeat(BAUD_TIME) @(posedge clk);
                end
                
                check("Send Frame - Transmitter, Preamble Baud 1, rdy", rdy, 0);
                check("Send Frame - Transmitter, Preamble Baud 1, txen", txen, 1);
                check("Send Frame - Transmitter, Preamble Baud 1, txd", txd, m_preamble[j*2]);
                check("Send Frame - Receiver, Preamble Baud 1, cardet", cardet, 1);
                check("Send Frame - Receiver, Preamble Baud 1, data", data_out, m_preamble[j*2]);
                check("Send Frame - Receiver, Preamble Baud 1, write", write, 0);
                check("Send Frame - Receiver, Preamble Baud 1, error", error, 0);
                repeat(BAUD_TIME) @(posedge clk);
                
                check("Send Frame - Transmitter, Preamble Baud 2, rdy", rdy, 0);
                check("Send Frame - Transmitter, Preamble Baud 2, txen", txen, 1);
                check("Send Frame - Transmitter, Preamble Baud 2, txd", txd, m_preamble[j*2+1]);
                check("Send Frame - Receiver, Preamble Baud 2, cardet", cardet, 1);
                check("Send Frame - Receiver, Preamble Baud 2, data", data_out, m_preamble[j*2+1]);
                check("Send Frame - Receiver, Preamble Baud 2, write", write, 0);
                check("Send Frame - Receiver, Preamble Baud 2, error", error, 0);
                
                send = 0;
                repeat(BAUD_TIME) @(posedge clk);
            end // End transmission of preamble bit
        end // End transmission of preamble
        
        // SFD
        for( x=0; x<8; x=x+1 ) begin
            if( x==0 ) begin
                data_in = sfd;
                send = 1'b1;
                repeat(BAUD_TIME) @(posedge clk);
            end
            
            check("Send Frame - Transmitter, SFD Baud 1, rdy", rdy, 0);
            check("Send Frame - Transmitter, SFD Baud 1, txen", txen, 1);
            check("Send Frame - Transmitter, SFD Baud 1, txd", txd, m_sfd[j*2]);
            check("Send Frame - Receiver, SFD Baud 1, cardet", cardet, 1);
            check("Send Frame - Receiver, SFD Baud 1, data", data_out, m_sfd[j*2]);
            check("Send Frame - Receiver, SFD Baud 1, write", write, 0);
            check("Send Frame - Receiver, SFD Baud 1, error", error, 0);
            repeat(BAUD_TIME) @(posedge clk);
            
            check("Send Frame - Transmitter, SFD Baud 2, rdy", rdy, 0);
            check("Send Frame - Transmitter, SFD Baud 2, txen", txen, 1);
            check("Send Frame - Transmitter, SFD Baud 2, txd", txd, m_sfd[j*2+1]);
            check("Send Frame - Receiver, SFD Baud 2, cardet", cardet, 1);
            check("Send Frame - Receiver, SFD Baud 2, data", data_out, m_sfd[j*2+1]);
            check("Send Frame - Receiver, SFD Baud 2, write", write, 0);
            check("Send Frame - Receiver, SFD Baud 2, error", error, 0);
            
            send = 0;
            repeat(BAUD_TIME) @(posedge clk);
        end // End transmission of SFD
                
        // Data
        for( i=0; i<num_bytes; i=i+1 ) begin
            
            data = generateByte();
            m_data = generateManchesterByte(data);
            
            // Transmission of Data Byte
            for( j=0; j<8; j=j+1 ) begin
                if( j==0 ) begin
                    data_in = data;
                    send = 1'b1;
                    repeat(BAUD_TIME) @(posedge clk);
                end
                
                check("Send Frame - Transmitter, Data Baud 1, rdy", rdy, 0);
                check("Send Frame - Transmitter, Data Baud 1, txen", txen, 1);
                check("Send Frame - Transmitter, Data Baud 1, txd", txd, m_data[j*2]);
                check("Send Frame - Receiver, Data Baud 1, cardet", cardet, 1);
                check("Send Frame - Receiver, Data Baud 1, data", data_out, m_data[j*2]);
                if( j==0 && i!=0 ) check("Send Frame - Receiver, Data Baud 1, write", write, 1);
                else check("Send Frame - Receiver, Data Baud 1, write", write, 0);
                check("Send Frame - Receiver, Data Baud 1, error", error, 0);
                repeat(BAUD_TIME) @(posedge clk);
                
                check("Send Frame - Transmitter, Data Baud 2, rdy", rdy, 0);
                check("Send Frame - Transmitter, Data Baud 2, txen", txen, 1);
                check("Send Frame - Transmitter, Data Baud 2, txd", txd, m_data[j*2+1]);
                check("Send Frame - Receiver, Data Baud 2, cardet", cardet, 1);
                check("Send Frame - Receiver, Data Baud 2, data", data_out, m_data[j*2+1]);
                check("Send Frame - Receiver, Data Baud 2, write", write, 0);
                check("Send Frame - Receiver, Data Baud 2, error", error, 0);
                
                send = 0;
                repeat(BAUD_TIME) @(posedge clk);
            end // end transmission of single data byte 
        end // end transmission of num_bytes of data
        
        // EOF
        for( y=0; y<EOF_LEN; y=y+1 ) begin
            check("Send Frame - Transmitter EOF rdy", rdy, 1);
            check("Send Frame - Transmitter EOF txen", txen, 0);
            check("Send Frame - Transmitter EOF txd", txd, 1);
            check("Send Frame - Receiver EOF cardet", cardet, 1);
            check("Send Frame - Receiver EOF data", data_out, 1);
            if(y==0) check("Send Frame - Receiver EOF write", write, 1);
            else check("Send Frame - Receiver EOF write", write, 0);
            check("Send Frame - Receiver EOF error", error, 0);
            repeat(BAUD_TIME) @(posedge clk);                        
        
            check("Send Frame - Transmitter EOF rdy", rdy, 1);
            check("Send Frame - Transmitter EOF txen", txen, 0);
            check("Send Frame - Transmitter EOF txd", txd, 1);
            check("Send Frame - Receiver EOF cardet", cardet, 1);
            check("Send Frame - Receiver EOF data", data_out, 1);
            check("Send Frame - Receiver EOF write", write, 0);
            check("Send Frame - Receiver EOF error", error, 0);
            repeat(BAUD_TIME) @(posedge clk);
        end // end transmission of EOF
    endtask
    
    initial begin
        check_group_begin("Check reset");
        check_reset();
        check_group_end;
        
        //Check sending one data dyte
        check_group_begin("Sending 1 Byte");
        check_sendFrame(1'd1);
        check_group_end; 
        
        check_group_begin("Check reset");
        check_reset();
        check_group_end;
        
        // Check sending 256 data bytes
        check_group_begin("Sending 256 Bytes");
        check_sendFrame(9'd256);
        check_group_end; 
        
        check_group_begin("Check reset");
        check_reset();
        check_group_end;
        
        // Check sending a random number (1, 256) of bytes
        for( i=0; i<10; i=i+1 ) begin
            rand_num = { $random } % 8'hff;
            $display("Sending %d Bytes", rand_num);
            
            check_group_begin("Sending Random Number of Bytes");
            check_sendFrame(rand_num);
            check_group_end;
            
            check_group_begin("Check reset");
            check_reset();
            check_group_end; 
        end
        
        check_summary_stop();

    end
    
endmodule