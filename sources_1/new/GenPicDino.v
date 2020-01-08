`define DINO_X 80
`define DINO_HEIGHT 49
`define DINO_WIDTH 44
`define DINO_SIT_WIDTH 59
`define DINO_SIT_HEIGHT 30
`define GROUND 298

`define GAME_INIT  0
`define GAME_START 1
`define GAME_END   2

`define GAME_RESET 3
`define STAND_BEHAVIOR 1
`define SIT_BEHAVIOR   0
module GenPicDino(
    input wire clk,
    input wire rst,
    input wire [9:0] pos,
    input wire [9:0] h_cnt,
    input wire [9:0] v_cnt,
    input wire dino_behavior,
    input wire [1:0] game_state,
    output wire [3:0] vgaRed,
    output wire [3:0] vgaGreen,
    output wire [3:0] vgaBlue
    );
    wire clk_div2;
    wire clk_div22;
    wire [16:0] dino_pixel_addr;
    wire [11:0] dino_pixel, dino_right_pixel, dino_left_pixel, dino_dead_pixel;
    wire stand_valid;
    wire [8:0] stand_h_start, stand_v_start;

    wire [16:0] sit_right_pixel_addr, sit_left_pixel_addr;
    wire [11:0] sit_right_pixel, sit_left_pixel;
    wire sit_valid;
    wire [8:0] sit_h_start, sit_v_start;
    wire [11:0] stand_RGB, sit_right_RGB, sit_left_RGB, sit_RGB; 
    wire [11:0] run_RGB, dead_RGB;
    wire to_run, is_dead;
    //wire in_update_space;


    assign {vgaRed, vgaGreen, vgaBlue} = dino_behavior ? stand_RGB : sit_RGB;  

    assign stand_RGB = stand_valid ? (to_run ? run_RGB : dead_RGB) : 12'hFFF;
    assign run_RGB = clk_div22 ? dino_left_pixel : dino_right_pixel;
    assign dead_RGB = is_dead ? dino_dead_pixel : dino_pixel;

    assign sit_right_RGB = sit_valid ? sit_right_pixel : 12'hFFF;
    assign sit_left_RGB = sit_valid ? sit_left_pixel : 12'hFFF;
    assign sit_RGB = clk_div22 ? sit_left_RGB : sit_right_RGB;

    assign to_run = pos == `GROUND && game_state == `GAME_START;
    assign is_dead = game_state == `GAME_END;

    //assign {vgaRed, vgaGreen, vgaBlue} = pixel;
    assign stand_valid = (stand_h_start < h_cnt && h_cnt < `DINO_X) && (stand_v_start < v_cnt && v_cnt < pos);
    assign sit_valid   = (sit_h_start   < h_cnt && h_cnt < `DINO_X) && (sit_v_start   < v_cnt && v_cnt < pos);
    assign stand_h_start = `DINO_X - `DINO_WIDTH + 5;
    assign stand_v_start = pos - `DINO_HEIGHT;
    assign sit_h_start = `DINO_X - `DINO_SIT_WIDTH + 3;
    assign sit_v_start = pos - `DINO_SIT_HEIGHT;
    //assign in_update_space = 

    ClockDivider #(2) clk2(clk, clk_div2);
    ClockDivider #(24) clk22(clk, clk_div22);

    mem_addr_gen #(`DINO_WIDTH, `DINO_HEIGHT) mem_dino_stand(
        .clk(clk_div2),
        .rst(rst),
        .pos_x(`DINO_X),
        .pos_y(pos),
        .h_cnt(h_cnt),
        .v_cnt(v_cnt),
        .pixel_addr(dino_pixel_addr)
    );

    mem_addr_gen #(`DINO_SIT_WIDTH, `DINO_SIT_HEIGHT) sit_right_mem_gen(
        .clk(clk_div2),
        .rst(rst),
        .pos_x(`DINO_X),
        .pos_y(pos),
        .h_cnt(h_cnt),
        .v_cnt(v_cnt),
        .pixel_addr(sit_right_pixel_addr)
    );
     mem_addr_gen #(`DINO_SIT_WIDTH, `DINO_SIT_HEIGHT) sit_left_mem_gen(
        .clk(clk_div2),
        .rst(rst),
        .pos_x(`DINO_X),
        .pos_y(pos),
        .h_cnt(h_cnt),
        .v_cnt(v_cnt),
        .pixel_addr(sit_left_pixel_addr)
    );

    blk_mem_gen_1 dino(
        .clka(clk_div2),
        .wea(0),
        .addra(dino_pixel_addr),
        .dina(0),
        .douta(dino_pixel)
    );
    
    sit_right_dino sit_right(
        .clka(clk_div2),
        .wea(0),
        .addra(sit_right_pixel_addr),
        .dina(0),
        .douta(sit_right_pixel)
    );
    sit_left_dino sit_left(
        .clka(clk_div2),
        .wea(0),
        .addra(sit_left_pixel_addr),
        .dina(0),
        .douta(sit_left_pixel)
    );
    stand_right_dino srd(
        .clka(clk_div2),
        .wea(0),
        .addra(dino_pixel_addr),
        .dina(0),
        .douta(dino_right_pixel)
    );
    stand_left_dino sld(
        .clka(clk_div2),
        .wea(0),
        .addra(dino_pixel_addr),
        .dina(0),
        .douta(dino_left_pixel)
    );
    dino_dead dd(
        .clka(clk_div2),
        .wea(0),
        .addra(dino_pixel_addr),
        .dina(0),
        .douta(dino_dead_pixel)
    );
endmodule