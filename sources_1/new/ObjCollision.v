`define GAME_INIT  0
`define GAME_START 1
`define GAME_END   2
`define GAME_RESET 3

module ObjColision(
    input clk,
    input [11:0] dinoRGB,
    input [11:0] dangerRGB,
    input [1:0] game_state,
    output reg isColision = 0   
    );

    always @ (posedge clk) begin
        if (isColision == 0) begin
            if (game_state == `GAME_START) begin
                isColision = (dinoRGB | dangerRGB) != 12'hFFF;
            end else begin
                isColision = 0;
            end
        end else begin
            if (game_state == `GAME_RESET) begin
                isColision = 0;
            end else begin
                isColision = 1;
            end
        end
        
    end
endmodule