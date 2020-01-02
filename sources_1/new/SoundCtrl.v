`define GROUND 298
`define silence   32'd50000000

`define no_sound 0
`define jump_sound 1
`define score_sound 2

`define no_sound 0
`define jump_sound 1
`define score_sound 2
`define SONG_LEN 6
module SoundCtrl(
    clk, // clock from crystal
    rst, // active high reset: BTNC
    _mute, // SW: Mute
    _volUP, // BTN: Vol up
    _volDOWN, // BTN: Vol down
    dino_pos,
    game_score,
    _led_vol, // LED: volume
    audio_mclk, // master clock
    audio_lrck, // left-right clock
    audio_sck, // serial clock
    audio_sdin // serial audio data input
);

    // I/O declaration
    input clk;  // clock from the crystal
    input rst;  // active high reset
    input _mute, _volUP, _volDOWN;
    input [9:0] dino_pos;
    input [13:0] game_score;
    output reg [4:0] _led_vol;
    output audio_mclk; // master clock
    output audio_lrck; // left-right clock
    output audio_sck; // serial clock
    output audio_sdin; // serial audio data input
    
    // Modify these
    //assign _led_vol = 5'b1_1111;
    //assign DIGIT = 4'b0001;
    //assign DISPLAY = 7'b111_1111;

    // Internal Signal
    wire [15:0] audio_in_left, audio_in_right;
    
    wire clkDiv22, clkDiv13;
    wire [11:0] ibeatNum; // Beat counter
    wire [31:0] freqL, freqR; // Raw frequency, produced by music module
    wire [21:0] freq_outL, freq_outR; // Processed Frequency, adapted to the clock rate of Basys3
    reg _music = 0;
    reg [9:0] old_dino_pos;
    reg [1:0] play_state;

    assign freq_outL = 50000000 / ((_mute == 1'b1) || play_state == `no_sound ? `silence : freqL); // Note gen makes no sound, if freq_out = 50000000 / `silence = 1
    assign freq_outR = 50000000 / ((_mute == 1'b1) || play_state == `no_sound ? `silence : freqR);

    ClockDivider #(.n(22)) clock_22(
        .clk(clk),
        .clk_div(clkDiv22)
    );
    ClockDivider #(.n(13)) clock_13(
        .clk(clk),
        .clk_div(clkDiv13)
    );
    reg [2:0] vol;

    wire _volUP_d, _volDOWN_d, volUP, volDOWN;
    Debounce d_volUP(_volUP_d, _volUP, clk);
    Debounce d_volDOWN(_volDOWN_d, _volDOWN, clk);
    OnePulse o_volUP(volUP, _volUP_d, clkDiv22);
    OnePulse o_volDOWN(volDOWN, _volDOWN_d, clkDiv22);

    always @ (posedge clk or posedge rst) begin
        if (rst) begin
            _music = 1;
            old_dino_pos = dino_pos;
            play_state = `no_sound;
        end else if (game_score % 100 == 0 && game_score != 0) begin
            _music = 1;
            old_dino_pos = dino_pos;
            play_state = `score_sound;
        end else if (old_dino_pos == `GROUND && dino_pos != `GROUND && play_state == `no_sound) begin
            _music = 0;
            old_dino_pos = dino_pos;
            play_state = `jump_sound;
        end else if (play_state != `no_sound && ibeatNum == `SONG_LEN - 1) begin
            _music = 0;
            old_dino_pos = dino_pos;
            play_state = `no_sound;
        end else begin
            _music = _music;
            old_dino_pos = dino_pos;
            play_state = play_state;
        end
    end

    always @ (posedge clkDiv22, posedge rst) begin
        if (rst == 1'b1) begin
            _led_vol <= 5'b0_0111;
            vol <= 3;
        end else begin
            if (volUP == 1'b1 && vol != 5) begin
                _led_vol <= {_led_vol[3:0], 1'b1};
                vol <= vol + 1;
            end else if (volDOWN == 1'b1 && vol != 0) begin
                _led_vol <= {1'b0, _led_vol[4:1]};
                vol <= vol - 1;
            end else begin
                _led_vol <= _led_vol;
                vol <= vol;
            end
        end 
    end
    // Player Control
    player_control #(.LEN(`SONG_LEN)) playerCtrl_00 ( 
        .clk(clkDiv22),
        .reset(rst),
        .play_state(play_state),
        ._music(_music),
        .ibeat(ibeatNum)
    );

    // Music module
    // [in]  beat number and en
    // [out] left & right raw frequency
    music_example music_00 (
        .ibeatNum(ibeatNum),
        .en(_music),
        .toneL(freqL),
        .toneR(freqR)
    );

    // Note generation
    // [in]  processed frequency
    // [out] audio wave signal (using square wave here)
    note_gen noteGen_00(
        .clk(clk), // clock from crystal
        .rst(rst), // active high reset
        .note_div_left(freq_outL),
        .note_div_right(freq_outR),
        .audio_left(audio_in_left), // left sound audio
        .audio_right(audio_in_right),
        .volume(vol) // 3 bits for 5 levels
    );

    // Speaker controller
    speaker_control sc(
        .clk(clk),  // clock from the crystal
        .rst(rst),  // active high reset
        .audio_in_left(audio_in_left), // left channel audio data input
        .audio_in_right(audio_in_right), // right channel audio data input
        .audio_mclk(audio_mclk), // master clock
        .audio_lrck(audio_lrck), // left-right clock
        .audio_sck(audio_sck), // serial clock
        .audio_sdin(audio_sdin) // serial audio data input
    );

endmodule