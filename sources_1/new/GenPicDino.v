`define DINO_X 80
`define DINO_HEIGHT 49
`define DINO_WIDTH 44
`define DINO_SIT_WIDTH 59
`define DINO_SIT_HEIGHT 30

`define STAND_BEHAVIOR 1
`define SIT_BEHAVIOR   0
module GenPicDino(
    input wire clk,
    input wire rst,
    input wire [9:0] pos,
    input wire [9:0] h_cnt,
    input wire [9:0] v_cnt,
    input wire dino_behavior,
    output wire [3:0] vgaRed,
    output wire [3:0] vgaGreen,
    output wire [3:0] vgaBlue
    );
    wire clk_div2;
    wire clk_div22;
    wire [16:0] dino_pixel_addr;
    wire [11:0] dino_pixel;
    wire stand_valid;
    wire [8:0] stand_h_start, stand_v_start;
    wire [16:0] sit_right_pixel_addr;
    wire [11:0] sit_right_pixel;
    wire sit_valid;
    wire [8:0] sit_h_start, sit_v_start;
    wire [11:0] stand_RGB, sit_right_RGB; 
    //wire in_update_space;


    assign {vgaRed, vgaGreen, vgaBlue} = dino_behavior ? stand_RGB : sit_right_RGB;  
    assign stand_RGB = stand_valid ? dino_pixel : 12'hFFF;
    assign sit_right_RGB = sit_valid ? sit_right_pixel : 12'hFFF;
    //assign {vgaRed, vgaGreen, vgaBlue} = pixel;
    assign stand_valid = (stand_h_start + 1 < h_cnt && h_cnt < `DINO_X) && (stand_v_start < v_cnt && v_cnt < pos);
    assign sit_valid   = (sit_h_start   + 1 < h_cnt && h_cnt < `DINO_X) && (sit_v_start   < v_cnt && v_cnt < pos);
    assign stand_h_start = `DINO_X - `DINO_WIDTH;
    assign stand_v_start = pos - `DINO_HEIGHT;
    assign sit_h_start = `DINO_X - `DINO_SIT_WIDTH;
    assign sit_v_start = pos - `DINO_SIT_HEIGHT;
    //assign in_update_space = 

    ClockDivider #(2) clk2(clk, clk_div2);
    ClockDivider #(22) clk22(clk, clk_div22);

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
endmodule