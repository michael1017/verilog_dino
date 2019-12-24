`define DINO_X  50
`define ENTER 9'b0_0101_1010
`define SPACE 9'b0_0010_1001
`define UP    9'b1_0111_0101
`define DOWN  9'b1_0111_0010

`define UP_STATUS 0
`define FALL_STATUS 1
`define STATIC_STATUS 2

module ObjCtrl(
    input wire clk, 
    input wire rst, 
    input wire game_clk,
    output reg [8:0] dino_pos, 
    output reg [8:0] danger_pos1, 
    output reg [8:0] danger_pos2,
    output reg [8:0] danger_pos3,
    output reg [1:0] danger_num,
    inout wire PS2_DATA,
    inout wire PS2_CLK
    );
    wire clk_div15, clk_div29, clk_div19;
    //keyboard kin();
    ClockDivider #(15) clk15(clk, clk_div15);
    ClockDivider #(23) clk29(clk, clk_div29);
    ClockDivider #(19) clk19(clk, clk_div19);

    wire  keyin;
    wire [3:0] key_num;
    KeyboardValue kbv(
        .key_num(key_num),
        .keyin(keyin),
        .PS2_DATA(PS2_DATA),
        .PS2_CLK(PS2_CLK),
        .rst(rst),
        .clk(clk)
	);

    //wire keyin_o;
    //OnePulse okeyboard(keyin_o, keyin, clk_div29);
    reg [1:0] gravity = 3;
    reg [2:0] jump_speed;
    reg [5:0] down_speed;
    reg [3:0] up_speed = 9;
    reg [3:0] jump_counter;
    reg [1:0] dino_status;

    always @ (posedge game_clk or posedge rst) begin
        if (rst == 1) begin
            danger_num = 1;
            dino_pos = `GROUND;
            danger_pos1 = 150;
            danger_pos2 = 150;
            danger_pos2 = 150;
            dino_status = `STATIC_STATUS;

        end else begin
            danger_num = 1;
            if (danger_pos1 != 0) begin
                danger_pos1 = danger_pos1 - 1;
            end else begin
                danger_pos1 = 319;
            end
            if (keyin == 1 && key_num == 2) begin
                if (dino_status == `STATIC_STATUS) begin
                    dino_status = `UP_STATUS;
                end else if (dino_status == `UP_STATUS) begin
                    jump_counter = jump_counter + 1;
                    if (jump_counter == 15) begin
                        dino_status = `FALL_STATUS;
                    end else begin
                        jump_speed = up_speed;
                    end 
                end else begin

                end 
            end else begin

            end 
        end
    end
endmodule