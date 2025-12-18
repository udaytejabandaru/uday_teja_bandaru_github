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

    integer label, img, fd_img, fd_mem;
    integer status, addr, total_tests, pass_count, fail_count;
    reg [7:0] byte_val;
    string img_path;
    string mem_path;

    // Clock Generation
    always #5 clk = ~clk;

    initial begin
        clk = 0;
        rst_n = 0;
        start = 0;
        wr_en = 0;
        wr_addr = 0;
        wr_data = 0;
        total_tests = 0;
        pass_count = 0;
        fail_count = 0;

        #20 rst_n = 1;

        mem_path = "combined_mem.hex";

        for (label = 0; label < 10; label = label + 1) begin
            for (img = 0; img < 800; img = img + 1) begin

                img_path = $sformatf("rdm_img_hex/label_%0d/image_%0d.hex", label, img);
		$display(img_path);
		fd_img = $fopen(img_path, "r");

                if (fd_img == 0) begin
                    $display("Skipping missing file: %s", img_path);
                end else begin
                    total_tests = total_tests + 1;

        // Load 784 bytes of image
        wr_en = 1;
	for (addr = 0; addr < 784; addr = addr + 1) begin
            status = $fscanf(fd_img, "%h\n", byte_val);
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

                    $display("Expected Class: %0d, DUT Output: %0d", label, final_class);

                    if (final_class == label) begin
                        pass_count = pass_count + 1;
                        $display("PASS\n");
                    end else begin
                        fail_count = fail_count + 1;
                        $display("FAIL\n");
                    end
                end
            end
        end

        $display("==== TEST SUMMARY ====");
        $display("Total Tests : %0d", total_tests);
        $display("Pass Count  : %0d", pass_count);
        $display("Fail Count  : %0d", fail_count);
        $finish;
    end

endmodule

