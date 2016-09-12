`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/06/2016 02:27:00 PM
// Design Name: 
// Module Name: transmitter
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// 
//////////////////////////////////////////////////////////////////////////////////

module transmitter(
    input logic [7:0] data,
    input logic send,
    input logic clk, rst,
    output logic txd,
    output logic rdy
    );
    
    typedef enum logic [2:0] {
    S0 = 3'b000, S1 = 3'b001, S2 = 3'b010, S3 = 3'b011,
    S4 = 3'b100, S5 = 3'b101, S6 = 3'b110, S7 = 3'b111
    } state_t;

    state_t state, next;
    
   always_ff@(posedge clk)
    if(rst) state <= S0;
    else    state <= next;
    
    logic [3:0] count;
    
   always_comb
    begin
    next = S0;
    rdy = 1;
    txd = 1;
    count = 0;
    case(state)
        S0:
            begin
                if(send && rdy)
                    begin
                        txd = 0;
                        rdy = 1;
                        next = S1;
                    end
                else
                    begin
                        txd = 1;
                        rdy = 1;
                        next = S0;
                    end
            end
        S1:
            begin
                if(count == 7)
                    begin
                        txd = data[count];
                        count = 0;
                        rdy = 0;
                        next = S2;
                    end    
                else
                    begin
                        txd = data[count];
                        count = count + 1;
                        rdy = 0;
                        next = S1;
                    end
            end       
         S2:
            begin
                txd = 1;
                rdy = 1;
                next = S0;
            end         
                
//        S1:
//            begin
//                txd = data[1];
//                next = S2;
//            end
//        S2:
//            begin
//                txd = data[2];
//                next = S3;
//            end
//        S3:
//            begin
//                txd = data[3];
//                next = S4;
//            end
//        S4:
//            begin
//                txd = data[4];
//                next = S5;
//            end
//        S5:
//            begin
//                txd = data[5];
//                next = S6;
//            end
//        S6:
//            begin
//                txd = data[6];
//                next = S7;
//            end
//        S7:
//            begin
//                rdy = 1;
//                txd = data[7];
//                next = S0;
//            end
        endcase
      end
        
    
endmodule
