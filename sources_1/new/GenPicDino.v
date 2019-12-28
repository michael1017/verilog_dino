`define DINO_X 70
`define DINO_HEIGHT 49
`define DINO_WIDTH 44
module GenPicDino(
    input wire clk,
    input wire rst,
    input wire [8:0] pos,
    input wire [9:0] h_cnt,
    input wire [9:0] v_cnt,
    output wire [3:0] vgaRed,
    output wire [3:0] vgaGreen,
    output wire [3:0] vgaBlue
    );
    wire [11:0] data;
    wire clk_div2;
    wire clk_div22;
    wire [16:0] pixel_addr;
    wire [11:0] pixel;
    wire valid;
    wire [8:0] h_addr, v_addr, h_start, v_start;
    //wire in_update_space;


    assign {vgaRed, vgaGreen, vgaBlue} = valid ? pixel : 12'hFFF;  
    //assign {vgaRed, vgaGreen, vgaBlue} = pixel;
    assign valid = (h_start < h_addr && h_addr < `DINO_X) && (v_start < v_addr && v_addr < pos);
    assign h_addr = h_cnt;
    assign v_addr = v_cnt;
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
        .dina(data[11:0]),
        .douta(pixel)
    );
endmodule