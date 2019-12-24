`define TOP   80
`define PIC1  218
`define PIC2  224
`define PIC3  236
`define PIC4  242
`define PIC5  248
`define PIC6  254
`define PIC7  260
`define PIC8  272
`define PIC9  278
`define PIC10 284
`define PIC11 290
`define PIC12 296
`define PIC_WIDTH 6
`define PIC_HEIGHT 9

module GenPicScore(
    input wire clk,
    input wire rst,
    input wire game_clk,
    input wire [9:0] h_cnt,
    input wire [9:0] v_cnt,
    output wire [3:0] vgaRed,
    output wire [3:0] vgaGreen,
    output wire [3:0] vgaBlue
    );
    wire [11:0] data;
    wire clk_div2;
    wire clk_div22;
    wire [16:0] pixel_addr [0:11];
    wire [16:0] gen_addr [0:11];
    wire [11:0] pixel [0:11];
    wire valid;
    wire [8:0] h_addr, v_addr, h_start, v_start;


    assign {vgaRed, vgaGreen, vgaBlue} = valid ? pixel : 12'hFFF;  
    //assign {vgaRed, vgaGreen, vgaBlue} = pixel;
    assign valid = (h_start <= h_addr && h_addr < pos) && (v_start <= v_addr && v_addr < `GROUND);
    assign h_addr = h_cnt>>1;
    assign v_addr = v_cnt>>1;
    assign h_start = pos - `DANGER1_WIDTH;
    assign v_start = `GROUND - `DANGER1_HEIGHT;

    ClockDivider #(2) clk2(clk, clk_div2);
    ClockDivider #(22) clk22(clk, clk_div22);

    

    mem_addr_gen #(`PIC_WIDTH, `PIC_HEIGHT) mem_gen0(
        .clk(clk_div22),
        .rst(rst),
        .pos_x(`PIC1),
        .pos_y(`TOP),
        .h_cnt(h_cnt),
        .v_cnt(v_cnt),
        .pixel_addr(gen_addr[0])
    );
    mem_addr_gen #(`PIC_WIDTH, `PIC_HEIGHT) mem_gen1(
        .clk(clk_div22),
        .rst(rst),
        .pos_x(`PIC2),
        .pos_y(`TOP),
        .h_cnt(h_cnt),
        .v_cnt(v_cnt),
        .pixel_addr(gen_addr[1])
    );
    mem_addr_gen #(`PIC_WIDTH, `PIC_HEIGHT) mem_gen2(
        .clk(clk_div22),
        .rst(rst),
        .pos_x(`PIC3),
        .pos_y(`TOP),
        .h_cnt(h_cnt),
        .v_cnt(v_cnt),
        .pixel_addr(gen_addr[2])
    );
    mem_addr_gen #(`PIC_WIDTH, `PIC_HEIGHT) mem_gen3(
        .clk(clk_div22),
        .rst(rst),
        .pos_x(`PIC4),
        .pos_y(`TOP),
        .h_cnt(h_cnt),
        .v_cnt(v_cnt),
        .pixel_addr(gen_addr[3])
    );
    mem_addr_gen #(`PIC_WIDTH, `PIC_HEIGHT) mem_gen4(
        .clk(clk_div22),
        .rst(rst),
        .pos_x(`PIC5),
        .pos_y(`TOP),
        .h_cnt(h_cnt),
        .v_cnt(v_cnt),
        .pixel_addr(gen_addr[4])
    );
    mem_addr_gen #(`PIC_WIDTH, `PIC_HEIGHT) mem_gen5(
        .clk(clk_div22),
        .rst(rst),
        .pos_x(`PIC6),
        .pos_y(`TOP),
        .h_cnt(h_cnt),
        .v_cnt(v_cnt),
        .pixel_addr(gen_addr[5])
    );
    mem_addr_gen #(`PIC_WIDTH, `PIC_HEIGHT) mem_gen6(
        .clk(clk_div22),
        .rst(rst),
        .pos_x(`PIC7),
        .pos_y(`TOP),
        .h_cnt(h_cnt),
        .v_cnt(v_cnt),
        .pixel_addr(gen_addr[6])
    );
    mem_addr_gen #(`PIC_WIDTH, `PIC_HEIGHT) mem_gen7(
        .clk(clk_div22),
        .rst(rst),
        .pos_x(`PIC8),
        .pos_y(`TOP),
        .h_cnt(h_cnt),
        .v_cnt(v_cnt),
        .pixel_addr(gen_addr[7])
    );
    mem_addr_gen #(`PIC_WIDTH, `PIC_HEIGHT) mem_gen8(
        .clk(clk_div22),
        .rst(rst),
        .pos_x(`PIC9),
        .pos_y(`TOP),
        .h_cnt(h_cnt),
        .v_cnt(v_cnt),
        .pixel_addr(gen_addr[8])
    );
    mem_addr_gen #(`PIC_WIDTH, `PIC_HEIGHT) mem_gen9(
        .clk(clk_div22),
        .rst(rst),
        .pos_x(`PIC10),
        .pos_y(`TOP),
        .h_cnt(h_cnt),
        .v_cnt(v_cnt),
        .pixel_addr(gen_addr[9])
    );
    mem_addr_gen #(`PIC_WIDTH, `PIC_HEIGHT) mem_gen10(
        .clk(clk_div22),
        .rst(rst),
        .pos_x(`PIC11),
        .pos_y(`TOP),
        .h_cnt(h_cnt),
        .v_cnt(v_cnt),
        .pixel_addr(gen_addr[10])
    );
    mem_addr_gen #(`PIC_WIDTH, `PIC_HEIGHT) mem_gen11(
        .clk(clk_div22),
        .rst(rst),
        .pos_x(`PIC12),
        .pos_y(`TOP),
        .h_cnt(h_cnt),
        .v_cnt(v_cnt),
        .pixel_addr(gen_addr[11])
    );

    Num0 n0(
        .clka(clk_div2),
        .wea(0),
        .addra(pixel_addr[0]),
        .dina(data[11:0]),
        .douta(pixel[0])
    );
    Num1 n1(
        .clka(clk_div2),
        .wea(0),
        .addra(pixel_addr[1]),
        .dina(data[11:0]),
        .douta(pixel[1])
    );
    Num2 n2(
        .clka(clk_div2),
        .wea(0),
        .addra(pixel_addr[2]),
        .dina(data[11:0]),
        .douta(pixel[2])
    );
    Num3 n3(
        .clka(clk_div2),
        .wea(0),
        .addra(pixel_addr[3]),
        .dina(data[11:0]),
        .douta(pixel[3])
    );
    Num4 n4(
        .clka(clk_div2),
        .wea(0),
        .addra(pixel_addr[4]),
        .dina(data[11:0]),
        .douta(pixel[4])
    );
    Num5 n5(
        .clka(clk_div2),
        .wea(0),
        .addra(pixel_addr[5]),
        .dina(data[11:0]),
        .douta(pixel[5])
    );
    Num6 n6(
        .clka(clk_div2),
        .wea(0),
        .addra(pixel_addr[6]),
        .dina(data[11:0]),
        .douta(pixel[6])
    );
    Num7 n7(
        .clka(clk_div2),
        .wea(0),
        .addra(pixel_addr[7]),
        .dina(data[11:0]),
        .douta(pixel[7])
    );
    Num8 n8(
        .clka(clk_div2),
        .wea(0),
        .addra(pixel_addr[8]),
        .dina(data[11:0]),
        .douta(pixel[8])
    );
    Num9 n9(
        .clka(clk_div2),
        .wea(0),
        .addra(pixel_addr[9]),
        .dina(data[11:0]),
        .douta(pixel[9])
    );
    AlphaH AH(
        .clka(clk_div2),
        .wea(0),
        .addra(pixel_addr[10]),
        .dina(data[11:0]),
        .douta(pixel[10])
    );
    AlphaI AI(
        .clka(clk_div2),
        .wea(0),
        .addra(pixel_addr[11]),
        .dina(data[11:0]),
        .douta(pixel[11])
    );

endmodule