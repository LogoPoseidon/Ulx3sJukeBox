
module SDKarte (
    input Clock,
    input Reset,
    input [6:0] btn,

    input Lesen, //Read operation, one time high
    output [7:0] Daten, //Data stored in the fifo
    output reg [7:0] song, //says what song is currently played
    //SD_controller
    input miso, // Connect to SD_DAT[0].
    output sclk, // Connect to SD_SCK.
    output cs, // Connect to SD_DAT[3].
    output mosi // Connect to SD_CMD.
                // For SPI mode, SD_DAT[2] and SD_DAT[1] should be held HIGH. 
                // SD_RESET should be held LOW.
);
  //Define where your Song starts using calculation:
  // Sector = 32,000/512*(60*SongStartMin+SongStartSec)
  //Example Song 2 starts at Min 1 Sec 0 => (32,000/512)*(1*60+0)
///////////////////////////////////////////////////////////////////////
    reg[31:0] SongStart1 = 0;
    reg[31:0] SongStart2 = 3750;
    reg[31:0] SongStart3 = 56875;
    reg[31:0] SongStart4 = 69687;
    reg[31:0] SongStart5 = 87312;
    reg[31:0] SongStart6 = 101562;
    reg[31:0] SongStart7 = 107937;
    reg[31:0] SongEnde7  = 120001;
///////////////////////////////////////////////////////////////////////

    localparam QueueSize = 2048;
    // states of Controller
    reg state = IDLE;
    localparam IDLE = 0;
    localparam BYTES = 1;

    // SD CARD INPUTS/OUTPUTS
    reg rd = 0; // Read signal for SD card
    wire [7:0] dout; // data output for read operation
    wire byte_available; // byte can be read
    wire ready;
    reg[31:0] address = 0;
    wire [31:0] sektorAdresse = address<<9;
    wire egal;
    wire [4:0] egal2;
    
    reg [8:0] byteZaehler = 0;
    
    wire fifo_full;
    wire fifo_empty;
    wire[31:0] count;

    queue #(
    .DATA_WIDTH(8),
    .MAX_QUEUE_SIZE(QueueSize)
    )queue(
    .clk(Clock),
    .rst(Reset),
    .enqueue(byte_available),
    .dequeue(Lesen),
    .data_in(dout),
    .data_out(Daten),
    .empty(fifo_empty),
    .full(fifo_full),
    .size(count)
);

    // Connections to sdcontroller
    sd_controller sd1 (
        .cs(cs),
        .mosi(mosi),
        .miso(miso),
        .sclk(sclk),
        .rd(rd),
        .dout(dout),
        .byte_available(byte_available),
        .wr(1'b0),
        .din(8'b0),
        .ready_for_next_byte(egal),
        .reset(1'b0),
        .ready(ready),
        .address(sektorAdresse),
        .clk(Clock),
        .status(egal2)
    );


    

    // Zustandsautomat für den SD-Controller
    always @(posedge Clock) begin
        if(state == IDLE) begin
          byteZaehler <= 0;
          if(btn[1]) begin
            address <= SongStart2;
          end
          if(btn[2]) begin
            address <= SongStart3;
          end
          if(btn[3]) begin
            address <= SongStart4;
          end
          if(btn[4]) begin
            address <= SongStart5;
          end
          if(btn[5]) begin
            address <= SongStart6;
          end
          if(btn[6]) begin
            address <= SongStart7;
          end
          if(address > SongEnde7) begin
            address <= SongStart1;
          end
          if(count < QueueSize-512 && ready) begin
            state <= BYTES;
            rd <= 1;
          end
        end else begin
          if(byte_available) begin
            byteZaehler <= byteZaehler + 1;
          end
          if(byteZaehler>=9'b100) begin
            rd <= 0;
            state <= IDLE;
            address <= address + 1;
          end
        end
        if (Reset) begin
          address <= SongStart1;
          state <= IDLE;
          rd <= 0;
          byteZaehler <= 0;
        end 
    end

    always @(posedge Clock) begin
      if(address>=SongStart1 && address < SongStart2) begin
        song <= 8'b00000001;
      end
      if(address>=SongStart2 && address < SongStart3) begin
        song <= 8'b00000010;
      end
      if(address>=SongStart3 && address < SongStart4) begin
        song <= 8'b00000100;
      end
      if(address>=SongStart4 && address < SongStart5) begin
        song <= 8'b00001000;
      end
      if(address>=SongStart5 && address < SongStart6) begin
        song <= 8'b00010000;
      end
      if(address>=SongStart6 && address < SongStart7) begin
        song <= 8'b00100000;
      end
      if(address>=SongStart7 && address < (SongEnde7)) begin
        song <= 8'b01000000;
      end
    end

endmodule

