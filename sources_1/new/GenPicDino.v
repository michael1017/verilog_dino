`define DINO_X 80
`define DINO_HEIGHT 49
`define DINO_WIDTH 44
module GenPicDino(
    input wire clk,
    input wire rst,
    input wire [9:0] pos,
    input wire [9:0] h_cnt,
    input wire [9:0] v_cnt,
    output wire [3:0] vgaRed,
    output wire [3:0] vgaGreen,
    output wire [3:0] vgaBlue
    );
    wire clk_div2;
    wire clk_div22;
    wire [16:0] pixel_addr;
    wire [11:0] pixel;
    wire valid;
    wire [8:0] h_addr, v_addr, h_start, v_start;
    //wire in_update_space;


    assign {vgaRed, vgaGreen, vgaBlue} = valid ? pixel : 12'hFFF;  
    //assign {vgaRed, vgaGreen, vgaBlue} = pixel;
    assign valid = (h_start + 1 < h_cnt && h_cnt < `DINO_X) && (v_start < v_cnt && v_cnt < pos);
    assign h_start = `DINO_X - `DINO_WIDTH;
    assign v_start = pos - `DINO_HEIGHT;
    //assign in_update_space = 

    ClockDivider #(2) clk2(clk, clk_div2);
    ClockDivider #(22) clk22(clk, clk_div22);

    mem_addr_gen #(`DINO_WIDTH, `DINO_HEIGHT) mem_background(
        .clk(clk_div2),
        .rst(rst),
        .pos_x(`DINO_X),
        .pos_y(pos),
        .h_cnt(h_cnt),
        .v_cnt(v_cnt),
        .pixel_addr(pixel_addr)
    );

    blk_mem_gen_1 dino(
        .clka(clk_div2),
        .wea(0),
        .addra(pixel_addr),
        .dina(0),
        .douta(pixel)
    );
endmodule