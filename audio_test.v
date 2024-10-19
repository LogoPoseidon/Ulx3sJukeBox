`include "SDKartenLeser.v"
`include "sd_controller.v"
`include "queue.v"
`include "dacpwm.v"
module topmodule (
    input clk_25mhz,          // 25 MHz clock input
    input [6:0] btn,
    output [7:0] led,

    // SD card interface
    output sd_cmd,            // MOSI (CMD pin of SD card)
    output sd_clk,            // Clock (SCK pin of SD card)
    output [3:0] audio_l,
    output [3:0] audio_r,
    inout [3:0] sd_d          // MISO (D0-D3 pins of SD card)
);
// SD card interface signals
wire SDmosi;                    // MOSI line
wire SDmiso;                    // MISO line
wire SDcs;                      // Chip Select line

// Connect SD data lines
assign sd_d[0] = SDmiso;          
assign sd_d[1] = 1'b1;         // Unused data lines pulled high
assign sd_d[2] = 1'b1;
assign sd_d[3] = SDcs;
assign sd_cmd = SDmosi;
// SD card control signals
wire [7:0] Daten;                // Data output from the SD controller
reg Lesen;                     // Signal to trigger SD card read
                               // Every 32kHz trigger a new read
SDKarte SDKarte (
    .Clock(clk_25mhz),
    .Reset(globalReset),
    .Lesen(Lesen),
    .Daten(Daten),
    .miso(SDmiso),
    .mosi(SDmosi),
    .sclk(sd_clk),
    .cs(SDcs),
    .btn(btn),
    .song(led)
);


reg globalReset;                // Global reset signal
reg state;                // Current state
localparam RESETSTATE = 0;        // Reset state
localparam RUNNINGSTATE = 1;      // Running state


always @(posedge clk_25mhz) begin
    if(state == RESETSTATE) begin
        globalReset <= 1;
        state <= RUNNINGSTATE;
    end else begin
        globalReset <= 0;
        if(!btn[0]) begin
            state <= RESETSTATE;
        end
    end
end


// Buffer for current audio sample (8-bit PCM)
reg [7:0] pcm;
wire [3:0] dac;  // Output from the DAC

// Instantiate the PWM DAC
dacpwm #(.C_pcm_bits(8))
dacpwm_instance (
    .clk(clk_25mhz),
    .pcm(pcm),
    .dac(dac)
);

// Assign DAC output to both left and right audio channels
assign audio_l = {0,dac[3:2],dac[1]||dac[0]};
assign audio_r = {0,dac[3:2],dac[1]||dac[0]};
reg[31:0] clkdiv = 0;
reg start = 0;
reg[31:0] count = 0;
always @(posedge clk_25mhz) begin
    if(start) begin
        Lesen <= 0;
        clkdiv <= clkdiv + 1;
        if(clkdiv == 25000000/32000) begin
            clkdiv <= 0;
            pcm <= Daten;
            Lesen <= 1;
        end
    end
    if(state == RUNNINGSTATE) begin
        count <= count + 1;
    end
    if(count > 1024) begin
        start <= 1;
    end
    if(!btn[0]) begin
        start <= 0;
        count <= 0;
    end
end

endmodule


