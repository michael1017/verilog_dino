`define GROUND 150
`define DANGER1_HEIGHT 40
`define DANGER1_WIDTH 26
module GenPicDanger(
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
    reg [11:0] pixel;
    wire [11:0] next_pixel;
    wire valid;
    wire [8:0] h_addr, v_addr, h_start, v_start;


    assign {vgaRed, vgaGreen, vgaBlue} = valid ? pixel : 12'hFFF;  
    assign valid = (h_start < h_addr && h_addr < pos) && (v_start < v_addr && v_addr < `GROUND);
    assign h_addr = h_cnt>>1;
    assign v_addr = v_cnt>>1;
    assign h_start = pos > `DANGER1_WIDTH ? pos - `DANGER1_WIDTH : 0;
    assign v_start = `GROUND - `DANGER1_HEIGHT;

    ClockDivider #(2) clk2(clk, clk_div2);
    ClockDivider #(22) clk22(clk, clk_div22);

    always @ * begin
        if (v_addr == 220) begin
            pixel = next_pixel;
        end else begin
            pixel = pixel;
        end
    end

    mem_addr_gen #(`DANGER1_WIDTH, `DANGER1_HEIGHT) mem_danger(
        .clk(clk_div2),
        .rst(rst),
        .pos_x(pos),
        .pos_y(`GROUND),
        .h_cnt(h_cnt),
        .v_cnt(v_cnt),
        .pixel_addr(pixel_addr)
    );

    blk_mem_gen_2 danger(
        .clka(clk_div2),
        .wea(0),
        .addra(pixel_addr),
        .dina(data[11:0]),
        .douta(next_pixel)
    );
endmodule