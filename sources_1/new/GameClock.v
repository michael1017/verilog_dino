module GameClock(
    input wire clk,
    input wire rst,
    output reg clk_div
    );

    reg [27:0] counter;
    reg [27:0] divider;
    reg [14:0] full;
    
    always @ (posedge clk, posedge rst) begin
        if (rst == 1'b1) begin
            counter <= 0;
            divider <= 200000;
            full <= 0;
            clk_div <= 1;
        end else begin
            if(counter < divider) begin
                counter <= counter + 1;
            end else begin
                if (full == 9999) begin
                    full <= 0;
                    if (divider != 100000) begin
                        divider <= divider - 20000;
                    end else begin
                        divider <= divider;
                    end
                end else begin
                    full <= full + 1;
                end
                clk_div <= ~clk_div;
                counter <= 0;
            end
        end
    end
endmodule