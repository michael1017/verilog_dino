`define TURN_LIGHT 0 
`define TURN_DARK 1 
module AnimateDark (
    input clk,
    input [13:0] game_score,
    input [3:0] OldVgaRed,
    input [3:0] OldVgaGreen,
    input [3:0] OldVgaBlue,
    output wire [3:0] NewVgaRed,
    output wire [3:0] NewVgaGreen,
    output wire [3:0] NewVgaBlue
    );

    wire clk_div21;
    ClockDivider #(21) c21(clk, clk_div21);

    reg [3:0] counter;
    reg state = `TURN_LIGHT;
    reg [13:0] old_score;

    assign NewVgaRed = OldVgaRed >= counter ? OldVgaRed - counter : counter - OldVgaRed;
    assign NewVgaGreen = OldVgaGreen >= counter ? OldVgaGreen - counter : counter - OldVgaGreen;
    assign NewVgaBlue = OldVgaBlue >= counter ? OldVgaBlue - counter : counter - OldVgaBlue;
    always @ (posedge clk) begin
        if (game_score % 700 == 0 && game_score != 0) begin
            state = `TURN_DARK;
            old_score = score;
        end else if (score - old_score == 150 && state == `TURN_DARK) begin
            state = `TURN_LIGHT;
        end else  begin

        end
    end

    always @ (posedge clk_div21) begin
        if (state == `TURN_DARK) begin
            if (counter != 15) begin
                counter = counter + 1;
            end else begin 
                counter = counter;
            end
        end else  begin // state == `TURN_LIGHT
            if (counter != 0) begin
                counter = counter - 1;
            end else begin 
                counter = counter;
            end
        end
    end 
    
endmodule