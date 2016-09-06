module reg_parm #(parameter W=5) (
		input logic          clk,
		input logic          reset,
		input logic          lden,
		input logic [W-1:0]  d,
		output logic [W-1:0] k
		);

  always_ff @(posedge clk)
    if (reset) k <= '0;
    else if (lden) k <= d;
	 
endmodule
 