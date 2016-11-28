`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Lafayette College, ECE 491, Lab 5
// Engineer: Meridith Guro, Emilie Grybos
// 
// Create Date: 10/22/2016 10:29:39 AM
// Module Name: mx_rcvr_bench_1
// Project Name: Lab_5
// Target Devices: Nexys4DDR
// Tool Versions: Vivado 2016.2
// Description: In this testbench, we verify that our manchester receiver can handle
// a longer data frame consisting of a 24-bit preamble/SFD followed by a string of
// at least 24 data bytes. The 'rxd' input value should be a constant "1" before and
// after the frame. We also verify that a deliberately erroneous input in which
// rxd remains low throughout an entire bit period as part of a larger input frame
// causes an error to be asserted and the receiver handles as expected. Testbench
// defined in the lab handout Requirements 10.b and 10.d. 
// 
// Dependencies: mx_rcvr, transmitter (Lab 3)
//////////////////////////////////////////////////////////////////////////////////


module mx_rcvr_bench_1();
    parameter EOF_LEN = 2;
    parameter PREAMBLE_LEN = 16;
    parameter EXPECTED_LEN = 8;
    parameter N = $clog2(PREAMBLE_LEN);
    parameter W = $clog2(EXPECTED_LEN);
    parameter BIT_TIME = 20_000;
    parameter BAUD_TIME = BIT_TIME/2;
    parameter NUM_DATA_BYTES = 1;

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
    function [2*(PREAMBLE_LEN)-1+15+16*NUM_DATA_BYTES-1:0] create_Frame(input logic [8*NUM_DATA_BYTES-1:0] data_byte, input logic error);
         integer i;
         logic [16*NUM_DATA_BYTES-1:0] m_data;
         logic [2*(PREAMBLE_LEN)-1+15:0] m_startFrame;
         logic [2*(PREAMBLE_LEN)-1+15+16*NUM_DATA_BYTES-1:0] m_Frame;
         
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
         m_data = manchesterize_data(.data_in(data_byte), .error(error));
         
         if( error ) begin
            //append SFD to start frame
            m_startFrame[2*(PREAMBLE_LEN)-1+15:2*PREAMBLE_LEN] = 16'b0101010110011010;
            
            m_Frame[2*(PREAMBLE_LEN)+15:0] = m_startFrame;
            m_Frame[2*(PREAMBLE_LEN)-1+15+16*NUM_DATA_BYTES:2*(PREAMBLE_LEN)+15] = m_data;
         end
         
         else begin
            m_startFrame[2*(PREAMBLE_LEN)-1+15:2*PREAMBLE_LEN] = 16'b0101010110011010;
                   
            m_Frame[2*(PREAMBLE_LEN)+15:0] = m_startFrame;
            m_Frame[2*(PREAMBLE_LEN)-1+15+16*NUM_DATA_BYTES-1:2*(PREAMBLE_LEN)+15] = m_data;
         end
         
         return m_Frame;
     endfunction
     
     function [16*NUM_DATA_BYTES-1:0] manchesterize_data(input [8*NUM_DATA_BYTES-1:0] data_in, input error);
             logic [16*NUM_DATA_BYTES-1:0] m_data;
             integer i;   
             
             for( i = 0; i <= 8*NUM_DATA_BYTES-1; i=i+1 ) begin

                 if(error && i == 4) begin
                      m_data[i*2] = 1'b0; 
                      m_data[i*2+1] = 1'b0;
                  end
                 else if(data_in[i] == 1) begin
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
    task check_N_Bytes(input logic [8*NUM_DATA_BYTES-1:0] data, input logic error);
        integer i; 
        logic data_bit;
        logic d_erroneous;
        logic [2*(PREAMBLE_LEN)-1+15+8*NUM_DATA_BYTES-1:2*(PREAMBLE_LEN)+15] m_frame;
        $display("Data byte %b", data);
        
        check("N Bytes - cardet before receive", cardet, 0);

        m_frame = create_Frame(.data_byte(data), .error(error));
        
        //Check receiver's response to preamble, SFD, and manchesterized byte
        for(i = 0; i <= (PREAMBLE_LEN-1+7+8*NUM_DATA_BYTES-1+EOF_LEN-1); i=i+1) begin
        
            //Set rxd input to bit within m_frame and hold this value for one baud
            //time where a baud is half of a manchester bit.
            rxd = m_frame[i]; repeat(BAUD_TIME) @(posedge clk);
        
            if( i <= PREAMBLE_LEN-1 ) begin //Preamble
                if ( i < 8 ) check("N Bytes - cardet Preamble", cardet, 0);
                else check("N Bytes - cardet Preamble", cardet, 1);
                check("N Bytes - write Preamble", write, 0);
                check("N Bytes - error Preamble", error, 0);
            end
            else if (i <= PREAMBLE_LEN-1+7 ) begin //SFD
                check("N Bytes - cardet SFD", cardet, 1);
                check("N Bytes - write SFD", write, 0);
                check("N Bytes - error SFD", error, 0);
            end
            else if (i <= PREAMBLE_LEN-1+7+NUM_DATA_BYTES-1 ) begin //Data
                if(d_erroneous) begin 
                    check("N Bytes - cardet data", cardet, 0);
                    check("N Bytes - write SFD", write, 0);
                    check("N Bytes - error data", error, 1);
                end
                else begin
                    check("N Bytes - cardet data", cardet, 1);
                    check("N Bytes - write SFD", write, 0);
                    check("N Bytes - error data", error, 0);
                end
            end
            else begin //EOF
                check("N Bytes - cardet data", cardet, 1);
                if (i == PREAMBLE_LEN+7+NUM_DATA_BYTES-1 ) check("N Bytes - write EOF", write, 1);
                check("N Bytes - write EOF", write, 0);
                check("N Bytes - error data", error, 0);
            end
        end
    endtask
    
    initial begin
        check_group_begin("Check reset");
        check_reset();
        check_group_end;

        check_N_Bytes( .data(48'h000000000000), .error(0) );
        check_N_Bytes( .data(48'hffffffffffff), .error(0) );
        check_N_Bytes( .data(48'h0f0f0f0f0f0f), .error(0) );
      
        //cause a deliberate error in a long frame (should be in 4th bit according to machestor function abov)
         check_N_Bytes( .data(48'h000000000000), .error(1) );
       
        //cause a deliberate error in a long frame (should be in 4th bit according to machestor function above)
         check_N_Bytes( .data(48'hffffffffffff), .error(1) );
       
        check_group_end;
      
        check_group_begin("Check reset");
        check_reset();
        check_group_end;
        
        check_summary_stop();
    end
    
endmodule
