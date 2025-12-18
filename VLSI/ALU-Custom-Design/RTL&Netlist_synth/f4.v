module Top_alu (
    input [3:0] A,          // First 4-bit input word
    input [1:0] Inst,       // Mode selection inputs
    input RESET,            // Reset input
    input clk,              // Clock input
    output reg [3:0] OUT    // Output word
);
  
wire [3:0] sum;
wire IInst;
add_sub_4_bit add_sub (
  .a(OUT),
  .b(A), // Connect to the reg
    .k(Inst[0]),  // Use the least significant bit of Inst for the subtraction mode
    .sum(sum),
    .cout()
);

  assign IInst = Inst[1] & Inst[0];
  
// Synchronous process triggered by rising edge of clock or RESET
always @(posedge clk) begin
    if (RESET) begin
	OUT <= 4'b0000;
    end else begin
        // ALU operation based on mode selection
      case({Inst[1] & Inst[0], Inst[1]})
            2'b00: OUT <= sum;  // ADD mode, B is OUT from previous operation
            2'b01: begin          // MUL/DIV mode
                case(A[3])
                    1'b0: begin   // Multiplication
                        case(A[2:0])
                            3'b100: OUT <= {A[2] & OUT[0], 3'b000}; 
                            3'b010: OUT <= {A[1] & OUT[1], A[1] & OUT[0], 2'b00};
                            3'b001: OUT <= {A[0] & OUT[2], A[0] & OUT[1], A[0] & OUT[0], 1'b0};
                            default: OUT <= 4'b0000; // No Multiplication
                        endcase
                    end
                    1'b1: begin   // Division
                        case(A[2:0])
                            3'b100: OUT <= {3'b000, A[2] & OUT[3]}; 
                            3'b010: OUT <= {2'b00, A[1] & OUT[3], A[1] & OUT[2]};
                            3'b001: OUT <= {1'b0, A[0] & OUT[3], A[0] & OUT[2], A[0] & OUT[1]};
                            default: OUT <= 4'b0000; // No division
                        endcase
                    end
                endcase
            end

	default: OUT <= ~(A ^ OUT);  // XNOR mode, B is OUT from previous operation
        endcase
    end
end


endmodule

module add_sub_4_bit (
    input [3:0] a,
    input [3:0] b,
    input k,  // Deciding bit: 0 for addition, 1 for subtraction
    output [3:0] sum,
    output cout
);

// Intermediate signals
wire [3:0] s;
wire c0, c1, c2;
wire [3:0]w1;
assign w1[0] = b[0] ^ k;
assign w1[1] = b[1] ^ k;
assign w1[2] = b[2] ^ k;
assign w1[3] = b[3] ^ k;
  
  full_adder_1bit fa0 (.a(a[0]), .b(w1[0]), .cin(k), .sum(s[0]), .cout(c0));
  full_adder_1bit fa1 (.a(a[1]), .b(w1[1]), .cin(c0), .sum(s[1]), .cout(c1));
  full_adder_1bit fa2 (.a(a[2]), .b(w1[2]), .cin(c1), .sum(s[2]), .cout(c2));
  full_adder_1bit fa3 (.a(a[3]), .b(w1[3]), .cin(c2), .sum(s[3]), .cout(cout));


// Output sum
assign sum = s;

endmodule

module full_adder_1bit (
    input a,
    input b,
    input cin,
    output sum,
    output cout
);

// Intermediate signals
wire s1, c1, c2;

// First stage: Add A, B, and Cin
xor xor1 (s1, a, b);
nand nand1 (c1, s1, cin);
nand nand2 (c2, a, b);
nand nand3 (cout, c1, c2);

// Second stage: Add Sum from first stage and Cin
xor xor2 (sum, s1, cin);

endmodule
