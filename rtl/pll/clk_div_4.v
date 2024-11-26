module clk_div_4(
input clk_in,
input rst_n,
output reg clk_out

);

reg [1:0] div_cnt1;
always@(posedge clk_in or negedge rst_n)
begin
	if(!rst_n)
		div_cnt1 <= 2'b00;
	else
		div_cnt1 <= div_cnt1 + 1'b1;
end
 
always@(posedge clk_in or negedge rst_n)  //四分频 
begin                                 
	if(!rst_n)                        
		clk_out <= 1'b0;
	else if(div_cnt1==2'b00 || div_cnt1==2'b10)
		clk_out <= ~clk_out;
	else
		clk_out <= clk_out;
end

endmodule