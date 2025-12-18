module top_module (
    input clk,
    input rst_n,
    input start,
    input wr_en,
    input [13:0] wr_addr,
    input [7:0] wr_data,
    output [3:0] final_class,
    output done
);

    wire [13:0] mem_addr_l1;
    wire [13:0] mem_addr_l2;
    wire [7:0] data_out_l1;
    wire [7:0] data_out_l2;
    wire signed [25:0] layer1_outputs [0:15];
    wire layer_one_done;


    unified_mem #(14) mem_inst (
        .clk(clk),
        .wr_en(wr_en),
        .wr_addr(wr_addr),
        .rd_addr_l1(mem_addr_l1),
        .rd_addr_l2(mem_addr_l2),
        .data_in(wr_data),
        .data_out_l1(data_out_l1),
        .data_out_l2(data_out_l2)
    );

    // Layer One FSM instance
    neuron_layer_one_fsm #(784, 16, 14) layer1_inst (
        .clk(clk),
        .rst_n(rst_n),
        .start(start),
        .data_from_mem(data_out_l1),
        .mem_addr(mem_addr_l1),
        .outputs(layer1_outputs),
        .done(layer_one_done)
    );

    // Layer Two FSM instance
    neuron_layer_two_fsm #(16, 10, 14) layer2_inst (
        .clk(clk),
        .rst_n(rst_n),
        .start(layer_one_done),
        .data_from_mem(data_out_l2),
        .mem_addr(mem_addr_l2),
        .layer1_outputs(layer1_outputs),
        .final_class(final_class),
        .done(done)
    );

endmodule
