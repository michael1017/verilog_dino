`timescale 1ns / 1ps

module main(
    input wire clk,
    input wire rst,
    input wire mode,
    input wire _mute,
    input wire _volUP,
    input wire _volDOWN,
    output wire [3:0] vgaRed,
    output wire [3:0] vgaGreen,
    output wire [3:0] vgaBlue,
    output wire hsync,
    output wire vsync,
    output wire [6:0] DISPLAY,
    output wire [3:0] DIGIT,
    output wire [4:0] _led_vol,
    output wire audio_mclk,
    output wire audio_lrck,
    output wire audio_sck,
    output wire audio_sdin,
    output wire [4:0] key_led,
    inout wire PS2_DATA,
    inout wire PS2_CLK
    );

    wire [3:0] raw_vgaRed, raw_vgaGreen, raw_vgaBlue;
    wire isColision;
    wire [1:0] game_state;
    wire clk_div2, clk_div15, game_clk, clk_div13;
    ClockDivider #(2) clk2(clk, clk_div2);
    ClockDivider #(13) clk13(clk, clk_div13);
    ClockDivider #(15) clk15(clk, clk_div15);
    GameClock gc(clk, rst, game_state, game_clk);

    wire [9:0] dino_pos, danger_pos1, danger_pos2, danger_pos3;
    wire [2:0] danger_type1, danger_type2, danger_type3;
    wire danger_en1, danger_en2, danger_en3;
    wire [1:0] danger_num;
    wire dino_behavior;
    ObjCtrl obj(
        .clk(clk), 
        .rst(rst), 
        .game_clk(game_clk), 
        .isColision(isColision),
        .dino_pos(dino_pos), 
        .danger_pos1(danger_pos1), 
        .danger_pos2(danger_pos2), 
        .danger_pos3(danger_pos3), 
        .danger_type1(danger_type1),
        .danger_type2(danger_type2),
        .danger_type3(danger_type3),
        .danger_en1(danger_en1),
        .danger_en2(danger_en2),
        .danger_en3(danger_en3),
        .game_state(game_state),
        .dino_behavior(dino_behavior),
        .key_led(key_led),
        .PS2_DATA(PS2_DATA), 
        .PS2_CLK(PS2_CLK)
    );

    wire [9:0] h_cnt, v_cnt;
    wire valid;
    vga_controller vga_ctrl(clk_div2, rst, hsync, vsync, valid, h_cnt, v_cnt);

    wire [3:0] background_vgaRed, background_vgaGreen, background_vgaBlue;
    GenPicBackground GPB(clk, rst, game_clk, h_cnt, v_cnt, game_state, background_vgaRed, background_vgaGreen, background_vgaBlue);

    wire [3:0] dino_vgaRed, dino_vgaGreen, dino_vgaBlue;
    GenPicDino GPDino(clk, rst, dino_pos, h_cnt, v_cnt, dino_behavior, game_state, dino_vgaRed, dino_vgaGreen, dino_vgaBlue);

    wire [3:0] danger_vgaRed, danger_vgaGreen, danger_vgaBlue;
    GenPicDanger GPDanger(
        clk, 
        rst, 
        danger_pos1, 
        danger_pos2, 
        danger_pos3, 
        danger_type1, 
        danger_type2, 
        danger_type3, 
        danger_en1, 
        danger_en2, 
        danger_en3,
        h_cnt,
        v_cnt,
        game_state,
        danger_vgaRed,
        danger_vgaGreen,   
        danger_vgaBlue
    );

    wire [27:0] display_all;
    wire [13:0] game_score;
    ScoreCounter SC(
        .game_clk(game_clk),
        .rst(rst),
        .game_state(game_state),
        .mode(mode),
        .display_all(display_all),
        .score(game_score)
    );

    SevenSegDisplay SSD(
        .display_all(display_all),
        .clk(clk_div13),
        .DISPLAY(DISPLAY), 
        .DIGIT(DIGIT)
    );

    SoundCtrl soundctrl(
        .clk(clk), // clock from crystal
        .rst(rst), // active high reset: BTNC
        ._mute(_mute), // SW: Mute
        ._volUP(_volUP), // BTN: Vol up
        ._volDOWN(_volDOWN), // BTN: Vol down
        .dino_pos(dino_pos),
        .game_score(game_score),
        ._led_vol(_led_vol), // LED: volume
        .audio_mclk(audio_mclk), // master clock
        .audio_lrck(audio_lrck), // left-right clock
        .audio_sck(audio_sck), // serial clock
        .audio_sdin(audio_sdin) // serial audio data input
    );

    AnimateDark AD(
        .clk(clk),
        .valid(valid),
        .game_score(game_score),
        .OldVgaRed(raw_vgaRed),
        .OldVgaGreen(raw_vgaGreen),
        .OldVgaBlue(raw_vgaBlue),
        .NewVgaRed(vgaRed),
        .NewVgaGreen(vgaGreen),
        .NewVgaBlue(vgaBlue)
    );
    
    
    ObjColision obj_colision(
        .rst(rst),
        .clk(clk),
        .dinoRGB({dino_vgaRed, dino_vgaGreen, dino_vgaBlue}),
        .dangerRGB({danger_vgaRed, danger_vgaGreen, danger_vgaBlue}),
        .game_state(game_state),
        .isColision(isColision)
    );
    //assign {vgaRed, vgaGreen, vgaBlue} = (valid == 1'b1) ? {dino_vgaRed, dino_vgaGreen, dino_vgaBlue} : 12'h0;
    //assign {vgaRed, vgaGreen, vgaBlue} = (valid == 1'b1) ? {background_vgaRed, background_vgaGreen, background_vgaBlue} : 12'h0;
    //assign {vgaRed, vgaGreen, vgaBlue} = (valid == 1'b1) ? {background_vgaRed & dino_vgaRed, background_vgaGreen & dino_vgaGreen, background_vgaBlue & dino_vgaBlue} : 12'h0;
    assign {raw_vgaRed, raw_vgaGreen, raw_vgaBlue} = (valid == 1'b1) ? 
    {background_vgaRed & dino_vgaRed & danger_vgaRed, background_vgaGreen & dino_vgaGreen & danger_vgaGreen, background_vgaBlue & dino_vgaBlue & danger_vgaBlue} : 12'h0;
    //{background_vgaRed & dino_vgaRed, background_vgaGreen & dino_vgaGreen, background_vgaBlue & dino_vgaBlue} : 12'b1111_1111_1111;
endmodule