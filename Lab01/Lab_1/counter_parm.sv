module counter_parm #(parameter W=4) (
		     input logic clk, reset, enb,
		     output logic [W-1:0] q,
		     output logic carry
		     );

   always_ff @(posedge clk)
     if (reset) q <= '0;
     else if (enb) q <= q + 1;

   assign carry = (q == '1);  // fills to all 1's
      
endmodule // counter_parm
