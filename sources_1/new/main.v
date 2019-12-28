`timescale 1ns / 1ps
module main(
    input wire clk,
    input wire rst,
    output wire [3:0] vgaRed,
    output wire [3:0] vgaGreen,
    output wire [3:0] vgaBlue,
    output wire hsync,
    output wire vsync,
    inout wire PS2_DATA,
    inout wire PS2_CLK
    );

    wire clk_div2, clk_div15, game_clk;
    ClockDivider #(2) clk2(clk, clk_div2);
    ClockDivider #(15) clk15(clk, clk_div15);
    GameClock gc(clk, rst, game_clk);

    wire [8:0] dino_pos, danger_pos1, danger_pos2, danger_pos3;
    wire [2:0] danger_type1, danger_type2, danger_type3;
    wire danger_en1, danger_en2, danger_en3;
    wire [1:0] danger_num;
    ObjCtrl obj(
        clk, 
        rst, 
        game_clk, 
        dino_pos, 
        danger_pos1, 
        danger_pos2, 
        danger_pos3, 
        danger_type1,
        danger_type2,
        danger_type3,
        danger_en1,
        danger_en2,
        danger_en3,
        PS2_DATA, 
        PS2_CLK
    );

    wire [9:0] h_cnt, v_cnt;
    wire valid;
    vga_controller vga_ctrl(clk_div2, rst, hsync, vsync, valid, h_cnt, v_cnt);

    wire [3:0] background_vgaRed, background_vgaGreen, background_vgaBlue;
    GenPicBackground GPB(clk, rst, game_clk, h_cnt, v_cnt, background_vgaRed, background_vgaGreen, background_vgaBlue);

    wire [3:0] dino_vgaRed, dino_vgaGreen, dino_vgaBlue;
    GenPicDino GPDino(clk, rst, dino_pos, h_cnt, v_cnt, dino_vgaRed, dino_vgaGreen, dino_vgaBlue);

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
        danger_vgaRed,
        danger_vgaGreen,   
        danger_vgaBlue
    );

    //assign {vgaRed, vgaGreen, vgaBlue} = (valid == 1'b1) ? {dino_vgaRed, dino_vgaGreen, dino_vgaBlue} : 12'h0;
    //assign {vgaRed, vgaGreen, vgaBlue} = (valid == 1'b1) ? {background_vgaRed, background_vgaGreen, background_vgaBlue} : 12'h0;
    //assign {vgaRed, vgaGreen, vgaBlue} = (valid == 1'b1) ? {background_vgaRed & dino_vgaRed, background_vgaGreen & dino_vgaGreen, background_vgaBlue & dino_vgaBlue} : 12'h0;
    assign {vgaRed, vgaGreen, vgaBlue} = (valid == 1'b1) ? 
    {background_vgaRed & dino_vgaRed & danger_vgaRed, background_vgaGreen & dino_vgaGreen & danger_vgaGreen, background_vgaBlue & dino_vgaBlue & danger_vgaBlue} : 12'h0;
    //{background_vgaRed & dino_vgaRed, background_vgaGreen & dino_vgaGreen, background_vgaBlue & dino_vgaBlue} : 12'b1111_1111_1111;
endmodule