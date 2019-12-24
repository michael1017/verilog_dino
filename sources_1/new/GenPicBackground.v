module GenPicBackground(
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
    wire [16:0] pixel_addr;
    wire [11:0] pixel;
    wire [11:0] pixel_next;
    reg [8:0] xpos, ypos;
    wire valid;

    assign {vgaRed, vgaGreen, vgaBlue} = pixel_next;  
    //assign valid = 0 <= v_cnt>>1 && v_cnt>>1 <= ypos ;
    //assign pixel = valid ? pixel : pixel_next;

    ClockDivider #(2) clk2(clk, clk_div2);
    ClockDivider #(22) clk22(clk, clk_div22);
    
    always @ (posedge game_clk or posedge rst) begin
        if (rst == 1) begin
            xpos = 320;
            ypos = 240;
        end else begin
            if (xpos == 0) begin
                xpos = 320;
            end else begin
                xpos = xpos - 1;
            end
        end
    end
    
    mem_addr_gen mem_background(
        .clk(clk_div2),
        .rst(rst),
        .pos_x(xpos),
        .pos_y(ypos),
        .h_cnt(h_cnt),
        .v_cnt(v_cnt),
        .pixel_addr(pixel_addr)
    );

    blk_mem_gen_0 background(
        .clka(clk_div2),
        .wea(0),
        .addra(pixel_addr),
        .dina(data[11:0]),
        .douta(pixel_next)
    );
endmodule