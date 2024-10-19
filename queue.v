module queue #(
    parameter DATA_WIDTH = 32,
    parameter MAX_QUEUE_SIZE = 16
)(
    input clk,
    input rst,
    input enqueue,
    input dequeue,
    input [DATA_WIDTH-1:0] data_in,
    output reg [DATA_WIDTH-1:0] data_out,
    output empty,
    output full,
    output[$clog2(MAX_QUEUE_SIZE)-1:0] size
);
    assign size = queue_size;
    // Queue structure
    reg [DATA_WIDTH-1:0] queue_data [MAX_QUEUE_SIZE-1:0];
    reg [$clog2(MAX_QUEUE_SIZE)-1:0] queue_size = 0;
    //Pointer to first element of the queue
    reg [$clog2(MAX_QUEUE_SIZE)-1:0] beginning = 0;
    //Pointer to last element of the queue
    reg [$clog2(MAX_QUEUE_SIZE)-1:0] ending = 0;

    // Queue empty and full flags
    assign empty = (queue_size == 0);
    assign full = (queue_size == MAX_QUEUE_SIZE);

    always @(posedge clk) begin
        
        if (enqueue && !full) begin
            queue_data[beginning] <= data_in;
            queue_size <= queue_size + 1;
            beginning <= (beginning + 1);
        end

        if (dequeue && !empty) begin
            queue_size <= queue_size - 1;
            ending <= (ending + 1);
            data_out <= queue_data[ending];
        end

        if(rst) begin
            queue_size <= 0;
            beginning <= 0;
            ending <= 0;
        end
    end
endmodule
