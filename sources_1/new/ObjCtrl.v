`define ENTER 0
`define SPACE 1
`define UP    2
`define DOWN  3

`define UP_STATUS 0
`define FALL_STATUS 1
`define STATIC_STATUS 2

`define GRAVITY 1
`define INITIAL_SPEED 9
`define QUICK_DOWN 3

`define LOW_BIRD     0
`define HIGH_BIRD    1
`define SMALL_CACTUS 2
`define MANY_CACTUS  3
`define BIG_CACTUS   4
`define NOTHING      5
module ObjCtrl(
    input wire clk, 
    input wire rst, 
    input wire game_clk,
    output reg [8:0] dino_pos, 
    output reg [8:0] danger_pos1, 
    output reg [8:0] danger_pos2,
    output reg [8:0] danger_pos3,
    output reg [2:0] danger_type1,
    output reg [2:0] danger_type2,
    output reg [2:0] danger_type3,
    output reg danger_en1,
    output reg danger_en2,
    output reg danger_en3,
    inout wire PS2_DATA,
    inout wire PS2_CLK
    );
    wire clk_div15, clk_div29, clk_div19, clk_div21;
    //keyboard kin();
    ClockDivider #(15) clk15(clk, clk_div15);
    ClockDivider #(23) clk29(clk, clk_div29);
    ClockDivider #(21) clk19(clk, clk_div19);
    ClockDivider #(21) clk21(clk, clk_div21);

    wire [3:0] key_num;
    KeyboardValue kbv(
        .key_num(key_num),
        .keyin(keyin),
        .PS2_DATA(PS2_DATA),
        .PS2_CLK(PS2_CLK),
        .rst(rst),
        .clk(clk)
	);

    wire [6:0] ramdon_result;
    Ramdon ramdon(clk, ramdon_result);

    //wire keyin_o;
    //OnePulse okeyboard(keyin_o, keyin, clk_div29);
    reg [6:0] up_speed, down_speed;
    reg [1:0] dino_status;
    reg [2:0] dino_counter;
    reg dino_start_fall;
    reg [5:0] ensure_empty_counter;
    reg [2:0] next_danger_type;


    always @ (posedge game_clk or posedge rst) begin
        if (rst == 1) begin
            ensure_empty_counter = 0;
            danger_pos1 = 0;
            danger_pos2 = 0;
            danger_pos2 = 0;
            danger_type1 = `NOTHING;
            danger_type2 = `NOTHING;
            danger_type3 = `NOTHING;
            next_danger_type = `NOTHING;
            danger_en1 = 0;
            danger_en2 = 0;
            danger_en3 = 0;
        end else begin
            if ((danger_en1 & danger_en2 & danger_en3) == 1) begin
                ensure_empty_counter = 0;
            end else if (ensure_empty_counter != 63) begin
                ensure_empty_counter = ensure_empty_counter + 1;
            end else begin
                //initialize
                if (next_danger_type != `NOTHING) begin
                    ensure_empty_counter = 0;
                    if (danger_en1 == 0) begin
                        danger_pos1 = 319;
                        danger_type1 = next_danger_type;
                        danger_en1 = 1;
                    end else if (danger_en2 == 0) begin
                        danger_pos2 = 319;
                        danger_type2 = next_danger_type;
                        danger_en2 = 1;
                    end else begin
                        danger_pos3 = 319;
                        danger_type3 = next_danger_type;
                        danger_en3 = 1;
                    end

                end else begin
                    //do nothing
                end
                //get obj
                if (ramdon_result <= 50) begin
                    next_danger_type = `NOTHING;
                end else if (ramdon_result <= 60) begin
                    next_danger_type = `BIG_CACTUS;
                end else if (ramdon_result <= 70) begin
                    next_danger_type = `SMALL_CACTUS;
                end else if (ramdon_result <= 80) begin
                    next_danger_type = `MANY_CACTUS;
                end else if (ramdon_result <= 90)begin
                    next_danger_type = `LOW_BIRD;
                end else begin
                    next_danger_type = `HIGH_BIRD;danger_pos1 = 319;
                end
            end
            //recycle and move
            if (danger_pos1 == 0) begin
                danger_en1 = 0;
                danger_type1 = `NOTHING;
            end else begin
                danger_pos1 = danger_pos1 - 1;
            end
            if (danger_pos2 == 0) begin
                danger_en2 = 0;
                danger_type2 = `NOTHING;
            end else begin
                danger_pos2 = danger_pos2 - 1;
            end
            if (danger_pos3 == 0) begin
                danger_en3 = 0;
                danger_type3 = `NOTHING;
            end else begin
                danger_pos3 = danger_pos3 - 1;
            end

        end
    end
    always @ (posedge clk_div19 or posedge rst) begin
        if (rst == 1) begin
            up_speed = 0;
            down_speed = 0;
            dino_pos = `GROUND;
            dino_status = `STATIC_STATUS;
        end else begin 
            if (keyin == 1) begin
                if (key_num == `ENTER) begin
                    
                end else if (key_num == `SPACE || key_num == `UP) begin
                    if (dino_status == `STATIC_STATUS) begin
                        up_speed = `INITIAL_SPEED;
                        down_speed = 0;
                        dino_status = `UP_STATUS;
                    end else if (dino_status == `UP_STATUS) begin
                        if (dino_start_fall == 1) begin
                            dino_status = `FALL_STATUS;
                            dino_pos = dino_pos - up_speed;
                        end else begin
                            dino_pos = dino_pos - up_speed;
                        end
                    end else begin
                        down_speed = down_speed + `GRAVITY;
                        if (down_speed >= up_speed) begin
                            if ((`GROUND - dino_pos) > (down_speed - up_speed)) begin
                                dino_pos = dino_pos + (down_speed - up_speed);
                            end else begin
                                dino_pos =  `GROUND;
                                dino_status = `STATIC_STATUS;
                                down_speed = 0;
                                up_speed = 0;
                            end 
                        end else begin
                            dino_pos = dino_pos - up_speed + down_speed;
                        end
                    end
                end else if (key_num == `DOWN) begin
                    if (dino_pos != `GROUND) begin
                        down_speed = down_speed + `QUICK_DOWN;
                        dino_status = `FALL_STATUS;
                        if (down_speed >= up_speed) begin
                            if ((`GROUND - dino_pos) > (down_speed - up_speed)) begin
                                dino_pos = dino_pos + (down_speed - up_speed);
                            end else begin
                                dino_pos =  `GROUND;
                                dino_status = `STATIC_STATUS;
                                down_speed = 0;
                                up_speed = 0;
                            end 
                        end else begin
                            dino_pos = dino_pos - up_speed + down_speed;
                        end
                    end else begin

                    end
                end
            end else begin
                if (dino_start_fall == 1) begin
                    dino_status = `FALL_STATUS;
                    down_speed = down_speed + `GRAVITY;
                    if (down_speed >= up_speed) begin
                        if ((`GROUND - dino_pos) > (down_speed - up_speed)) begin
                            dino_pos = dino_pos + (down_speed - up_speed);
                        end else begin
                            dino_pos =  `GROUND;
                            dino_status = `STATIC_STATUS;
                            down_speed = 0;
                            up_speed = 0;
                        end 
                    end else begin
                        dino_pos = dino_pos - up_speed + down_speed;
                    end
                end else begin

                end
            end
        end
    end 
    always @ (posedge clk_div19 or posedge rst) begin
        if (rst == 1) begin
            dino_counter = 0;
            dino_start_fall = 0;
        end else begin
            if (keyin == 1 && dino_start_fall == 0) begin
                if (dino_counter == 4) begin
                    dino_counter = 0;
                    dino_start_fall = 1;
                end else begin
                    dino_counter = dino_counter + 1;
                    dino_start_fall = 0;
                end 
            end else if (dino_pos != `GROUND) begin
                dino_start_fall = 1;
                dino_counter = 0;
            end else begin
                dino_counter = 0;
                dino_start_fall = 0;
            end 
        end 
    end
endmodule