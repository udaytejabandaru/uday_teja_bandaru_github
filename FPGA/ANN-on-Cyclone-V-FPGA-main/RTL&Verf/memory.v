module unified_mem #(parameter ADDR_WIDTH = 14)(
    input clk,
    input wr_en,
    input [ADDR_WIDTH-1:0] wr_addr,
    input [ADDR_WIDTH-1:0] rd_addr_l1,
    input [ADDR_WIDTH-1:0] rd_addr_l2,
    input [7:0] data_in,
    output reg [7:0] data_out_l1,
    output reg [7:0] data_out_l2
);
    reg [7:0] memory [0:(1<<ADDR_WIDTH)-1];

    // Write logic
    always @(posedge clk) begin
        if (wr_en && (^data_in !== 1'bx))
       	    //$display("addr %0d byte value %0x", wr_addr, data_in);
            memory[wr_addr] <= data_in;
    end

    // Read logic (dual-port)
    always @(posedge clk) begin
        data_out_l1 <= memory[rd_addr_l1];
        data_out_l2 <= memory[rd_addr_l2];
    end
endmodule

