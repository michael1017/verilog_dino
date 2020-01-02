`define GROUND 298
`define HIGH_SKY 250
`define LOW_SKY 290
`define BIG_CACTUS_HEIGHT 50
`define BIG_CACTUS_WIDTH 27
`define SMALL_CACTUS_HEIGHT 36
`define SMALL_CACTUS_WIDTH 19
`define MANY_CACTUS_HEIGHT 49
`define MANY_CACTUS_WIDTH 77 
`define BIRD_HEIGHT 42
`define BIRD_WIDTH 47

`define LOW_BIRD     0
`define HIGH_BIRD    1
`define SMALL_CACTUS 2
`define MANY_CACTUS  3
`define BIG_CACTUS   4
`define NOTHING      5

`define GAME_INIT  0
`define GAME_START 1
`define GAME_END   2
`define GAME_RESET 3
module GenPicDanger(
    input wire clk,
    input wire rst,
    input wire [9:0] new_danger_pos1, 
    input wire [9:0] new_danger_pos2, 
    input wire [9:0] new_danger_pos3, 
    input wire [2:0] danger_type1,
    input wire [2:0] danger_type2,
    input wire [2:0] danger_type3,
    input wire danger_en1,
    input wire danger_en2,
    input wire danger_en3,
    input wire [9:0] h_cnt,
    input wire [9:0] v_cnt,
    input wire [1:0] game_state,
    output wire [3:0] vgaRed,
    output wire [3:0] vgaGreen,
    output wire [3:0] vgaBlue
    );
    wire [11:0] data;
    wire clk_div2;
    wire clk_div22, clk_div25;
    wire [16:0] pixel_addr1, pixel_addr2, pixel_addr3;
    reg [16:0] pixel_addr_cb, pixel_addr_cs, pixel_addr_cm, pixel_addr_bd;
    reg [6:0] danger_width1, danger_width2, danger_width3;
    reg [6:0] danger_height1, danger_height2, danger_height3;
    reg [9:0] danger_y1, danger_y2, danger_y3; // y_position
    reg [11:0] pixel1, pixel2, pixel3;
    wire [11:0] pixel_cb, pixel_cs, pixel_cm, pixel_bd;
    wire [11:0] pixel_bd_low, pixel_bd_high;
    wire valid1, valid2, valid3;
    reg [9:0] danger_pos1, danger_pos2, danger_pos3;
    wire on_edge1, on_edge2, on_edge3;
    wire is_game_start;
    wire [9:0] danger_h_start1, danger_h_start2, danger_h_start3;
    //wire [8:0] h_start1, h_start2, h_start3, v_start1, v_start2, v_start3;


    assign {vgaRed, vgaGreen, vgaBlue} = pixel1 & pixel2 & pixel3;  
    //assign h_start1 = (danger_pos1 > danger_width1 ? danger_pos1 - danger_width1 : 0);
    //assign h_start2 = (danger_pos2 > danger_width2 ? danger_pos2 - danger_width2 : 0);
    //assign h_start3 = (danger_pos3 > danger_width3 ? danger_pos3 - danger_width3 : 0);
    //assign v_start1 = (danger_y1 - danger_height1);
    //assign v_start2 = (danger_y2 - danger_height2);
    //assign v_start3 = (danger_y3 - danger_height3);
    assign valid1 = (danger_h_start1 < h_cnt && h_cnt <= danger_pos1) && ((danger_y1 - danger_height1) < v_cnt && v_cnt < danger_y1);
    assign valid2 = (danger_h_start2 < h_cnt && h_cnt <= danger_pos2) && ((danger_y2 - danger_height2) < v_cnt && v_cnt < danger_y2);
    assign valid3 = (danger_h_start3 < h_cnt && h_cnt <= danger_pos3) && ((danger_y3 - danger_height3) < v_cnt && v_cnt < danger_y3);
    assign on_edge1 = danger_pos1 > danger_width1 ? (h_cnt == (danger_pos1 - danger_width1 + 1)) || (h_cnt == (danger_pos1 - danger_width1)) : (h_cnt == 0);
    assign on_edge2 = danger_pos2 > danger_width2 ? (h_cnt == (danger_pos2 - danger_width2 + 1)) || (h_cnt == (danger_pos2 - danger_width2)) : (h_cnt == 0);
    assign on_edge3 = danger_pos3 > danger_width3 ? (h_cnt == (danger_pos3 - danger_width3 + 1)) || (h_cnt == (danger_pos3 - danger_width3)) : (h_cnt == 0);
    assign danger_h_start1 = danger_pos1 > danger_width1 ? danger_pos1 - danger_width1 + 1: 0;
    assign danger_h_start2 = danger_pos2 > danger_width2 ? danger_pos2 - danger_width2 + 1: 0;
    assign danger_h_start3 = danger_pos3 > danger_width3 ? danger_pos3 - danger_width3 + 1: 0;
    assign pixel_bd = is_game_start ? (clk_div25 ? pixel_bd_low : pixel_bd_high) : pixel_bd_low;
    assign is_game_start = game_state == `GAME_START;
    
    ClockDivider #(2) clk2(clk, clk_div2);
    ClockDivider #(22) clk22(clk, clk_div22);
    ClockDivider #(25) clk25(clk, clk_div25);

    always @ (posedge clk) begin
        if (v_cnt  ==  `GROUND + 10) begin
            danger_pos1 = new_danger_pos1;
            danger_pos2 = new_danger_pos2;
            danger_pos3 = new_danger_pos3;
        end else begin
            // do nothing
        end
    end
    always @ (posedge clk) begin
        if (danger_en1 == 1) begin
            if (danger_type1 == `SMALL_CACTUS) begin
                danger_height1 = `SMALL_CACTUS_HEIGHT;
                danger_width1 = `SMALL_CACTUS_WIDTH;
                danger_y1 = `GROUND;
                if (valid1 == 1) begin
                    pixel1 = pixel_cs;
                    pixel_addr_cs = pixel_addr1;
                end else if (on_edge1 == 1) begin
                    pixel_addr_cs = pixel_addr1;
                end else begin
                    pixel1 = 12'hFFF;
                end
            end else if (danger_type1 == `MANY_CACTUS) begin
                danger_height1 = `MANY_CACTUS_HEIGHT;
                danger_width1 = `MANY_CACTUS_WIDTH;
                danger_y1 = `GROUND;
                if (valid1 == 1) begin
                    pixel1 = pixel_cm;
                    pixel_addr_cm = pixel_addr1;
                end else if (on_edge1 == 1) begin
                    pixel_addr_cm = pixel_addr1;
                end else begin
                    pixel1 = 12'hFFF;
                end
            end else if (danger_type1 == `BIG_CACTUS) begin
                danger_height1 = `BIG_CACTUS_HEIGHT;
                danger_width1 = `BIG_CACTUS_WIDTH;
                danger_y1 = `GROUND;
                if (valid1 == 1) begin
                    pixel1 = pixel_cb;
                    pixel_addr_cb = pixel_addr1;
                end else if (on_edge1 == 1) begin
                    pixel_addr_cb = pixel_addr1;
                end else begin
                    pixel1 = 12'hFFF;
                end
            end else if (danger_type1 == `LOW_BIRD) begin
                danger_height1 = `BIRD_HEIGHT;
                danger_width1 = `BIRD_WIDTH;
                danger_y1 = `LOW_SKY;
                if (valid1 == 1) begin
                    pixel1 = pixel_bd;
                    pixel_addr_bd = pixel_addr1;
                end else if (on_edge1 == 1) begin
                    pixel_addr_bd = pixel_addr1;
                end else begin
                    pixel1 = 12'hFFF;
                end
            end else if (danger_type1 == `HIGH_BIRD) begin
                danger_height1 = `BIRD_HEIGHT;
                danger_width1 = `BIRD_WIDTH;
                danger_y1 = `HIGH_SKY;
                if (valid1 == 1) begin
                    pixel1 = pixel_bd;
                    pixel_addr_bd = pixel_addr1;
                end else if (on_edge1 == 1) begin
                    pixel_addr_bd = pixel_addr1;
                end else begin
                    pixel1 = 12'hFFF;
                end
            end else begin
                pixel1 = 12'hFFF;
            end
        end else begin
            pixel1 = 12'hFFF;
        end
        if (danger_en2 == 1) begin
            if (danger_type2 == `SMALL_CACTUS) begin
                danger_height2 = `SMALL_CACTUS_HEIGHT;
                danger_width2 = `SMALL_CACTUS_WIDTH;  
                danger_y2 = `GROUND;
                if (valid2 == 1) begin
                    pixel2 = pixel_cs;
                    pixel_addr_cs = pixel_addr2;
                end else if (on_edge2 == 1) begin
                    pixel_addr_cs = pixel_addr2;
                end else begin
                    pixel2 = 12'hFFF;
                end
            end else if (danger_type2 == `MANY_CACTUS) begin
                danger_height2 = `MANY_CACTUS_HEIGHT;
                danger_width2 = `MANY_CACTUS_WIDTH;
                danger_y2 = `GROUND;
                if (valid2 == 1) begin
                    pixel2 = pixel_cm;
                    pixel_addr_cm = pixel_addr2;
                end else if (on_edge2 == 1) begin
                    pixel_addr_cm = pixel_addr2;
                end else begin
                    pixel2 = 12'hFFF;
                end
            end else if (danger_type2 == `BIG_CACTUS) begin
                danger_height2 = `BIG_CACTUS_HEIGHT;
                danger_width2 = `BIG_CACTUS_WIDTH;
                danger_y2 = `GROUND;
                if (valid2 == 1) begin
                    pixel2 = pixel_cb;
                    pixel_addr_cb = pixel_addr2;
                end else if (on_edge2 == 1) begin
                    pixel_addr_cb = pixel_addr2;
                end else begin
                    pixel2 = 12'hFFF;
                end
            end else if (danger_type2 == `LOW_BIRD) begin
                danger_height2 = `BIRD_HEIGHT;
                danger_width2 = `BIRD_WIDTH;
                danger_y2 = `LOW_SKY;
                if (valid2 == 1) begin
                    pixel2 = pixel_bd;
                    pixel_addr_bd = pixel_addr2;
                end else if (on_edge2 == 1) begin
                    pixel_addr_bd = pixel_addr2;
                end else begin
                    pixel2 = 12'hFFF;
                end
            end else if (danger_type2 == `HIGH_BIRD) begin
                danger_height2 = `BIRD_HEIGHT;
                danger_width2 = `BIRD_WIDTH;
                danger_y2 = `HIGH_SKY;
                if (valid2 == 1) begin
                    pixel2 = pixel_bd;
                    pixel_addr_bd = pixel_addr2;
                end else if (on_edge2 == 1) begin
                    pixel_addr_bd = pixel_addr2;
                end else begin
                    pixel2 = 12'hFFF;
                end
            end else begin
                pixel2 = 12'hFFF;
            end
        end else begin
            pixel2 = 12'hFFF;
        end
        if (danger_en3 == 1) begin
            if (danger_type3 == `SMALL_CACTUS) begin
                danger_height3 = `SMALL_CACTUS_HEIGHT;
                danger_width3 = `SMALL_CACTUS_WIDTH;
                danger_y3 = `GROUND;
                if (valid3 == 1) begin
                    pixel3 = pixel_cs;
                    pixel_addr_cs = pixel_addr3;
                end else if (on_edge3 == 1) begin
                    pixel_addr_cs = pixel_addr3;
                end else begin
                    pixel3 = 12'hFFF;
                end
            end else if (danger_type3 == `MANY_CACTUS) begin
                danger_height3 = `MANY_CACTUS_HEIGHT;
                danger_width3 = `MANY_CACTUS_WIDTH;
                danger_y3 = `GROUND;
                if (valid3 == 1) begin
                    pixel3 = pixel_cm;
                    pixel_addr_cm = pixel_addr3;
                end else if (on_edge3 == 1) begin
                    pixel_addr_cm = pixel_addr3;
                end else begin
                    pixel3 = 12'hFFF;
                end
            end else if (danger_type3 == `BIG_CACTUS) begin
                danger_height3 = `BIG_CACTUS_HEIGHT;
                danger_width3 = `BIG_CACTUS_WIDTH;
                danger_y3 = `GROUND;
                if (valid3 == 1) begin
                    pixel3 = pixel_cb;
                    pixel_addr_cb = pixel_addr3;
                end else if (on_edge3 == 1) begin
                    pixel_addr_cb = pixel_addr3;
                end else begin
                    pixel3 = 12'hFFF;
                end
            end else if (danger_type3 == `LOW_BIRD) begin
                danger_height3 = `BIRD_HEIGHT;
                danger_width3 = `BIRD_WIDTH;
                danger_y3 = `LOW_SKY;
                if (valid3 == 1) begin
                    pixel3 = pixel_bd;
                    pixel_addr_bd = pixel_addr3;
                end else if (on_edge3 == 1) begin
                    pixel_addr_bd = pixel_addr3;
                end else begin
                    pixel3 = 12'hFFF;
                end
            end else if (danger_type3 == `HIGH_BIRD) begin
                danger_height3 = `BIRD_HEIGHT;
                danger_width3 = `BIRD_WIDTH;
                danger_y3 = `HIGH_SKY;
                if (valid3 == 1) begin
                    pixel3 = pixel_bd;
                    pixel_addr_bd = pixel_addr3;
                end else if (on_edge3 == 1) begin
                    pixel_addr_bd = pixel_addr3;
                end else begin
                    pixel3 = 12'hFFF;
                end
            end else begin
                pixel3 = 12'hFFF;
            end
        end else begin
            pixel3 = 12'hFFF;
        end
    end

    mem_addr_gen_plus  mem_danger1(
        .clk(clk_div2),
        .rst(rst),
        .width(danger_width1),
        .height(danger_height1),
        .pos_x(danger_pos1),
        .pos_y(danger_y1),
        .h_cnt(h_cnt),
        .v_cnt(v_cnt),
        .pixel_addr(pixel_addr1)
    );
    mem_addr_gen_plus  mem_danger2(
        .clk(clk_div2),
        .rst(rst),
        .width(danger_width2),
        .height(danger_height2),
        .pos_x(danger_pos2),
        .pos_y(danger_y2),
        .h_cnt(h_cnt),
        .v_cnt(v_cnt),
        .pixel_addr(pixel_addr2)
    );
    mem_addr_gen_plus  mem_danger3(
        .clk(clk_div2),
        .rst(rst),
        .width(danger_width3),
        .height(danger_height3),
        .pos_x(danger_pos3),
        .pos_y(danger_y3),
        .h_cnt(h_cnt),
        .v_cnt(v_cnt),
        .pixel_addr(pixel_addr3)
    );
    cactusBig cb(.clka(clk_div2), .wea(0), .addra(pixel_addr_cb), .dina(0), .douta(pixel_cb));
    cactusSmall cs(.clka(clk_div2), .wea(0), .addra(pixel_addr_cs), .dina(0), .douta(pixel_cs));
    cactusMany cm(.clka(clk_div2), .wea(0), .addra(pixel_addr_cm), .dina(0), .douta(pixel_cm));
    bird bd(.clka(clk_div2), .wea(0), .addra(pixel_addr_bd), .dina(0), .douta(pixel_bd_low));
    bird_high bh(.clka(clk_div2), .wea(0), .addra(pixel_addr_bd), .dina(0), .douta(pixel_bd_high));
endmodule