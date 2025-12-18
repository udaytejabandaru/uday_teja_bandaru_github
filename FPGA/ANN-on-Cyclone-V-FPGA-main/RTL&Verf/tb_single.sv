`timescale 1ns/1ps

module tb;

    reg clk, rst_n, start, wr_en;
    reg [13:0] wr_addr;
    reg [7:0] wr_data;
    wire [3:0] final_class;
    wire done;

    top_module uut (
        .clk(clk),
        .rst_n(rst_n),
        .start(start),
        .wr_en(wr_en),
        .wr_addr(wr_addr),
        .wr_data(wr_data),
        .final_class(final_class),
        .done(done)
    );

    integer fd_img, fd_mem;
    integer status, addr, sscanf_result;
    integer label_val;
    reg [7:0] byte_val;
    reg [1023:0] img_path;
    reg [1023:0] mem_path;

    // Clock Generation
    always #5 clk = ~clk;

    initial begin
        clk = 0;
        rst_n = 0;
        start = 0;
        wr_en = 0;
        wr_addr = 0;
        wr_data = 0;
	label_val = 0;

        #20 rst_n = 1;

        mem_path = "combined_mem.hex";
        img_path = "rdm_img_hex/label_6/image_150.hex";

        sscanf_result = $sscanf(img_path, "rdm_img_hex/label_%d/", label_val);
        if (sscanf_result == 1)
            $display("Extracted label = %0d", label_val);
        else
            $display("Failed to extract label");
        $display("[INFO] Loading Image: %s", img_path);

        fd_img = $fopen(img_path, "r");
        if (fd_img == 0) begin
            $display("ERROR: Cannot open %s", img_path);
            $finish;
        end

        wr_en = 1;
	for (addr = 0; addr < 784; addr = addr + 1) begin
            status = $fscanf(fd_img, "%h\n", byte_val);
            //$display("addr=%0d data=%0h status=%0d", addr, byte_val, status);
            if (status != 1) begin
                $display("Error reading image file at addr %0d", addr);
                $finish;
            end
            @(posedge clk);
            wr_addr = addr;
            wr_data = byte_val;
            #1;
            @(posedge clk);
        end

        $fclose(fd_img);

        $display("[INFO] Image loaded successfully.");

        // Load combined memory after 784
        fd_mem = $fopen(mem_path, "r");
        if (fd_mem == 0) begin
            $display("ERROR: Cannot open %s", mem_path);
            $finish;
        end

        addr = 784;
	while (!$feof(fd_mem)) begin
            status = $fscanf(fd_mem, "%h\n", byte_val);
            if (status == 1) begin
                @(posedge clk);
                wr_addr = addr;
                wr_data = byte_val;
                #1
                @(posedge clk);
                addr = addr + 1;
            end
        end

        @(posedge clk);
        wr_en = 0;

        $fclose(fd_mem);

        $display("[INFO] Loaded %0d bytes into memory.", addr);

        // Start DUT
        @(posedge clk);
        start = 1;
        @(posedge clk);
        start = 0;

        // Wait for done
        wait (done);
	@(posedge clk);

        $display("Expected Label: %0d", label_val);
        $display("Predicted Label from DUT: %0d", final_class);

        if (final_class == label_val)
            $display("PASS: Prediction is correct.");
        else
            $display("FAIL: Prediction mismatch.");

        #300;

        $finish;
    end

        initial begin
          $dumpfile("wave.vcd");       // Name of VCD file to generate
          $dumpvars(0, tb);            // tb is your testbench module name
        end

endmodule

