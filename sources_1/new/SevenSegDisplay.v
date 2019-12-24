module SevenSegDisplay(
    input wire [27:0] display_all,
    input clk,
    output reg [6:0] DISPLAY, 
    output reg [3:0] DIGIT = 4'b1110
);

    always @ (posedge clk) begin
        DIGIT = {DIGIT[2:0], DIGIT[3]};
        case (DIGIT)
            4'b1110 : DISPLAY = display_all[6:0];
            4'b1101 : DISPLAY = display_all[13:7];
            4'b1011 : DISPLAY = display_all[20:14];
            default:  DISPLAY = display_all[27:21];
        endcase
    end
endmodule // SevenSegDisplay