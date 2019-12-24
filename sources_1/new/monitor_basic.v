module vga_controller (
    input wire pclk, reset,
    output wire hsync, vsync, valid,
    output wire [9:0] h_cnt,
    output wire [9:0] v_cnt
);
    reg [9:0] pixel_cnt;
    reg [9:0] line_cnt;
    reg hsync_i, vsync_i;

    parameter HD = 640;
    parameter HF = 16;
    parameter HS = 96;
    parameter HB = 48;
    parameter HT = 800;
    parameter VD = 480;
    parameter VF = 10;
    parameter VS = 2;
    parameter VB = 33;
    parameter VT = 525;
    parameter hsync_default = 1'b1;
    parameter vsync_default = 1'b1;

    always @(posedge pclk) begin
        if (reset)
            pixel_cnt <= 0;
        else begin
            if(pixel_cnt < (HT - 1))
                pixel_cnt <= pixel_cnt + 1;
            else
                pixel_cnt <= 0;
        end
    end

    always @(posedge pclk) begin
        if (reset)
            hsync_i <= hsync_default;
        else begin
            if ((pixel_cnt >= (HD + HF - 1)) && (pixel_cnt < (HD + HF + HS - 1)))
                hsync_i <= ~hsync_default;
            else
                hsync_i <= hsync_default;
        end
    end 

    always @(posedge pclk) begin
        if (reset)
            line_cnt <= 0;
        else begin
            if (pixel_cnt == (HT - 1)) begin
                if (line_cnt < (VT - 1))
                    line_cnt <= line_cnt + 1;
                else
                    line_cnt <= 0;
            end
        end
    end

    always @(posedge pclk) begin
        if (reset)
            vsync_i <= vsync_default;
        else begin 
            if ((line_cnt >= (VD + VF - 1)) && (line_cnt < (VD + VF + VS - 1)))
                vsync_i <= ~vsync_default;
            else
                vsync_i <= vsync_default;
        end
    end
    assign hsync = hsync_i;
    assign vsync = vsync_i;
    assign valid = ((pixel_cnt < HD) && (line_cnt < VD));
    assign h_cnt = (pixel_cnt < HD) ? pixel_cnt : 10'd0;
    assign v_cnt = (line_cnt < VD) ? line_cnt : 10'd0;
endmodule
