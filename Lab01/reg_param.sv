module reg_parm #(parameter W=4) (
		input logic          clk,
		input logic          reset,
		input logic          lden,
		input logic [W-1:0]  d,
		output logic [W-1:0] q
		);

  always_ff @(posedge clk)
    if (reset) q <= '0;
    else if (lden) q <= d;
	 
endmodule
