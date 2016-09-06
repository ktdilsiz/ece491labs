module single_pulser_bench();
   reg clk, din;
   wire d_pulse;

   // Device Under Verification (DUV)

   single_pulser U_SP(.clk(clk), .din(din), .d_pulse(d_pulse));
   
   // clock generator
   always begin
      clk = 0;
      #10;
      clk = 1;
      #10;
   end


   // test stimulus
   initial begin
//      $monitor("t=%t din=%b d_pulse=%b", $time, din, d_pulse);
      $monitor("t=%t clk=%b din=%b d_pulse=%b", $time, clk, din, d_pulse);
      din = 0;
      @(posedge clk) #5;
      din = 1;
      @(posedge clk) #5;
      @(posedge clk) #5;
      @(posedge clk) #5;
      din = 0;
      repeat (3) @(posedge clk);
      din = 1;    // this pulse should be too narrow to be seen
      #10;
      din = 0;
      @(posedge clk) #5;
      #10;
      din = 1;
      repeat (3) @(posedge clk);
      #5;
      $stop;
   end
endmodule   