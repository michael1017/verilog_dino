module Debounce(pb_debounced, pb, clk);

  output    pb_debounced; 
  input     pb;          
  input     clk;         
  
  reg [3:0] shift_reg;   
  
  always @(posedge clk) begin
    shift_reg[3:1] <= shift_reg[2:0];
    shift_reg[0] <= pb;
  end

  assign pb_debounced = ((shift_reg == 4'b1111) ? 1'b1 : 1'b0);

endmodule
module OnePulse (
	output reg signal_single_pulse,
	input wire signal,
	input wire clock
	);
	
	reg signal_delay;

	always @(posedge clock) begin
		if (signal == 1'b1 & signal_delay == 1'b0)
		  signal_single_pulse <= 1'b1;
		else
		  signal_single_pulse <= 1'b0;

		signal_delay <= signal;
	end
endmodule
module ClockDivider(clk, clk_div);
    parameter n = 26;
    input clk;
    output clk_div;
// add your design here
    
    reg [n-1:0] num;
    wire [n-1:0] next_num;
    always @(posedge clk) begin
        num = next_num;
    end
    assign next_num = num + 1;
    assign clk_div = num[n-1];

endmodule

module Ramdon(
    input wire clk,
    output reg [6:0] result = 37
);
    
    always @ (posedge clk) begin
        if (result == 98) begin
            result = 1;
        end else begin
            result = result + 1;
        end
    end
endmodule
