module neuron_layer_two_fsm #(
    parameter M1 = 16,           // Number of outputs from layer 1
    parameter M2 = 10,           // Number of neurons in layer 2
    parameter ADDR_WIDTH = 14
)(
    input clk,
    input rst_n,
    input start,
    input [7:0] data_from_mem,
    output reg [ADDR_WIDTH-1:0] mem_addr,
    input signed [25:0] layer1_outputs [0:M1-1],
    output reg [3:0] final_class,
    output reg done
);

    localparam IDLE                 = 4'd0,
               COPY_L1              = 4'd1,
               LOAD_BIAS_ADDR       = 4'd2,
               LOAD_BIAS_BFFR       = 4'd10,
               LOAD_BIAS_WAIT       = 4'd3,
               MAC_START            = 4'd4,
               MAC_START_BFFR            = 4'd11,
               MAC_READ_WEIGHT_ADDR = 4'd5,
               MAC_READ_WEIGHT_BFFR = 4'd15,
               MAC_READ_WEIGHT_WAIT = 4'd6,
               MAC_PARTIAL_SUM_BFFR = 4'd12,
               MAC_UPDATE           = 4'd7,
               DONE_START           = 4'd8,
               DONE_START_BFFR           = 4'd13,
               DONE_COMPARE_BFFR           = 4'd14,
               DONE_COMPARE         = 4'd9;

    reg [3:0] state;

    reg [3:0] j; // layer 1 output index
    reg [3:0] n; // layer 2 neuron index
    reg [3:0] bias_count;
    reg signed [7:0] weight_byte;
    reg signed [40:0] partial_sum;
    reg signed [40:0] accum [0:M2-1];

    reg signed [25:0] l1_cache [0:M1-1];
    reg [3:0] copy_idx;

    reg signed [40:0] max_val;
    reg [3:0] compare_idx;
    reg [3:0] max_idx;

    localparam BIAS2_BASE   = 14'd13344;
    localparam WEIGHT2_BASE = 14'd13354;

    integer k;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= IDLE;
            j <= 0;
            n <= 0;
            bias_count <= 0;
            done <= 0;
            mem_addr <= 0;
            weight_byte <= 0;
            partial_sum <= 0;
            final_class <= 0;
            max_val <= 0;
            compare_idx <= 0;
            max_idx <= 0;
            copy_idx <= 0;
            for (k = 0; k < M2; k = k + 1) begin
                accum[k] <= 0;
            end
        end else begin
            case (state)
                IDLE: begin
                    if (start) begin
                        j <= 0;
                        n <= 0;
                        bias_count <= 0;
                        done <= 0;
                        final_class <= 0;
                        max_val <= 0;
                        compare_idx <= 0;
                        max_idx <= 0;
                        copy_idx <= 0;
                        mem_addr <= BIAS2_BASE;
                        state <= COPY_L1;
                    end
                end

                COPY_L1: begin
                    l1_cache[copy_idx] <= layer1_outputs[copy_idx];
                    if (copy_idx == M1 - 1)
                        state <= LOAD_BIAS_ADDR;
                    else
                        copy_idx <= copy_idx + 1;
                end

                LOAD_BIAS_ADDR: begin
                    mem_addr <= BIAS2_BASE + bias_count;
                    state <= LOAD_BIAS_BFFR;
                end

                LOAD_BIAS_BFFR: begin
                    state <= LOAD_BIAS_WAIT;
                end

                LOAD_BIAS_WAIT: begin
                    accum[bias_count] <= $signed(data_from_mem) <<< 20; // Q4.4 → Q17.24
                    if (bias_count == M2 - 1) begin
                        j <= 0;
                        state <= MAC_START;
                    end else begin
                        bias_count <= bias_count + 1;
                        state <= LOAD_BIAS_ADDR;
                    end
                end

                MAC_START: begin
                    mem_addr <= WEIGHT2_BASE + (n * M1) + j;
                    state <= MAC_START_BFFR;
                end

                MAC_START_BFFR: begin
                    state <= MAC_READ_WEIGHT_ADDR;
                end

                MAC_READ_WEIGHT_ADDR: begin
                    weight_byte <= $signed(data_from_mem); // Q3.5
                    state <= MAC_READ_WEIGHT_BFFR;
                end

                MAC_READ_WEIGHT_BFFR: begin
                    state <= MAC_READ_WEIGHT_WAIT;
                end

                MAC_READ_WEIGHT_WAIT: begin
                    // Q14.12 × Q3.12 = Q17.24
		    partial_sum = ($signed(l1_cache[j]) * ($signed(weight_byte) <<< 7));
                    state <= MAC_PARTIAL_SUM_BFFR;
                end

                MAC_PARTIAL_SUM_BFFR: begin
                    state <= MAC_UPDATE;
                end

                MAC_UPDATE: begin
                    accum[n] <= accum[n] + partial_sum;
                    if (n == M2 - 1) begin
                        n <= 0;
                        if (j == M1 - 1)
                            state <= DONE_START_BFFR;
                        else begin
                            j <= j + 1;
                            state <= MAC_START;
                        end
                    end else begin
                        n <= n + 1;
                        state <= MAC_START;
                    end
                end

                DONE_START_BFFR: begin
                    state <= DONE_START;
                end

                DONE_START: begin
                    compare_idx <= 1;
                    max_val <= (accum[0][40] == 1'b1) ? 41'd0 : accum[0];
                    max_idx <= 0;
                    state <= DONE_COMPARE_BFFR;
                end

                DONE_COMPARE_BFFR: begin
                    state <= DONE_COMPARE;
                end


                DONE_COMPARE: begin
                    if (compare_idx < M2) begin
                        if ((accum[compare_idx][40] == 1'b0) && (accum[compare_idx] > max_val)) begin
                            max_val <= accum[compare_idx];
                            max_idx <= compare_idx;
                        end
                        compare_idx <= compare_idx + 1;
                    end else begin
                        final_class <= max_idx;
                        done <= 1;
                        state <= IDLE;
                    end
                end

                default: state <= IDLE;
            endcase
        end
    end
endmodule

