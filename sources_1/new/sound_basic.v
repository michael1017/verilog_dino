`define sil 32'd50000000
`define ha  32'd440
`define hb  32'd494   // B3
`define hc  32'd524   // C4
`define hd  32'd588   // D4
`define he  32'd660   // E4
`define hf  32'd698   // F4
`define hg  32'd784   // G4
`define hha 32'd880
`define a   32'd220
`define b   32'd247
`define c   32'd262   // C3
`define d   32'd293   
`define e   32'd329   
`define f   32'd349   
`define g   32'd392   // G3

`define no_sound 0
`define jump_sound 1
`define score_sound 2
module speaker_control(
    clk,  // clock from the crystal
    rst,  // active high reset
    audio_in_left, // left channel audio data input
    audio_in_right, // right channel audio data input
    audio_mclk, // master clock
    audio_lrck, // left-right clock, Word Select clock, or sample rate clock
    audio_sck, // serial clock
    audio_sdin // serial audio data input
);

    // I/O declaration
    input clk;  // clock from the crystal
    input rst;  // active high reset
    input [15:0] audio_in_left; // left channel audio data input
    input [15:0] audio_in_right; // right channel audio data input
    output audio_mclk; // master clock
    output audio_lrck; // left-right clock
    output audio_sck; // serial clock
    output audio_sdin; // serial audio data input
    reg audio_sdin;

    // Declare internal signal nodes 
    wire [8:0] clk_cnt_next;
    reg [8:0] clk_cnt;
    reg [15:0] audio_left, audio_right;

    // Counter for the clock divider
    assign clk_cnt_next = clk_cnt + 1'b1;

    always @(posedge clk or posedge rst)
        if (rst == 1'b1)
            clk_cnt <= 9'd0;
        else
            clk_cnt <= clk_cnt_next;

    // Assign divided clock output
    assign audio_mclk = clk_cnt[1];
    assign audio_lrck = clk_cnt[8];
    assign audio_sck = 1'b1; // use internal serial clock mode

    // audio input data buffer
    always @(posedge clk_cnt[8] or posedge rst)
        if (rst == 1'b1)
            begin
                audio_left <= 16'd0;
                audio_right <= 16'd0;
            end
        else
            begin
                audio_left <= audio_in_left;
                audio_right <= audio_in_right;
            end

    always @*
        case (clk_cnt[8:4])
            5'b00000: audio_sdin = audio_right[0];
            5'b00001: audio_sdin = audio_left[15];
            5'b00010: audio_sdin = audio_left[14];
            5'b00011: audio_sdin = audio_left[13];
            5'b00100: audio_sdin = audio_left[12];
            5'b00101: audio_sdin = audio_left[11];
            5'b00110: audio_sdin = audio_left[10];
            5'b00111: audio_sdin = audio_left[9];
            5'b01000: audio_sdin = audio_left[8];
            5'b01001: audio_sdin = audio_left[7];
            5'b01010: audio_sdin = audio_left[6];
            5'b01011: audio_sdin = audio_left[5];
            5'b01100: audio_sdin = audio_left[4];
            5'b01101: audio_sdin = audio_left[3];
            5'b01110: audio_sdin = audio_left[2];
            5'b01111: audio_sdin = audio_left[1];
            5'b10000: audio_sdin = audio_left[0];
            5'b10001: audio_sdin = audio_right[15];
            5'b10010: audio_sdin = audio_right[14];
            5'b10011: audio_sdin = audio_right[13];
            5'b10100: audio_sdin = audio_right[12];
            5'b10101: audio_sdin = audio_right[11];
            5'b10110: audio_sdin = audio_right[10];
            5'b10111: audio_sdin = audio_right[9];
            5'b11000: audio_sdin = audio_right[8];
            5'b11001: audio_sdin = audio_right[7];
            5'b11010: audio_sdin = audio_right[6];
            5'b11011: audio_sdin = audio_right[5];
            5'b11100: audio_sdin = audio_right[4];
            5'b11101: audio_sdin = audio_right[3];
            5'b11110: audio_sdin = audio_right[2];
            5'b11111: audio_sdin = audio_right[1];
            default: audio_sdin = 1'b0;
        endcase

endmodule

module player_control (
	input clk,
	input reset,
	input jump,
	input score,
	input _music,
	output reg [11:0] ibeat
);
	parameter LEN = 4095;
    reg [11:0] next_ibeat;
    reg [1:0] play_state = `no_sound;
	always @(posedge clk, posedge reset) begin
		if (reset) begin
			ibeat <= 0;
		end else begin
			ibeat <= next_ibeat;
		end
	end

    always @ (posedge clk) begin
        if (score == 1) begin
            next_ibeat = 0;
            play_state = `score_sound;
        end else if (play_state == `no_sound && jump == 1) begin
            next_ibeat = 0;
            play_state = `jump_sound;
        end else if (play_state == `jump_sound) begin
            if (ibeat + 1 < LEN) begin
                next_ibeat = ibeat + 1;
            end else begin
                next_ibeat = LEN;
                play_state = `no_sound;
            end
        end else if (play_state == `score_sound) begin
            if (ibeat + 1 < LEN) begin
                next_ibeat = ibeat + 1;
            end else begin
                next_ibeat = LEN;
                play_state = `no_sound;
            end
        end else begin
            
        end
    end

endmodule

module music_example (
	input [11:0] ibeatNum,
	input en,
	output reg [31:0] toneL,
    output reg [31:0] toneR
);

    always @* begin
        if(en == 0) begin
            case(ibeatNum)
                // --- Measure 1 ---
                12'd0   : toneR = `hc;   12'd1   : toneR = `hc;
                12'd2   : toneR = `hc;   12'd3   : toneR = `hc;

                default: toneR = `sil;
            endcase
        end else begin
            case(ibeatNum)
                12'd0   : toneR = `hc;   12'd1   : toneR = `hg;
                12'd2   : toneR = `hg;   12'd3   : toneR = `hg;
                default : toneR = `sil;
            endcase
        end
    end

    always @(*) begin
        if(en==0)begin
            case(ibeatNum)
                12'd0   : toneL = `hc;   12'd1   : toneL = `hc;
                12'd2   : toneL = `hc;   12'd3   : toneL = `hc;

                default : toneL = `sil;
            endcase
        end
        else begin
            case(ibeatNum)
                12'd0   : toneL = `hc;   12'd1   : toneL = `hg;
                12'd2   : toneL = `hg;   12'd3   : toneL = `hg;
                
                default : toneL = `sil;
            endcase
        end
    end
endmodule
module note_gen(
    clk, // clock from crystal
    rst, // active high reset
    note_div_left, // div for note generation
    note_div_right,
    audio_left,
    audio_right,
    volume
);

    // I/O declaration
    input clk; // clock from crystal
    input rst; // active low reset
    input [21:0] note_div_left, note_div_right; // div for note generation
    output [15:0] audio_left, audio_right;
    input [2:0] volume;

    // Declare internal signals
    reg [21:0] clk_cnt_next, clk_cnt;
    reg [21:0] clk_cnt_next_2, clk_cnt_2;
    reg b_clk, b_clk_next;
    reg c_clk, c_clk_next;
    reg [15:0] new_vol;

    // Note frequency generation
    always @(posedge clk or posedge rst)
        if (rst == 1'b1)
            begin
                clk_cnt <= 22'd0;
                clk_cnt_2 <= 22'd0;
                b_clk <= 1'b0;
                c_clk <= 1'b0;
            end
        else
            begin
                clk_cnt <= clk_cnt_next;
                clk_cnt_2 <= clk_cnt_next_2;
                b_clk <= b_clk_next;
                c_clk <= c_clk_next;
            end
        
    always @*
        if (clk_cnt == note_div_left)
            begin
                clk_cnt_next = 22'd0;
                b_clk_next = ~b_clk;
            end
        else
            begin
                clk_cnt_next = clk_cnt + 1'b1;
                b_clk_next = b_clk;
            end

    always @*
        if (clk_cnt_2 == note_div_right)
            begin
                clk_cnt_next_2 = 22'd0;
                c_clk_next = ~c_clk;
            end
        else
            begin
                clk_cnt_next_2 = clk_cnt_2 + 1'b1;
                c_clk_next = c_clk;
            end

    // Assign the amplitude of the note
    // Volume is controlled here
    
    always @ * begin
        if (volume == 0) 
            new_vol = 16'h2000;
        else if (volume == 1) 
            new_vol = 16'h20A0;
        else if (volume == 2) 
            new_vol = 16'h2300;
        else if (volume == 3) 
            new_vol = 16'h2A00;
        else if (volume == 4) 
            new_vol = 16'h3000;
        else
            new_vol = 16'h4000;
    end
    
    assign audio_left = (note_div_left == 22'd1) ? 16'h0000 : (b_clk == 1'b0) ? new_vol : 16'h2000;
    assign audio_right = (note_div_right == 22'd1) ? 16'h0000 : (c_clk == 1'b0) ? new_vol : 16'h2000;
endmodule