`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/24/2016 08:26:15 PM
// Design Name: 
// Module Name: mx_rcvr
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
module mx_rcvr(
    input logic rxd, clk, rst,
    output logic [7:0] data,
    output logic cardet, write, error
   );
   
   parameter BAUD = 9600;
   parameter TWICEBAUD = BAUD * 2;
   parameter SIXTEENBAUD = BAUD * 16;
   parameter BIT_RATE = 50_000;
   
   logic BaudRate, TwiceBaudrate, SixteenBaudRate;
   logic [7:0] tempdata;
       
   //logic clkEnb;
  // logic [7:0] k;

   clkenb #(.DIVFREQ(BAUD)) CLKENB(.clk(clk), .reset(rst), .enb(BaudRate));
   clkenb #(.DIVFREQ(TWICEBAUD)) CLKENB2(.clk(clk), .reset(rst), .enb(TwiceBaudRate));
   clkenb #(.DIVFREQ(SIXTEENBAUD)) CLKENB3(.clk(clk), .reset(rst), .enb(SixteenBaudRate));
   
   typedef enum logic [3:0] {
       IDLE =       4'b0000, 
       PREAMBLE =   4'b1010, 
       SFD =        4'b0001, 
       RECEIVE =    4'b0010, 
       EOF =        4'b0011
//       TR3 = 4'b0100, 
//       TR4 = 4'b0101, 
//       TR5 = 4'b0110, 
//       TR6 = 4'b0111, 
//       TR7 = 4'b1000, 
//       STOP = 4'b1001,
//       WAIT = 4'b1111,
//       EOF1 = 4'b1101,
//       EOF2 = 4'b1100
   } state_t;

   state_t state, next;

   
  always_ff@(posedge clk)
  begin
   if(rst) 
       begin
           state <= IDLE;
       end
   else if(SixteenBaudRate)
       begin
           state <= next;
//           dataState <= nextDataState;
       end 
//   else if(SixteenBaudRate)
//       begin
//           dataState <= nextDataState;
//       end
   else
       begin
           state <= state;
       end
   end
   
    //decoder instantiated    

   logic enb_pre, h_out_pre, l_out_pre;
   logic d_in_pre;
   logic [3:0] csum_pre;

   logic rst_pre, rst_bit, rst_baud, rst_sfd;
   logic [7:0] replace_pre, replace_sfd, replace_bit, replace_baud;
   
   //instantiate the correlator module
   correlator #(.LEN(8), .PATTERN(8'b10101010), .HTHRESH(7), .LTHRESH(1)) 
       COR_PREAM( 
       .clk(clk), 
       .reset(rst_pre || reset), 
       .enb(enb_pre), 
       .d_in(d_in_pre), 
       .replace(replace_pre),
       .csum(csum_pre), 
       .h_out(h_out_pre), 
       .l_out(l_out_pre));
       
   logic enb_sfd, h_out_sfd, l_out_sfd;
   logic d_in_sfd;
   logic [3:0] csum_sfd;
   
   //correlator module for sfd
   correlator #(.LEN(8), .PATTERN(8'b00001011), .HTHRESH(7), .LTHRESH(1))
    COR_SFD( 
    .clk(clk), 
    .reset(rst_sfd || reset), 
    .enb(enb_sfd), 
    .d_in(d_in_sfd), 
    .replace(replace_sfd),
    .csum(csum_sfd), 
    .h_out(h_out_sfd), 
    .l_out(l_out_sfd));
    
    logic enb_bit, h_out_bit, l_out_bit;
    logic d_in_bit;
    logic [3:0] csum_bit;

 //correlator module for bit
 correlator #(.LEN(8), .PATTERN(8'b11110000), .HTHRESH(7), .LTHRESH(1)) 
    COR_BIT( 
    .clk(clk), 
    .reset(rst_bit || reset), 
    .enb(enb_bit), 
    .d_in(d_in_bit), 
    .replace(replace_bit),
    .csum(csum_bit), 
    .h_out(h_out_bit), 
    .l_out(l_out_bit));
   
    logic enb_baud, h_out_baud, l_out_baud;
    logic d_in_baud;
    logic [3:0] csum_baud;
   
  //correlator module for baudrate mismatch
 correlator #(.LEN(8), .PATTERN(8'b11110000), .HTHRESH(7), .LTHRESH(1)) 
    COR_MIS_BAUD( 
    .clk(clk), 
    .reset(rst_baud || reset), 
    .enb(enb_baud), 
    .d_in(d_in_baud), 
    .replace(replace_baud),
    .csum(csum_baud), 
    .h_out(h_out_baud), 
    .l_out(l_out_baud));
    
    logic corr_bit_out, corr_baud_out, corr_pre_out, corr_sfd_out;
    
    assign corr_bit_out = h_out_bit ? h_out_bit : l_out_bit;
    assign corr_baud_out = h_out_baud ? h_out_baud : l_out_baud;
    assign corr_pre_out = h_out_pre ? h_out_pre : l_out_pre;
    assign corr_sfd_out = h_out_sfd ? h_out_sfd : l_out_sfd;
    
    //////////////////////////////////////////////////////////////////////////////////
   
    logic reset_time_count = 0;
    logic reset_bit_count = 0;
    logic bit_up; 
    logic [2:0] bit_count;
    logic [3:0] time_count;
    logic time_up, time_up_double, time_fix;  
    
    always_ff@(posedge clk)
        begin
            if((rst || reset_bit_count))
                begin 
                    bit_count <= 3'b000;
                end
             else if(bit_up && SixteenBaudRate)
                begin
                    bit_count <= bit_count + 1;
                end
          end
                     
   always_ff@(posedge clk)
         begin
             if((reset_time_count || rst))
                 begin 
                     time_count <= 4'b0000;
                 end
              else if(time_up && SixteenBaudRate)
                 begin
                     time_count <= time_count + 1;
                 end
              else if(time_up_double && SixteenBaudRate)
                 begin
                     time_count <= time_count + 2;
                 end   
              else if(time_fix)
                begin
                  time_count <= 4'b0001;
                end
              else
                 begin
                     time_count <= time_count;
                 end
           end
   
   logic enable_data;  
   logic d0,d1,d2,d3,d4,d5,d6,d7;  
    
    assign data = {d7,d6,d5,d4,d3,d2,d1,d0};
        
   always_ff@(posedge clk) 
   begin
       if(enable_data)
       begin
         case (bit_count)
               3'd0 : d0 = rxd;
               3'd1 : d1 = rxd;
               3'd2 : d2 = rxd;
               3'd3 : d3 = rxd;
               3'd4 : d4 = rxd;
               3'd5 : d5 = rxd;
               3'd6 : d6 = rxd;
               3'd7 : d7 = rxd;
         endcase
       end
   end // always_ff  
           
   
    
  ////////////////////////////////////////////////////////////////////////////////// 
  //    logic corr_bit_out, corr_baud_out, corr_pre_out, corr_sfd_out;
      
  logic idle_h_check = 0;
  logic idle_h_check_up;

  always_ff@(posedge clk)
    begin
        if((rst))
            begin 
                idle_h_check <= 1'b0;
            end
         else if(idle_h_check_up && SixteenBaudRate)
            begin
                idle_h_check <= idle_h_check + 1;
            end
      end

  logic [3:0] time_count_sfd;
  logic reset_time_count_sfd;
  logic time_sfd_up = 0;
  logic time_sfd_enabled = 0;

 always_ff@(posedge clk)
     begin
         //if((reset_time_count_sfd || rst || time_count_sfd == 4'b1111))
         if(reset_time_count_sfd || rst)
             begin 
                 time_count_sfd <= 4'b0000;
             end
          else if(time_sfd_up && SixteenBaudRate)
             begin
                 time_count_sfd <= time_count_sfd + 1;
             end 
          else
             begin
                 time_count_sfd <= time_count_sfd;
             end
       end

logic replace_bit_enb;

 always_ff@(posedge SixteenBaudRate)
     begin
         //if((reset_time_count_sfd || rst || time_count_sfd == 4'b1111))
         if(rst)
             begin 
                 replace_bit <= 8'bxxxxxxxx;
             end
          else if(replace_bit_enb && SixteenBaudRate)
             begin
                 replace_bit <= 8'b10101010;
             end 
          else
             begin
                 replace_bit <= 8'bxxxxxxxx;
             end
       end

   always_comb
   begin    
    rst_bit = 0;
    rst_baud = 0;
    rst_pre = 0;
    rst_sfd = 0;
    idle_h_check_up = 0;
    replace_baud = 8'bxxxxxxxx;
    replace_sfd = 8'bxxxxxxxx;
    replace_pre = 8'bxxxxxxxx;
    replace_bit_enb = 0;
    time_up_double = 0;
    time_sfd_up = time_sfd_up;
    reset_time_count_sfd = 0;
    time_sfd_enabled = time_sfd_enabled;
   case(state)
       IDLE:
           begin
           cardet = 0;
           write = 0;
           time_up = 1;
           bit_up = 0;
           error = error;
           enb_pre = 0;
           enb_bit = 0;
           enb_baud = 0;
           enb_sfd = 0;
           idle_h_check_up = 0;
           reset_time_count = 0;
           
           if(time_count % 2 == 0 && SixteenBaudRate)
           begin
              d_in_bit = rxd;
              enb_bit = 1;
           end

          if(h_out_bit == 1 && ~enb_pre && SixteenBaudRate) //added ~enb_pre
          begin
              if(idle_h_check == 0)
              begin
                idle_h_check_up = 1;
                rst_bit = 1;
              end
          end

          //CHANGE TO 8 IF CREATES PROBLEMS, LOOK HERE KEMAL OR ZAINAB
          //WOLOLOLOLOLOL
          if(csum_bit == 8 && ~enb_pre && SixteenBaudRate)
           begin
              if(time_count % 2 == 1 && idle_h_check)
              begin
                next = PREAMBLE;
                reset_time_count = 1;

                d_in_pre = 1; enb_pre = 1;
                //rst_bit = 1;
                replace_bit_enb = 1;

              end
          end

           end
  
    //start counting time
    //sample 16 times for each bit
    //take 8 samples for correlator_bit --> sample at 3,4,5,6 / 10,11,12,13
    //put correlator/h_out_bit into d_in_pre
    //if h_out_pre is true, go to SFD, make cardet 1
    //go to sfd when time_count == 15 OR DONT
       PREAMBLE:
           begin
           write = 0;
           time_up = 1;
           enb_pre = 0;
           enb_bit = 0;
           enb_baud = 0;
           enb_sfd = 0;
           cardet = 0;
           error = error;
           reset_time_count = 0;
           next = PREAMBLE;           
           
           if((time_count == 3 || time_count == 4 || time_count == 5 || time_count == 6 
           || time_count == 10 || time_count == 11 || time_count == 12 || time_count == 13))
            begin
                
                d_in_bit = rxd;
                enb_bit = 1; 
                        
            end
            
            if(h_out_bit == 1 && SixteenBaudRate)
            //if(h_out_bit == 1)  
              begin
                d_in_pre = 1; enb_pre = 1;
              end
            if(l_out_bit == 1 && SixteenBaudRate) 
            //if(l_out_bit == 1) 
              begin
                d_in_pre = 0; enb_pre = 1;
              end

           if(h_out_pre == 1)
            begin
            
            next = SFD;
            cardet = 1;
            
            end
           
           
           end
       
       //give error if (csum_pre < 5-6) && (csum_sfd < 3)
       //first i'm just writing the code to check if everything is perfect, will it work?
       //then i will add the error situations, exceptions and others
       SFD:
           begin
           time_up = 1;
           bit_up = 0;
           enb_pre = 0;
           enb_bit = 0;
           enb_baud = 0;
           enb_sfd = 0;
           cardet = 0;
           reset_time_count = 0;
           next = SFD;

           write = 0;
           error = 0;
           
           if((time_count == 3 || time_count == 4 || time_count == 5 || time_count == 6 
              || time_count == 10 || time_count == 11 || time_count == 12 || time_count == 13))
               begin
                   
                   d_in_bit = rxd;
                   enb_bit = 1; 
                           
               end
            
            if(h_out_bit == 1 && SixteenBaudRate && (time_count_sfd >= 4'ha || time_count_sfd == 0)) 
              begin
                d_in_sfd = 1; enb_sfd = 1;
                time_sfd_up = 1;
                //time_sfd_enabled = 1;
              end
            if(l_out_bit == 1 && SixteenBaudRate && (time_count_sfd >= 4'ha || time_count_sfd == 0)) 
              begin
                d_in_sfd = 0; enb_sfd = 1;
                time_sfd_up = 1;
                //time_sfd_enabled = 1;
              end   

            if(h_out_bit == 1 && SixteenBaudRate && time_count_sfd <= 4'h7 && time_count_sfd != 4'h0) 
              begin
                d_in_sfd = 1; enb_sfd = 1;
                reset_time_count_sfd = 1;
              end
            if(l_out_bit == 1 && SixteenBaudRate && time_count_sfd <= 4'h7 && time_count_sfd != 4'h0) 
              begin
                d_in_sfd = 0; enb_sfd = 1;
                reset_time_count_sfd = 1;
              end            

           //BE CAREFUL HERE
           //Receive should start RIGHT after SFD is finished, meaning that 00001011 must be received perfectly
           //I think it is more important to make sure that data starts from right place
           //Therefore, if sfd is received faultily frequently, either optimize code or just give an error
          if(h_out_sfd == 1)
            begin
            
            time_sfd_enabled = 1;
            time_sfd_up = 0;
            reset_time_count_sfd = 1;

            //rst_bit = 1;

            end

          if(time_count == 4'b1110 && time_sfd_enabled)
          begin
            next = RECEIVE;
            cardet = 1;

            replace_bit_enb = 1;

          end

           end
       
       RECEIVE:
           begin
           cardet = 0;
           write = 0;
           time_up = 1;
           bit_up = 0;
           error = 0;
           enb_pre = 0;
           enb_bit = 0;
           enb_baud = 0;
           enb_sfd = 0;
           reset_time_count = 0;
           next = RECEIVE;


           if((time_count == 3 || time_count == 4 || time_count == 5 || time_count == 6 
              || time_count == 10 || time_count == 11 || time_count == 12 || time_count == 13))
               begin
                   
                   d_in_bit = rxd;
                   enb_bit = 1; 
                           
               end

            // if(l_out_bit && ~time_sfd_enabled)
            //   time_sfd_enabled = 1;

            if(h_out_bit == 1 && SixteenBaudRate && (time_count_sfd >= 4'ha || time_count_sfd == 0)) 
              begin
                d_in_sfd = 1; enb_sfd = 1;
                time_sfd_up = 1;
                //time_sfd_enabled = 1;
              end
            if(l_out_bit == 1 && SixteenBaudRate && (time_count_sfd >= 4'ha || time_count_sfd == 0)) 
              begin
                d_in_sfd = 0; enb_sfd = 1;
                time_sfd_up = 1;
                //time_sfd_enabled = 1;
              end   

            if(h_out_bit == 1 && SixteenBaudRate && time_count_sfd <= 4'h7 && time_count_sfd != 4'h0) 
              begin
                d_in_sfd = 1; enb_sfd = 1;
                reset_time_count_sfd = 1;
              end
            if(l_out_bit == 1 && SixteenBaudRate && time_count_sfd <= 4'h7 && time_count_sfd != 4'h0) 
              begin
                d_in_sfd = 0; enb_sfd = 1;
                reset_time_count_sfd = 1;
              end   


           end
       
       EOF:
          begin
          cardet = 0;
          write = 0;
          time_up = 0;
          bit_up = 0;
          error = 0;
          enb_pre = 0;
          enb_bit = 0;
          enb_baud = 0;
          enb_sfd = 0;
          reset_time_count = 0;
          next = EOF;
          end 
      
             
       default: 
       
           begin
               next = IDLE;
               cardet = 1;
               write = 1;
               error = 0;
               time_up = 0;
               bit_up = 0;
               enb_pre = 0;
               enb_bit = 0;
               enb_baud = 0;
               enb_sfd = 0;
               reset_time_count = 0;
           end     
       endcase
     end


endmodule
