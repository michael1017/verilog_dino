`define GAME_INIT  0
`define GAME_START 1
`define GAME_END   2
`define GAME_RESET 3

module GameClock(
    input wire clk,
    input wire rst,
    input [1:0] game_state,
    output reg clk_div
    );

    reg [27:0] counter;
    reg [27:0] divider;
    reg [14:0] full;

    wire clk_div21;
    ClockDivider #(23) clk21(clk, clk_div21);
    
    always @ (posedge clk, posedge rst) begin
        if (rst == 1'b1) begin
            counter <= 0;
            divider <= 150000;
            full <= 0;
            clk_div <= 1;
        end else begin
            if (game_state == `GAME_START) begin
                if(counter < divider) begin
                    counter <= counter + 1;
                end else begin
                    if (full == 3499) begin
                        full <= 0;
                        if (divider > 122000) begin
                            divider <= divider - 4000;
                        end else begin
                            divider <= divider;
                        end
                    end else begin
                        full <= full + 1;
                    end
                    clk_div <= ~clk_div;
                    counter <= 0;
                end
            end else if (game_state == `GAME_END) begin
                clk_div <= clk_div21;
            end else if (game_state == `GAME_RESET) begin
                clk_div <= clk_div21;
                counter <= 0;
                divider <= 150000;
                full <= 0;
            end else begin
                clk_div <= clk_div21;
                counter <= 0;
                divider <= 150000;
                full <= 0;
            end
            
        end
    end
endmodule