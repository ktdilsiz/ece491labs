`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Lafayette College, ECE 491, Lab 5
// Engineer: Meridith Guro, Emilie Grybos
// 
// Create Date: 10/22/2016 10:29:39 AM
// Module Name: mx_rcvr_bench_2
// Project Name: Lab_5
// Target Devices: Nexys4DDR
// Tool Versions: Vivado 2016.2
// Description: In this testbench, we verify the transmission of a short data frame
// of 24-bit preamble/SFD followed by a single data byte. The transmission of this 
// short data frame is followed by 10^6 bit periods of randomly varying input; this
// verifies that our receiver only responds to a correct preamble and SFD pattern.
// Testbench defined in the lab handout Requirements 10.c. 
// 
// Dependencies: mx_rcvr, transmitter (Lab 3)
//////////////////////////////////////////////////////////////////////////////////


module mx_rcvr_bench_2();
    parameter EOF_LEN = 2;
    parameter PREAMBLE_LEN = 16;
    parameter N = $clog2(PREAMBLE_LEN);
    parameter BIT_TIME = 20000; //50kbps
    parameter BAUD_TIME = BIT_TIME/2;

    import check_p::*;
    
    logic clk, reset, rxd, cardet, write, error;
    logic [7:0] data;
    
    mx_rcvr #() DUV( .clk(clk), .rst(reset), .rxd(rxd), .cardet(cardet), .data(data), .write(write), .error(error) );
    
    always begin
        clk = 0;
        #5 clk = 1;
        #5;
    end
    
    /* 
     *
     */
    function [2*(PREAMBLE_LEN)-1+15+15:0] create_Frame(input logic [7:0] data_byte);
        integer i;
        logic [15:0] m_data;
        logic [2*(PREAMBLE_LEN)-1+15:0] m_startFrame;
        logic [2*(PREAMBLE_LEN)-1+15+15:0] m_Frame;
        
        //Create Preamble
        for( i=0; i <= PREAMBLE_LEN-1; i=i+1 ) begin
            if( i%2 == 0 ) begin
                m_startFrame[i*2] = 1'b1; 
                m_startFrame[i*2+1] = 1'b0;
            end
            else begin
                m_startFrame[i*2] = 1'b0;
                m_startFrame[i*2+1] = 1'b1;
            end
        end
        
        //Manchesterize data_byte to be received
        m_data = manchesterize_data(.data_in(data_byte));
        
        //append SFD to start frame
        m_startFrame[2*(PREAMBLE_LEN)-1+15:2*PREAMBLE_LEN] = 16'b0101010110011010;
        
        m_Frame[2*(PREAMBLE_LEN)+15:0] = m_startFrame;
        m_Frame[2*(PREAMBLE_LEN)-1+15+15:2*(PREAMBLE_LEN)+15] = m_data;
        
        return m_Frame;
    endfunction
    
    /*
     *
     */
    function [15:0] manchesterize_data(input logic [7:0] data_in);
        integer i;
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
     *
     */
    task check_reset();
        reset = 0;
        rxd = 1'b1;
        
        repeat(BAUD_TIME) @(posedge clk);
        reset = 1;
        rxd = 1'b1;
        
        repeat(BAUD_TIME) @(posedge clk);
        check("Check reset cardet", cardet, 0);
        check("Check reset data", data, 0);
        check("Check reset write", write, 0);
        check("Check reset error", error, 0);
        
        repeat(BAUD_TIME) @(posedge clk);
        reset = 0;
        
        repeat(BAUD_TIME) @(posedge clk);
    endtask
    
    /*
     * 
     */
    task generate_noise();
        integer i, j;
        logic [7:0] rand_in;
        logic [15:0] m_rand;
        
        for(i = 0; i <= (10^6)/8*BIT_TIME ; i=i+1) begin
            rand_in = { $random } % 32'hffffffff;
            m_rand = manchesterize_data(.data_in(rand_in));
            
            for(j = 0; j<=15; j=j+1) begin
                rxd = m_rand[j]; repeat(BAUD_TIME) @(posedge clk);
            end
        end
        
        $display("%b", rand_in);
        $display("%b", m_rand);
    endtask
    
    /*
     * 
     */
    task check_singleByte(input logic [7:0] data_byte);
        integer i; 
        logic data_bit;
        logic [2*(PREAMBLE_LEN)-1+15+15:2*(PREAMBLE_LEN)+15] m_frame;
        $display("Data byte %b", data_byte);
        
        check("Single data byte - cardet before receive", cardet, 0);
        
        m_frame = create_Frame(.data_byte(data_byte));
        
        //Check receiver's response to preamble, SFD, and manchesterized byte
        for(i = 0; i <= (PREAMBLE_LEN-1+7+7+EOF_LEN-1); i=i+1) begin
            //Set rxd input to bit within m_frame and hold this value for one baud
            //time where a baud is half of a manchester bit.
            rxd = m_frame[i]; repeat(BAUD_TIME) @(posedge clk);
        
            if( i <= PREAMBLE_LEN-1 ) begin //Preamble
                if ( i < 8 ) check("Single data byte - cardet Preamble", cardet, 0);
                else check("Single data byte - cardet Preamble", cardet, 1);
                check("Single data byte - write Preamble", write, 0);
                check("Single data byte - error Preamble", error, 0);
            end
            else if (i <= PREAMBLE_LEN-1+7 ) begin //SFD
                check("Single data byte - cardet SFD", cardet, 1);
                check("Single data byte - write SFD", write, 0);
                check("Single data byte - error SFD", error, 0);
            end
            else if (i <= PREAMBLE_LEN-1+7+7 ) begin //Data
                check("Single data byte - cardet data", cardet, 1);
                check("Single data byte - write SFD", write, 0);
                check("Single data byte - error data", error, 0);
            end
            else begin //EOF
                check("Single data byte - cardet data", cardet, 1);
                if (i == PREAMBLE_LEN+7+7 ) check("Single data byte - write EOF", write, 1);
                check("Single data byte - write EOF", write, 0);
                check("Single data byte - error data", error, 0);
            end
        end
    endtask
    
    initial begin
        check_group_begin("Check reset");
        check_reset();
        check_group_end;
        
        generate_noise();
        
        check_group_begin("Single data byte transmission");
        check_singleByte( .data_byte(8'b00110011) );
        check_group_end;
        
        generate_noise();
        check_summary_stop();
    end
    
endmodule
