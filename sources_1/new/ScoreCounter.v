`define GAME_INIT  0
`define GAME_START 1
`define GAME_END   2
`define GAME_RESET 3

`define ZERO 7'b1000000
`define ONE 7'b1111001
`define TWO 7'b0100100
`define THREE 7'b0110000
`define FOUR 7'b0011001
`define FIVE 7'b0010010
`define SIX 7'b0000010
`define SEVEN 7'b1111000
`define EIGHT 7'b0000000
`define NINE 7'b0010000
module ScoreCounter(
    input game_clk,
    input rst,
    input game_state,
    input mode,
    output reg [27:0] display_all,
    output reg [13:0] score
    );
    reg [13:0] high_score;
    reg [4:0] counter;
    reg [27:0] display_score, display_high_score;

    always @ (posedge game_clk or posedge rst) begin
        if (rst) begin
            score = 0;
            high_score = 0;
            counter = 0;
        end else if (game_state == `GAME_START) begin
            if (counter == 19) begin
                score = score + 1;
                counter = 0;
            end else begin
                counter = counter + 1;
            end
        end else if (game_state == `GAME_END) begin
            
        end else if (game_state == `GAME_RESET) begin
            score = 0;
            counter = 0;
        end else begin 

        end
    end
    always @ (*) begin
        if (mode == 0) begin
            display_all = display_score;
        end else begin
            display_all = display_high_score;
        end
    end
    always @ (*) begin
        case (score/1000)
            1:display_score[27:21] = `ONE;
            2:display_score[27:21] = `TWO;
            3:display_score[27:21] = `THREE;
            4:display_score[27:21] = `FOUR;
            5:display_score[27:21] = `FIVE;
            6:display_score[27:21] = `SIX;
            7:display_score[27:21] = `SEVEN;
            8:display_score[27:21] = `EIGHT;
            9:display_score[27:21] = `NINE;
            default :display_score[27:21] = `ZERO;
        endcase
        case ((score/100) % 10)
            1:display_score[20:14] = `ONE;
            2:display_score[20:14] = `TWO;
            3:display_score[20:14] = `THREE;
            4:display_score[20:14] = `FOUR;
            5:display_score[20:14] = `FIVE;
            6:display_score[20:14] = `SIX;
            7:display_score[20:14] = `SEVEN;
            8:display_score[20:14] = `EIGHT;
            9:display_score[20:14] = `NINE;
            default :display_score[20:14] = `ZERO;
        endcase
        case ((score/10) % 10)
            1:display_score[13:7] = `ONE;
            2:display_score[13:7] = `TWO;
            3:display_score[13:7] = `THREE;
            4:display_score[13:7] = `FOUR;
            5:display_score[13:7] = `FIVE;
            6:display_score[13:7] = `SIX;
            7:display_score[13:7] = `SEVEN;
            8:display_score[13:7] = `EIGHT;
            9:display_score[13:7] = `NINE;
            default :display_score[13:7] = `ZERO;
        endcase
        case (score % 10)
            1:display_score[6:0] = `ONE;
            2:display_score[6:0] = `TWO;
            3:display_score[6:0] = `THREE;
            4:display_score[6:0] = `FOUR;
            5:display_score[6:0] = `FIVE;
            6:display_score[6:0] = `SIX;
            7:display_score[6:0] = `SEVEN;
            8:display_score[6:0] = `EIGHT;
            9:display_score[6:0] = `NINE;
            default :display_score[6:0] = `ZERO;
        endcase

        case (high_score/1000)
            1:display_high_score[27:21] = `ONE;
            2:display_high_score[27:21] = `TWO;
            3:display_high_score[27:21] = `THREE;
            4:display_high_score[27:21] = `FOUR;
            5:display_high_score[27:21] = `FIVE;
            6:display_high_score[27:21] = `SIX;
            7:display_high_score[27:21] = `SEVEN;
            8:display_high_score[27:21] = `EIGHT;
            9:display_high_score[27:21] = `NINE;
            default :display_high_score[27:21] = `ZERO;
        endcase
        case ((high_score/100) % 10)
            1:display_high_score[20:14] = `ONE;
            2:display_high_score[20:14] = `TWO;
            3:display_high_score[20:14] = `THREE;
            4:display_high_score[20:14] = `FOUR;
            5:display_high_score[20:14] = `FIVE;
            6:display_high_score[20:14] = `SIX;
            7:display_high_score[20:14] = `SEVEN;
            8:display_high_score[20:14] = `EIGHT;
            9:display_high_score[20:14] = `NINE;
            default :display_high_score[20:14] = `ZERO;
        endcase
        case ((high_score/10) % 10)
            1:display_high_score[13:7] = `ONE;
            2:display_high_score[13:7] = `TWO;
            3:display_high_score[13:7] = `THREE;
            4:display_high_score[13:7] = `FOUR;
            5:display_high_score[13:7] = `FIVE;
            6:display_high_score[13:7] = `SIX;
            7:display_high_score[13:7] = `SEVEN;
            8:display_high_score[13:7] = `EIGHT;
            9:display_high_score[13:7] = `NINE;
            default :display_high_score[13:7] = `ZERO;
        endcase
        case (high_score % 10)
            1:display_high_score[6:0] = `ONE;
            2:display_high_score[6:0] = `TWO;
            3:display_high_score[6:0] = `THREE;
            4:display_high_score[6:0] = `FOUR;
            5:display_high_score[6:0] = `FIVE;
            6:display_high_score[6:0] = `SIX;
            7:display_high_score[6:0] = `SEVEN;
            8:display_high_score[6:0] = `EIGHT;
            9:display_high_score[6:0] = `NINE;
            default :display_high_score[6:0] = `ZERO;
        endcase

    end
endmodule // ScoreCounter