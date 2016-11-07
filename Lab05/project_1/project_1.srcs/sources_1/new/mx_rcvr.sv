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
   parameter SIXTYFOURBAUD = BAUD * 64;
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

   logic [3:0] prev_csum_pre;
   logic [3:0] prev_prev_csum_pre;

   assign reset = rst;
   
  always_ff@(posedge clk)
  begin
   if(rst) 
       begin
           state <= IDLE;
       end

   else if(SixteenBaudRate)
       begin
           state <= next;
           //prev_csum_pre <= csum_pre;
       end 

   // else if(BaudRate)
   //    begin
   //      prev_csum_pre <= csum_pre;
   //    end
//   else if(SixteenBaudRate)
//       begin
//           dataState <= nextDataState;
//       end
   else
       begin
           state <= state;
       end
   end

   always_ff@(posedge BaudRate)
   begin

   if(BaudRate)
      begin
        prev_csum_pre <= csum_pre;
        prev_prev_csum_pre <= prev_csum_pre;
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
   correlator #(.LEN(8), .PATTERN(8'b11010000), .HTHRESH(7), .LTHRESH(1))
    COR_SFD( 
    .clk(clk), 
    .reset(rst_sfd || reset), 
    .enb(enb_sfd), 
    .d_in(d_in_sfd), 
    .replace(replace_sfd),
    .csum(csum_sfd), 
    .h_out(h_out_sfd), 
    .l_out(l_out_sfd));
    
   logic enb_eof, h_out_eof, l_out_eof;
   logic d_in_eof, rst_eof;
   logic [3:0] csum_eof;
   logic [7:0] replace_eof = 12'bxxxxxxxxxxxx;
   
   //correlator module for sfd
   correlator #(.LEN(12), .PATTERN(12'b111111111111), .HTHRESH(11), .LTHRESH(1))
    COR_EOF( 
    .clk(clk), 
    .reset(rst_eof || reset), 
    .enb(enb_eof), 
    .d_in(d_in_eof), 
    .replace(replace_eof),
    .csum(csum_eof), 
    .h_out(h_out_eof), 
    .l_out(l_out_eof));
    
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
    logic time_up, time_up_double;  
    
    always_ff@(posedge clk)
        begin
            if((rst || reset_bit_count))
                begin 
                    bit_count <= 3'b111;
                end
             else if(bit_up && clk)
                begin
                    bit_count <= bit_count - 1;
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
               3'd0 : d0 = ~rxd;
               3'd1 : d1 = ~rxd;
               3'd2 : d2 = ~rxd;
               3'd3 : d3 = ~rxd;
               3'd4 : d4 = ~rxd;
               3'd5 : d5 = ~rxd;
               3'd6 : d6 = ~rxd;
               3'd7 : d7 = ~rxd;
         endcase
       end
   end // always_ff  
           
   
    
  ////////////////////////////////////////////////////////////////////////////////// 
  //    logic corr_bit_out, corr_baud_out, corr_pre_out, corr_sfd_out;
      
  logic idle_h_check = 0;
  logic idle_h_check_up;
  logic reset_idle_check;

  always_ff@(posedge clk)
    begin
        if((reset_idle_check || rst))
            begin 
                idle_h_check <= 1'b0;
            end
         else if(idle_h_check_up && SixteenBaudRate)
            begin
                idle_h_check <= idle_h_check + 1;
            end
      end

  logic input_pre_check = 1'b0;
  logic input_pre_check_up;

  always_ff@(posedge clk)
    begin
        if((rst))
            begin 
                input_pre_check <= 1'b0;
            end
        else if(input_pre_check_up)
            begin
                input_pre_check <= 1'b1;
            end
         else if(SixteenBaudRate)
            begin
                input_pre_check <= 1'b0;
            end
      end

  logic [3:0] time_count_sfd = 0;
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

  logic [4:0] time_count_eof;
  logic reset_time_count_eof;
  logic time_eof_up = 0;
  logic time_eof_enabled = 0;

 always_ff@(posedge clk)
     begin
         //if((reset_time_count_sfd || rst || time_count_sfd == 4'b1111))
         if(reset_time_count_eof || rst)
             begin 
                 time_count_eof <= 5'b00000;
             end
          else if(time_eof_up && SixteenBaudRate)
             begin
                 time_count_eof <= time_count_eof + 1;
             end 
          else
             begin
                 time_count_eof <= time_count_eof;
             end
       end

  logic [5:0] time_count_error;
  logic reset_time_count_error;
  logic time_error_up = 0;

 always_ff@(posedge clk)
     begin
         //if((reset_time_count_sfd || rst || time_count_sfd == 4'b1111))
         if(reset_time_count_error || rst)
             begin 
                 time_count_error <= 6'b000000;
             end
          else if(time_error_up && SixteenBaudRate)
             begin
                 time_count_error <= time_count_error + 1;
             end 
          else
             begin
                 time_count_error <= time_count_error;
             end
       end

  logic [3:0] time_count_sfd_error;
  logic reset_time_count_sfd_error;
  logic time_sfd_error_up = 0;

 always_ff@(posedge clk)
     begin
         //if((reset_time_count_sfd || rst || time_count_sfd == 4'b1111))
         if(reset_time_count_sfd_error || rst)
             begin 
                 time_count_sfd_error <= 4'b0000;
             end
          else if(time_sfd_error_up && BaudRate)
             begin
                 time_count_sfd_error <= time_count_sfd_error + 1;
             end 
          else
             begin
                 time_count_sfd_error <= time_count_sfd_error;
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

logic check_last_data = 1;
logic at_least_one_byte = 0;

// logic time_sfd_enabled_up, time_sfd_enabled_down;

// always_ff@(posedge clk)
//   begin
//     if(rst)
//       time_sfd_enabled <= 1'b0;
//     else if(time_sfd_enabled_up)
//       time_sfd_enabled <= 1'b1;
//     else if(time_sfd_enabled_down)
//       time_eof_enabled <= 1'b0;
//     else
//       time_eof_enabled <= time_eof_enabled;
//   end

logic totalReset = 0;

logic check_last_data_up, check_last_data_down;

always_ff@(posedge clk)
  begin
    if(rst || totalReset)
      check_last_data <= 1'b1;
    else if(check_last_data_up)
      check_last_data <= 1'b1;
    else if(check_last_data_down)
      check_last_data <= 1'b0;
    else
      check_last_data <= check_last_data;
  end

logic at_least_one_byte_up, at_least_one_byte_down;

always_ff@(posedge clk)
  begin
    if(rst || totalReset)
      at_least_one_byte <= 1'b0;
    else if(at_least_one_byte_up)
      at_least_one_byte <= 1'b1;
    else if(at_least_one_byte_down)
      at_least_one_byte <= 1'b0;
    else
      at_least_one_byte <= at_least_one_byte;
  end


logic time_error_up_up, time_error_up_down;

always_ff@(posedge clk)
  begin
    if(rst || totalReset)
      time_error_up <= 1'b0;
    else if(time_error_up_up)
      time_error_up <= 1'b1;
    else if(time_error_up_down)
      time_error_up <= 1'b0;
    else
      time_error_up <= time_error_up;
  end

logic time_sfd_up_up, time_sfd_up_down;

always_ff@(posedge clk)
  begin
    if(rst || totalReset)
      time_sfd_up <= 1'b0;
    else if(time_sfd_up_up)
      time_sfd_up <= 1'b1;
    else if(time_sfd_up_down)
      time_sfd_up <= 1'b0;
    else
      time_sfd_up <= time_sfd_up;
  end

logic error_up, error_down;

always_ff@(posedge clk)
  begin
    if(rst)
      error <= 1'b0;
    else if(error_up)
      error <= 1'b1;
    else if(error_down)
      error <= 1'b0;
    else
      error <= error;
  end

logic time_sfd_enabled_up, time_sfd_enabled_down;

always_ff@(posedge clk)
  begin

    if(rst || totalReset)
      time_sfd_enabled <= 0;
    else if(time_sfd_enabled_up)
      time_sfd_enabled <= 1;
    else if(time_sfd_enabled_down)
      time_sfd_enabled <= 0;
    else
      time_sfd_enabled <= time_sfd_enabled;
  end

   always_comb
   begin    
    rst_bit = 0;
    totalReset = 0;
    rst_baud = 0;
    rst_pre = 0;
    rst_sfd = 0;
    idle_h_check_up = 0;
    replace_baud = 8'bxxxxxxxx;
    replace_sfd = 8'bxxxxxxxx;
    replace_pre = 8'bxxxxxxxx;
    replace_bit_enb = 0;
    time_up_double = 0;
    time_up = 0;

    //time_sfd_up = time_sfd_up;
    time_sfd_up_up = 0;
    time_sfd_up_down = 0;

    reset_time_count_sfd = 0;
    //time_sfd_enabled = time_sfd_enabled;
    input_pre_check_up = 0;
    time_eof_up = 0;
    reset_time_count_eof = 0;
    //time_sfd_enabled = 0;
    time_sfd_enabled_up = 0;
    time_sfd_enabled_down = 0;
    //check_last_data = check_last_data;
    check_last_data_up = 0;
    check_last_data_down = 0;
    //at_least_one_byte = at_least_one_byte;
    at_least_one_byte_up = 0;
    at_least_one_byte_down = 0;

    reset_idle_check = 0;
    reset_bit_count =  0;
    reset_time_count  = 0;

    reset_time_count_error = 0;
    //time_error_up = time_error_up;
    time_error_up_up = 0;
    time_error_up_down = 0;

    bit_up = 0;
    enable_data = 0;

    d_in_pre = 0;
    d_in_bit = 0;
    d_in_sfd = 0;
    d_in_baud = 0;
    d_in_eof = 0;
    enb_eof = 0;

    error_up = 0;
    error_down = 0;

    reset_time_count_sfd_error = 0;
    time_sfd_error_up = 0;

   case(state)
       IDLE:
           begin
           cardet = 0;
           write = 0;
           time_up = 1;
           bit_up = 0;
           reset_time_count_sfd_error = 1;
           //error = error;
           enb_pre = 0;
           enb_bit = 0;
           enb_baud = 0;
           enb_sfd = 0;
           idle_h_check_up = 0;
           reset_time_count = 0;
           next = IDLE;
           
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
           //error = error;
           reset_time_count = 0;
           next = PREAMBLE;           
           
           if((time_count == 3 || time_count == 4 || time_count == 5 || time_count == 6 
           || time_count == 10 || time_count == 11 || time_count == 12 || time_count == 13))
            begin
                
                d_in_bit = rxd;
                enb_bit = 1; 
                        
            end
            
            if(h_out_bit == 1 && ~input_pre_check)
            //if(h_out_bit == 1)  
              begin
                d_in_pre = 1; enb_pre = 1;
                input_pre_check_up = 1;
              end
            if(l_out_bit == 1 && ~input_pre_check) 
            //if(l_out_bit == 1) 
              begin
                d_in_pre = 0; enb_pre = 1;
                input_pre_check_up = 1;
              end

           if(time_sfd_enabled)
            begin
            
            next = SFD;
            cardet = 1;
            time_sfd_enabled_down = 1;
            //reset_time_count  = 1;
            
            end

           if(time_count_sfd_error == 4'h6)
            begin
              next = IDLE;
              rst_bit = 1;
              rst_baud = 1;
              rst_sfd = 1;
              rst_pre = 1;
              reset_time_count_eof = 1;
              reset_time_count_sfd = 1;
              reset_time_count_error = 1;
              reset_time_count = 1;
              reset_bit_count = 1;
              reset_idle_check = 1;

              //time_sfd_up = 0;

              at_least_one_byte_down = 1;
              at_least_one_byte_up = 0;

              totalReset = 1;
          end

          reset_time_count_sfd_error = 1;

          if(prev_csum_pre == prev_prev_csum_pre)
          begin
            time_sfd_error_up = 1;
            reset_time_count_sfd_error = 0;
          end

          if((time_count % 3 == 0) && SixteenBaudRate)
             begin
                 
                 d_in_eof = rxd;
                 enb_eof = 1;
                         
             end


          if(h_out_pre == 1)
            begin
            
            time_sfd_enabled_up = 1;

            //rst_bit = 1;

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
           cardet = 1;
           reset_time_count = 0;
           next = SFD;

           write = 0;
           error_down = 1;
           
           if((time_count == 3 || time_count == 4 || time_count == 5 || time_count == 6 
              || time_count == 10 || time_count == 11 || time_count == 12 || time_count == 13) && SixteenBaudRate )
               begin
                   
                   d_in_bit = rxd;
                   enb_bit = 1; 
                           
               end
            
            if(h_out_bit == 1 && (time_count_sfd >= 4'ha || time_count_sfd == 0) && ~input_pre_check && SixteenBaudRate ) 
              begin
                d_in_sfd = 1; enb_sfd = 1;
                d_in_pre = 1; enb_pre = 1;
                time_sfd_up_up = 1;
                time_sfd_up_down = 0;
                //time_sfd_enabled = 1;
                input_pre_check_up = 1;
              end
            if(l_out_bit == 1 && (time_count_sfd >= 4'ha || time_count_sfd == 0) && ~input_pre_check && SixteenBaudRate ) 
              begin
                d_in_sfd = 0; enb_sfd = 1;
                d_in_pre = 0; enb_pre = 1;
                time_sfd_up_up = 1;
                time_sfd_up_down = 0;
                //time_sfd_enabled = 1;
                input_pre_check_up = 1;
              end   

            if(h_out_bit == 1 && time_count_sfd <= 4'h7 && time_count_sfd != 4'h0 && ~input_pre_check && SixteenBaudRate ) 
              begin
                d_in_sfd = 1; enb_sfd = 1;
                d_in_pre = 1; enb_pre = 1;
                reset_time_count_sfd = 1;
                input_pre_check_up = 1;
              end
            if(l_out_bit == 1 && time_count_sfd <= 4'h7 && time_count_sfd != 4'h0 && ~input_pre_check && SixteenBaudRate ) 
              begin
                d_in_sfd = 0; enb_sfd = 1;
                d_in_pre = 0; enb_pre = 1;
                reset_time_count_sfd = 1;
                input_pre_check_up = 1;
              end            

           //BE CAREFUL HERE
           //Receive should start RIGHT after SFD is finished, meaning that 00001011 must be received perfectly
           //I think it is more important to make sure that data starts from right place
           //Therefore, if sfd is received faultily frequently, either optimize code or just give an error
          if(h_out_sfd == 1)
            begin
            
            time_sfd_enabled_up = 1;
            time_sfd_up_down = 1;
            time_sfd_up_up = 0;
            reset_time_count_sfd = 1;

            //rst_bit = 1;

            end

          if(time_count == 4'b1111 && time_sfd_enabled)
          begin
            next = RECEIVE;
            cardet = 1;

            replace_bit_enb = 1;

          end

          if(time_count_sfd_error == 4'd15)
            begin
              error_up = 1;
              error_down = 0;
              next = IDLE;
              rst_bit = 1;
              rst_baud = 1;
              rst_sfd = 1;
              rst_pre = 1;
              reset_time_count_eof = 1;
              reset_time_count_sfd = 1;
              reset_time_count_error = 1;
              reset_time_count = 1;
              reset_bit_count = 1;
              reset_idle_check = 1;

              //time_sfd_up = 0;

              at_least_one_byte_down = 1;
              at_least_one_byte_up = 0;

              totalReset = 1;
          end

          //NEEDS TO BE FIXED, DOESNT GET OUT OF SFD RIGHT AWAY, WAITS FOR DECAY
          if((csum_pre <= 6 && csum_pre >= 2)  )
          begin
            time_sfd_error_up = 1;
          end


         if((time_count % 3 == 0) && SixteenBaudRate)
             begin
                 
                 d_in_eof = rxd;
                 enb_eof = 1;
                         
             end

          if(l_out_eof == 1)
             next = IDLE;

           end
       
       RECEIVE:
           begin
           cardet = 1;
           write = 0;
           time_up = 1;
           bit_up = 0;
           error_down = 1;
           enb_pre = 0;
           enb_bit = 0;
           enb_baud = 0;
           enb_sfd = 0;
           reset_time_count = 0;
           next = RECEIVE;


           if((time_count == 3 || time_count == 4 || time_count == 5 || time_count == 6 
              || time_count == 9 || time_count == 10 || time_count == 11 || time_count == 12))
               begin
                   
                   d_in_bit = rxd;
                   enb_bit = 1; 
                           
               end

           if((time_count % 3 == 0) && SixteenBaudRate)
               begin
                   
                   d_in_eof = rxd;
                   enb_eof = 1;
                           
               end
            // if(l_out_bit && ~time_sfd_enabled)
            //   time_sfd_enabled = 1;

            if(h_out_bit == 1 && (time_count_sfd >= 4'hb || time_count_sfd == 0) && ~input_pre_check) 
              begin
                //d_in_sfd = 1; enb_sfd = 1;

                time_sfd_up_up = 1;
                time_sfd_up_down = 0;
                time_error_up_up = 1;
                time_error_up_down = 0;

                bit_up = 1;
                enable_data = 1;
                
                input_pre_check_up = 1;
              end
            if(l_out_bit == 1 && (time_count_sfd >= 4'hb || time_count_sfd == 0) && ~input_pre_check) 
              begin
                //d_in_sfd = 0; enb_sfd = 1;

                time_sfd_up_up = 1;
                time_sfd_up_down = 0;
                time_error_up_up = 1;
                time_error_up_down = 0;

                bit_up = 1;
                enable_data = 1;
                
                input_pre_check_up = 1;
              end   

            if(h_out_bit == 1 && time_count_sfd <= 4'h7 && time_count_sfd != 4'h0 && ~input_pre_check) 
              begin
                //d_in_sfd = 1; enb_sfd = 1;

                reset_time_count_sfd = 1;
                reset_time_count_error = 1;

                bit_up = 1;
                enable_data = 1;

                input_pre_check_up = 1;
              end
            if(l_out_bit == 1 && time_count_sfd <= 4'h7 && time_count_sfd != 4'h0 && ~input_pre_check) 
              begin
                //d_in_sfd = 0; enb_sfd = 1;

                reset_time_count_sfd = 1;
                reset_time_count_error = 1;

                bit_up = 1;
                enable_data = 1;

                input_pre_check_up = 1;
              end   

            if(h_out_bit == 1 || h_out_bit ==1)
              reset_time_count_error = 1;

          if(bit_count == 7)
            begin
              if(~check_last_data && SixteenBaudRate)
                begin
                  write = 1;
                  at_least_one_byte_up = 1;
                  at_least_one_byte_down = 0;
                end
              tempdata = 8'bxxxxxxxx;
            end

          if(check_last_data && bit_count == 6)
          begin
            check_last_data_down = 1;
            check_last_data_up = 0;
          end

          if(h_out_eof)
            time_eof_up = 1;
          else
            reset_time_count_eof = 1;

          if(h_out_eof == 1)
             next = EOF;

          // if(time_count_eof == 5'b10000 && SixteenBaudRate && bit_count == 7)
          //    next = EOF;

          // if(time_count_error == 6'b100010 && SixteenBaudRate)
          // begin
          //   error_up = 1;
          //   error_down = 0;
          //   next = IDLE;
          //   rst_bit = 1;
          //   rst_baud = 1;
          //   rst_sfd = 1;
          //   rst_pre = 1;
          //   reset_time_count_eof = 1;
          //   reset_time_count_sfd = 1;
          //   reset_time_count_error = 1;
          //   reset_time_count = 1;
          //   reset_bit_count = 1;
          //   reset_idle_check = 1;

          //   //time_sfd_up = 0;

          //   at_least_one_byte_down = 1;
          //   at_least_one_byte_up = 0;

          //   totalReset = 1;
          // end

           end
       
       EOF:
          begin
          cardet = 1;
          write = 0;
          time_up = 0;
          bit_up = 0;
          error_down = 1;
          enb_pre = 0;
          enb_bit = 0;
          enb_baud = 0;
          enb_sfd = 0;
          reset_time_count = 0;
          next = EOF;

          tempdata = data;
          check_last_data_up = 1;
          check_last_data_down = 0;

          time_eof_up = 1;

          d_in_eof = rxd;
          enb_eof = 1;

          //if(time_count_eof == 5'b11101 && SixteenBaudRate)
          if(csum_eof < 4'h8)
            begin 
              next = IDLE;
              rst_bit = 1;
              rst_baud = 1;
              rst_sfd = 1;
              rst_pre = 1;
              reset_time_count_eof = 1;
              reset_time_count_sfd = 1;
              reset_time_count_error = 1;
              reset_time_count = 1;
              reset_bit_count = 1;
              reset_idle_check = 1;

              //time_sfd_up = 0;

              at_least_one_byte_down = 1;
              at_least_one_byte_up = 0;

              totalReset = 1;

            end


          end 
      
             
       default: 
       
           begin
               next = IDLE;
               cardet = 1;
               write = 1;
               error_down = 1;
               time_up = 0;
               bit_up = 0;
               enb_pre = 0;
               enb_bit = 0;
               enb_baud = 0;
               enb_sfd = 0;
               reset_time_count = 0;

               $display("i was in default");

           end     
       endcase
     end


endmodule
