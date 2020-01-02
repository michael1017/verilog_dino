`define BACKGROUND_WIDTH 1187
`define BACKGROUND_HEIGHT 14
`define BACKGROUND_YPOS 300

`define GAME_INIT  0
`define GAME_START 1
`define GAME_END   2
`define GAME_RESET 3

`define PIC_GAME_OVER_XPOS 419
`define PIC_GAME_OVER_YPOS 280
`define PIC_GAME_OVER_WIDTH  198
`define PIC_GAME_OVER_HEIGHT 71

`define CLOUD_WIDTH 52
`define CLOUD_HEIGHT 19
`define CLOUD_BASE 240

`define WINDOW_WIDTH 640
`define WINDOW_HEIGHT 480
module GenPicBackground(
    input wire clk,
    input wire rst,
    input wire game_clk,
    input wire [9:0] h_cnt,
    input wire [9:0] v_cnt,
    input wire [1:0] game_state,
    output wire [3:0] vgaRed,
    output wire [3:0] vgaGreen,
    output wire [3:0] vgaBlue
    );
    wire clk_div2;
    wire clk_div21;
    wire [6:0] ramdon_result;
    wire [16:0] pixel_addr;
    wire [11:0] pixel;
    wire [11:0] pixel_next;
    reg [10:0] xpos;
    wire valid;

    wire [16:0] game_over_pixel_addr;
    wire [11:0] game_over_pixel;
    wire game_over_valid;
    wire [11:0] gameRGB, backgroundRGB;

    wire [16:0] cloud_pixel_addr1, cloud_pixel_addr2, cloud_pixel_addr3;
    wire [11:0] cloud_pixel1, cloud_pixel2, cloud_pixel3;
    wire cloud_pixel_valid1, cloud_pixel_valid2, cloud_pixel_valid3;
    wire [11:0] cloudRGB1, cloudRGB2, cloudRGB3;
    reg [10:0] cloud_xpos1, cloud_xpos2, cloud_xpos3;
    reg [10:0] cloud_ypos1, cloud_ypos2, cloud_ypos3;
    wire [9:0] cloud_h_start1, cloud_h_start2, cloud_h_start3;
    reg cloud_en1, cloud_en2, cloud_en3;
    reg [16:0] keep_cloud_distance;

    assign {vgaRed, vgaGreen, vgaBlue} = backgroundRGB & gameRGB & cloudRGB1 & cloudRGB2 & cloudRGB3;
    assign backgroundRGB = valid ? pixel_next : 12'hFFF;  
    assign valid = `BACKGROUND_YPOS - `BACKGROUND_HEIGHT < v_cnt && v_cnt < `BACKGROUND_YPOS ? 1 : 0;
    assign game_over_valid = (`PIC_GAME_OVER_YPOS - `PIC_GAME_OVER_HEIGHT < v_cnt && v_cnt < `PIC_GAME_OVER_YPOS) && (`PIC_GAME_OVER_XPOS - `PIC_GAME_OVER_WIDTH < h_cnt && h_cnt < `PIC_GAME_OVER_XPOS);
    assign gameRGB = game_state == `GAME_END ? (game_over_valid ? game_over_pixel : 12'hFFF) : 12'hFFF;

    assign cloud_pixel_valid1 = cloud_en1 && (cloud_ypos1 - `CLOUD_HEIGHT < v_cnt && v_cnt < cloud_ypos1) && (cloud_h_start1 < h_cnt && h_cnt < cloud_xpos1);
    assign cloud_pixel_valid2 = cloud_en2 && (cloud_ypos2 - `CLOUD_HEIGHT < v_cnt && v_cnt < cloud_ypos2) && (cloud_h_start2 < h_cnt && h_cnt < cloud_xpos2);
    assign cloud_pixel_valid3 = cloud_en3 && (cloud_ypos3 - `CLOUD_HEIGHT < v_cnt && v_cnt < cloud_ypos3) && (cloud_h_start3 < h_cnt && h_cnt < cloud_xpos3);
    assign cloud_h_start1 = cloud_xpos1 > `CLOUD_WIDTH ? cloud_xpos1 - `CLOUD_WIDTH + 1 : 0;
    assign cloud_h_start2 = cloud_xpos2 > `CLOUD_WIDTH ? cloud_xpos2 - `CLOUD_WIDTH + 1 : 0;
    assign cloud_h_start3 = cloud_xpos3 > `CLOUD_WIDTH ? cloud_xpos3 - `CLOUD_WIDTH + 1 : 0;
    assign cloudRGB1 = cloud_pixel_valid1 ? cloud_pixel1 : 12'hFFF;
    assign cloudRGB2 = cloud_pixel_valid2 ? cloud_pixel2 : 12'hFFF;
    assign cloudRGB3 = cloud_pixel_valid3 ? cloud_pixel3 : 12'hFFF;
    
    ClockDivider #(2) clk2(clk, clk_div2);
    ClockDivider #(21) clk21(clk, clk_div21);

    Ramdon rs(clk, ramdon_result);
    
    always @ (posedge game_clk or posedge rst) begin
        if (rst == 1) begin
            xpos = 1187;
        end else begin
            if (game_state == `GAME_START) begin
                if (xpos == 0) begin
                    xpos = 1187;
                end else begin
                    xpos = xpos - 1;
                end
            end else begin
                xpos = xpos;
            end
            
        end
    end
    always @ (posedge clk_div21 or posedge rst) begin
        if (rst == 1) begin
            cloud_en1 = 0;
            cloud_en2 = 0;
            cloud_en3 = 0;
            keep_cloud_distance = 0;
            cloud_xpos1 = 0;
            cloud_xpos2 = 0;
            cloud_xpos3 = 0;
            cloud_ypos1 = 0;
            cloud_ypos2 = 0;
            cloud_ypos3 = 0;
        end else begin
            if (keep_cloud_distance <= 200) begin
                keep_cloud_distance = keep_cloud_distance + 1;
            end else begin
                if (cloud_en1 & cloud_en2 & cloud_en3 == 1) begin
                    keep_cloud_distance = 50;
                end else begin
                    keep_cloud_distance = 0;
                    if (ramdon_result < 10) begin
                        keep_cloud_distance = 80;
                    end else if (cloud_en1 == 0) begin
                        cloud_en1 = 1;
                        cloud_xpos1 = `WINDOW_WIDTH + `CLOUD_WIDTH;
                        cloud_ypos1 = `CLOUD_BASE - ramdon_result;
                    end else if (cloud_en2 == 0) begin
                        cloud_en2 = 1;
                        cloud_xpos2 = `WINDOW_WIDTH + `CLOUD_WIDTH;
                        cloud_ypos2 = `CLOUD_BASE - ramdon_result;
                    end else begin
                        cloud_en3 = 1;
                        cloud_xpos3 = `WINDOW_WIDTH + `CLOUD_WIDTH;
                        cloud_ypos3 = `CLOUD_BASE - ramdon_result;
                    end
                end
                
            end
            if (cloud_xpos1 == 0) begin
                cloud_en1 = 0;
            end else begin
                cloud_xpos1 = game_state == `GAME_START ? cloud_xpos1 - 1 : cloud_xpos1;
            end
            if (cloud_xpos2 == 0) begin
                cloud_en2 = 0;
            end else begin
                cloud_xpos2 = game_state == `GAME_START ? cloud_xpos2 - 1 : cloud_xpos2;
            end
            if (cloud_xpos3 == 0) begin
                cloud_en3 = 0;
            end else begin
                cloud_xpos3 = game_state == `GAME_START ? cloud_xpos3 - 1 : cloud_xpos3;
            end
        end
    end 
    
    mem_addr_gen #(`BACKGROUND_WIDTH, `BACKGROUND_HEIGHT) mem_background(
        .clk(clk_div2),
        .rst(rst),
        .pos_x(xpos),
        .pos_y(`BACKGROUND_YPOS),
        .h_cnt(h_cnt),
        .v_cnt(v_cnt),
        .pixel_addr(pixel_addr)
    );
    mem_addr_gen #(`PIC_GAME_OVER_WIDTH, `PIC_GAME_OVER_HEIGHT) mem_gameover(
        .clk(clk_div2),
        .rst(rst),
        .pos_x(`PIC_GAME_OVER_XPOS),
        .pos_y(`PIC_GAME_OVER_YPOS),
        .h_cnt(h_cnt),
        .v_cnt(v_cnt),
        .pixel_addr(game_over_pixel_addr)
    );
    mem_addr_gen #(`CLOUD_WIDTH, `CLOUD_HEIGHT) mem_cloud1(
        .clk(clk_div2),
        .rst(rst),
        .pos_x(cloud_xpos1),
        .pos_y(cloud_ypos1),
        .h_cnt(h_cnt),
        .v_cnt(v_cnt),
        .pixel_addr(cloud_pixel_addr1)
    );
    mem_addr_gen #(`CLOUD_WIDTH, `CLOUD_HEIGHT) mem_cloud2(
        .clk(clk_div2),
        .rst(rst),
        .pos_x(cloud_xpos2),
        .pos_y(cloud_ypos2),
        .h_cnt(h_cnt),
        .v_cnt(v_cnt),
        .pixel_addr(cloud_pixel_addr2)
    );
    mem_addr_gen #(`CLOUD_WIDTH, `CLOUD_HEIGHT) mem_cloud3(
        .clk(clk_div2),
        .rst(rst),
        .pos_x(cloud_xpos3),
        .pos_y(cloud_ypos3),
        .h_cnt(h_cnt),
        .v_cnt(v_cnt),
        .pixel_addr(cloud_pixel_addr3)
    );

    blk_mem_gen_0 background(
        .clka(clk_div2),
        .wea(0),
        .addra(pixel_addr),
        .dina(0),
        .douta(pixel_next)
    );
    gameover go(
        .clka(clk_div2),
        .wea(0),
        .addra(game_over_pixel_addr),
        .dina(0),
        .douta(game_over_pixel)
    );
    cloud cl1(
        .clka(clk_div2),
        .wea(0),
        .addra(cloud_pixel_addr1),
        .dina(0),
        .douta(cloud_pixel1)
    );
    cloud cl2(
        .clka(clk_div2),
        .wea(0),
        .addra(cloud_pixel_addr2),
        .dina(0),
        .douta(cloud_pixel2)
    );
    cloud cl3(
        .clka(clk_div2),
        .wea(0),
        .addra(cloud_pixel_addr3),
        .dina(0),
        .douta(cloud_pixel3)
    );
endmodule