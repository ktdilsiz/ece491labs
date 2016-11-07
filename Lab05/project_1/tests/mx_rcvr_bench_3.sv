`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Meridith Guro, Emilie Grybos
// 
// Create Date: 10/22/2016 10:29:39 AM
// Design Name: 
// Module Name: mx_rcvr_bench_3
// Project Name: Lab_5
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


module mx_rcvr_bench_3();
    parameter EOF_LEN = 2;
    parameter PREAMBLE_LEN = 16;
    parameter N = $clog2(PREAMBLE_LEN);
    parameter BIT_TIME = 20000;
    parameter BAUD_TIME = BIT_TIME/2;
    parameter NUM_DATA_BYTES = 1;

    import check_p::*;
    
    logic clk, reset, rxd, cardet, write, error;
    logic [7:0] data;
    
    mx_rcvr #() DUV( .clk(clk), .reset(reset), .rxd(rxd), .cardet(cardet), .data(data), .write(write), .error(error) );
    
    always begin
        clk = 0;
        #5 clk = 1;
        #5;
    end
    
    /* 
     * function create_Frame takes data and an error flag to output manchesterized frame
     */
      function [2*(PREAMBLE_LEN)+15+16*NUM_DATA_BYTES:0] create_Frame(input logic [8*NUM_DATA_BYTES-1:0] data_byte, input logic error);
          integer i;
          logic [16*NUM_DATA_BYTES-1:0] m_data; //Manchesterized data byte from input data_byte
          logic [2*(PREAMBLE_LEN)+15+16*NUM_DATA_BYTES:0] m_Frame; //Manchesterized frame (preamble, SFD, data byte)
          logic [2*(PREAMBLE_LEN)-1:0] m_pre; //Manchesterized preamble
          
          //Create Preamble
          for( i=0; i <= PREAMBLE_LEN-1; i=i+1 ) begin
              if( i%2 == 0 ) begin
                  m_pre[i*2] = 1'b1; 
                  m_pre[i*2+1] = 1'b0;
              end
              else begin
                  m_pre[i*2] = 1'b0;
                  m_pre[i*2+1] = 1'b1;
              end
          end
                    
          //Manchesterize data_byte to be received
          m_data = manchesterize_data(.data_in(data_byte), .error(error));
          
          if(error) begin
            m_Frame[2*(PREAMBLE_LEN)-1:0] = m_pre; //adding preamble
            m_Frame[2*(PREAMBLE_LEN)+16-1:2*(PREAMBLE_LEN)] = 16'b0101100110101010;
            m_Frame[NUM_DATA_BYTES*16-1+2*(PREAMBLE_LEN)+16:2*(PREAMBLE_LEN)+16] = 16'bX; //DATA IS DON'T CARE; HARDCODED TO 16 BITS
            return m_Frame; 
          end
          
          else begin
            m_Frame[2*(PREAMBLE_LEN)-1:0] = m_pre; //adding preamble
            m_Frame[2*(PREAMBLE_LEN)+16-1:2*(PREAMBLE_LEN)] = 16'b0101100110101010;
            m_Frame[NUM_DATA_BYTES*16-1+2*(PREAMBLE_LEN)+16:2*(PREAMBLE_LEN)+16] = m_data;
            return m_Frame; 
          end    
      endfunction
      
      function [16*NUM_DATA_BYTES-1:0] manchesterize_data(input [8*NUM_DATA_BYTES-1:0] data_in, input error);
              integer i;
              logic [16*NUM_DATA_BYTES-1:0] m_data;
              for( i = 0; i <= 8*NUM_DATA_BYTES-1; i=i+1 ) begin
                  if(error && i ==8*NUM_DATA_BYTES-1) begin
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
         check_ok("Check reset cardet", cardet, 0);
         check_ok("Check reset write", write, 0);
         check_ok("Check reset error", error, 0);
         
         repeat(BAUD_TIME) @(posedge clk);
         reset = 0;
         
         repeat(BAUD_TIME) @(posedge clk);
     endtask
    
    /*
     * 
     */
    task check_singleByte(input logic [N:0] preamble_length, input logic [8*NUM_DATA_BYTES-1:0] data_byte, input error);
        integer i; 
        integer num_data_bytes = NUM_DATA_BYTES;
        logic data_bit;
        logic [2*(PREAMBLE_LEN)+15+16*NUM_DATA_BYTES:0] m_frame;
        $display("Data byte %b", data_byte);
        
        check_ok("Single data byte - cardet before receive", cardet, 0);
        
        m_frame = create_Frame(.data_byte(data_byte), .error(error));

        //Check receiver's response to preamble, SFD, and manchesterized byte
        for(i = 0; i < (2*(PREAMBLE_LEN)+15+16*NUM_DATA_BYTES+EOF_LEN*2); i=i+1) begin
            //Set rxd input to bit within m_frame and hold this value for one baud
            //time where a baud is half of a manchester bit.
            if( i < 2*(PREAMBLE_LEN)+15+16*NUM_DATA_BYTES ) begin
                rxd = m_frame[i]; 
                $display("Rxd set to: %b", rxd);
                repeat(BAUD_TIME) @(posedge clk);
            end
            else begin
                rxd = 1'b1; 
                repeat(BAUD_TIME) @(posedge clk);
            end
        
            if( i <= PREAMBLE_LEN*2-1 ) begin //Preamble
                if ( i < 8 ) check_ok("Single data byte- cardet Preamble", cardet, 0);
                else check_ok("Single data byte - cardet Preamble", cardet, 1);
                check_ok("Single data byte - write Preamble", write, 0);
                check_ok("Single data byte - error Preamble", error, 0);
            end
            else if (i <= 2*PREAMBLE_LEN-1+16 ) begin //SFD
                check_ok("Single data byte - cardet SFD", cardet, 1);
                check_ok("Single data byte - write SFD", write, 0);
                check_ok("Single data byte - error SFD", error, 0);
            end
            else if (i < 2*(PREAMBLE_LEN)+15+16*NUM_DATA_BYTES ) begin //Data
                //should go back to IDLE
                if(error) begin
                    check_ok("Single data byte - cardet data", cardet, 0);
                    check_ok("Single data byte - write SFD", write, 0);
                    check_ok("Single data byte - error data", error, 1);
                end
                else begin
                    check_ok("Single data byte - cardet data", cardet, 1);
                    check_ok("Single data byte - write SFD", write, 0);
                    check_ok("Single data byte - error data", error, 0);
                end
            end
            else begin //EOF
                check_ok("Single data byte - cardet data", cardet, 1);
                if (i == PREAMBLE_LEN+7+NUM_DATA_BYTES-1 ) check_ok("Single data byte - write EOF", write, 1);
                else check_ok("Single data byte - write EOF", write, 0);
                check_ok("Single data byte - write EOF", write, 0);
                check_ok("Single data byte - error data", error, 0);
            end
        end
    endtask
    
    
    initial begin
        check_group_begin("Check reset");
        check_reset();
        check_group_end;
        
        check_group_begin("Single data byte transmission");
        

        check_group_begin("Single data byte transmission");
        check_singleByte( .preamble_length(16), .data_byte(8'b01010101), .error(0));
        //check_singleByte( .preamble_length(16), .data_byte(8'b00110011), .error(0));
        //check_singleByte( .preamble_length(16), .data_byte(8'b00001111), .error(0));
        //check_singleByte( .preamble_length(16), .data_byte(8'b00000000), .error(0));
        //check_singleByte( .preamble_length(16), .data_byte(8'b11111111), .error(0));
      
        //deliberately erroneous input where transmission of a byte ends prematurely
      //  check_singleByte( .preamble_length(16), .data_byte(8'b00000000) , .error(1) );
      
        check_group_end;
        
        check_summary_stop();
    end
    
endmodule
