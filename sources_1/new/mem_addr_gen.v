module mem_addr_gen #(parameter width = 320, parameter height = 240) (
    input clk,
    input rst,
    input [8:0] pos_x,
    input [8:0] pos_y,
    input [9:0] h_cnt,
    input [9:0] v_cnt,
    output [16:0] pixel_addr
    );
    reg  [8:0] pic_x_start, pic_y_start;
    wire [9:0] h_addr, v_addr;
    assign h_addr = h_cnt>>1;
    assign v_addr = v_cnt>>1;
    always @ * begin
        if (pos_x > h_addr) begin
            pic_x_start = width - (pos_x - h_addr);
        end else begin
            pic_x_start = h_addr - pos_x;
        end
        if (pos_y > v_addr) begin
            pic_y_start = height - (pos_y - v_addr);
        end else begin
            pic_y_start = v_addr - pos_y;
        end
    end
    assign pixel_addr = ( pic_x_start%width + width*(pic_y_start%height)) % (width*height);
    //assign pixel_addr = ( (width - distance_with_x) + width*(height - distance_with_y)) % (width*height);
endmodule
