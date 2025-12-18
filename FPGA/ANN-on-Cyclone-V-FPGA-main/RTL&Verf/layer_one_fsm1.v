module neuron_layer_one_fsm #(
    parameter N = 784,
    parameter M = 16,
    parameter ADDR_WIDTH = 14
)(
    input clk,
    input rst_n,
    input start,
    input [7:0] data_from_mem,
    output reg [ADDR_WIDTH-1:0] mem_addr,
    output reg signed [25:0] outputs [0:M-1],
    output reg done
);

    localparam IDLE                 = 4'd0,
               LOAD_BIAS_ADDR       = 4'd1,
               LOAD_BIAS_BFFR       = 4'd10,
               LOAD_BIAS_WAIT       = 4'd2,
               READ_INPUT_ADDR      = 4'd3,
               READ_INPUT_BFFR      = 4'd11,
               READ_INPUT_WAIT      = 4'd4,
               MAC_READ_WEIGHT_ADDR = 4'd5,
               MAC_READ_WEIGHT_BFFR = 4'd12,
               MAC_READ_WEIGHT_WAIT = 4'd6,
               MAC_SAFETY_BFFR	    = 4'd13,
               MAC_PREPARE_MULT     = 4'd7,
               MAC_PREPARE_BFFR     = 4'd14,
               MAC_UPDATE           = 4'd8,
               DONE                 = 4'd9;

    reg [3:0] state;

    reg [9:0] i;
    reg [3:0] n;
    reg [3:0] bias_count;
    reg [7:0] input_byte;
    reg signed [7:0] weight_byte;
    reg signed [25:0] accum [0:M-1];
    reg signed [16:0] mult_result;

    localparam INPUT_BASE   = 14'd0;
    localparam BIAS1_BASE   = 14'd784;
    localparam WEIGHT1_BASE = 14'd800;

    integer k;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= IDLE;
            i <= 0;
            n <= 0;
            bias_count <= 0;
            done <= 0;
            mem_addr <= 0;
            input_byte <= 0;
            weight_byte <= 0;
            mult_result <= 0;
            for (k = 0; k < M; k = k + 1) begin
                accum[k] <= 0;
                outputs[k] <= 0;
            end
        end else begin
            case (state)
                IDLE: begin
                    if (start) begin
                        i <= 0;
                        n <= 0;
                        bias_count <= 0;
                        done <= 0;
                        mem_addr <= BIAS1_BASE;
                        state <= LOAD_BIAS_ADDR;
                    end else begin
                        done <= 0;
                    end
                end

                LOAD_BIAS_ADDR: begin
                    mem_addr <= BIAS1_BASE + bias_count;
                    state <= LOAD_BIAS_BFFR;
                end

                LOAD_BIAS_BFFR: begin
                    state <= LOAD_BIAS_WAIT;
                end

                LOAD_BIAS_WAIT: begin
                    accum[bias_count] <= {{18{data_from_mem[7]}}, data_from_mem} <<< 8; // Q4.4 → Q12.12
                    if (bias_count == M - 1) begin
                        i <= 0;
                        state <= READ_INPUT_ADDR;
                    end else begin
                        bias_count <= bias_count + 1;
                        state <= LOAD_BIAS_ADDR;
                    end
                end

                READ_INPUT_ADDR: begin
                    mem_addr <= INPUT_BASE + i;
                    state <= READ_INPUT_BFFR;
                end

                READ_INPUT_BFFR: begin
                    state <= READ_INPUT_WAIT;
                end

                READ_INPUT_WAIT: begin
                    input_byte <= data_from_mem; // Q1.7 unsigned
                    n <= 0;
                    state <= MAC_READ_WEIGHT_ADDR;
                end

                MAC_READ_WEIGHT_ADDR: begin
                    mem_addr <= WEIGHT1_BASE + (n * N) + i;
                    state <= MAC_READ_WEIGHT_BFFR;
                end

                MAC_READ_WEIGHT_BFFR: begin
                    state <= MAC_READ_WEIGHT_WAIT;
                end

                MAC_READ_WEIGHT_WAIT: begin
                    weight_byte <= $signed(data_from_mem); // Q3.5
                    state <= MAC_SAFETY_BFFR;
                end
                MAC_SAFETY_BFFR: begin
                    state <= MAC_PREPARE_MULT;
                end

                MAC_PREPARE_MULT: begin
                    mult_result <= $signed({1'b0, input_byte}) * weight_byte; // Q1.7 * Q3.5 = Q4.12
                    state <= MAC_PREPARE_BFFR;
                end

                MAC_PREPARE_BFFR: begin
                    state <= MAC_UPDATE;
                end

                MAC_UPDATE: begin
                    accum[n] <= accum[n] + {{9{mult_result[16]}}, mult_result}; // Extend to 26-bit

                    if (n == M - 1) begin
                        n <= 0;
                        if (i == N - 1)
                            state <= DONE;
                        else begin
                            i <= i + 1;
                            state <= READ_INPUT_ADDR;
                        end
                    end else begin
                        n <= n + 1;
                        state <= MAC_READ_WEIGHT_ADDR;
                    end
                end

                DONE: begin
                    for (k = 0; k < M; k = k + 1) begin
                        outputs[k] <= (accum[k][25]) ? 26'd0 : accum[k]; // ReLU
                    end
                    done <= 1;
                    state <= IDLE;
                end

                default: begin
                    state <= IDLE;
                    done <= 0;
                end
            endcase
        end
    end

endmodule


