module INVERTER (
	IN, 
	OUT);
   input IN;
   output OUT;
endmodule

module NAND (
	A, 
	B, 
	OUT);
   input A;
   input B;
   output OUT;
endmodule

module NOR (
	A, 
	B, 
	OUT);
   input A;
   input B;
   output OUT;
endmodule

module XOR (
	A, 
	B, 
	OUT);
   input A;
   input B;
   output OUT;
endmodule

module AOI22 (
	A, 
	B, 
	C, 
	D, 
	OUT);
   input A;
   input B;
   input C;
   input D;
   output OUT;
endmodule

module DFF (
	D, 
	CLK, 
	Q);
   input D;
   input CLK;
   output Q;
endmodule

module Top_alu ( A, Inst, RESET, clk, OUT );
  input [3:0] A;
  input [1:0] Inst;
  output [3:0] OUT;
  input RESET, clk;
  wire   N18, N19, N21, N22, N23, N24, N25, N26, N27, N28, N29, N31, N32, N33,
         N37, N38, N39, N45, N46, N47, N49, N50, N51, N52, N53, N54, N55, N59,
         N60, N61, N74, N75, N76, N77, N82, N83, N84, N85, N86, N87, N88, N89,
         n1, n2, n3, n4, n5, n6, n7, n8, n9, n10, n11, n12, n13, n14, n15, n16,
         n17, n18, n19, n20, n21, n22, n23, n24, n25, n26, n27, n28, n29, n30,
         n31, n32, n33, n34, n35, n36, n37, n38, n39, n40, n41, n42, n43, n44,
         n45, n46, n47, n48, n49, n50, n51, \add_sub/c2 , \add_sub/c1 ,
         \add_sub/c0 , \add_sub/fa0/c2 , \add_sub/fa0/c1 , \add_sub/fa0/s1 ,
         \add_sub/fa3/s1 , \add_sub/fa2/c2 , \add_sub/fa2/c1 ,
         \add_sub/fa2/s1 , \add_sub/fa1/c2 , \add_sub/fa1/c1 ,
         \add_sub/fa1/s1 ;
  wire   [3:0] sum;
  wire   [3:0] \add_sub/w1 ;
  assign N21 = A[3];

  XOR C169 ( .A(A[0]), .B(OUT[0]), .OUT(N89) );
  INVERTER I_21 ( .IN(N89), .OUT(N77) );
  XOR C167 ( .A(A[1]), .B(OUT[1]), .OUT(N88) );
  INVERTER I_20 ( .IN(N88), .OUT(N76) );
  XOR C165 ( .A(A[2]), .B(OUT[2]), .OUT(N87) );
  INVERTER I_19 ( .IN(N87), .OUT(N75) );
  XOR C163 ( .A(N21), .B(OUT[3]), .OUT(N86) );
  INVERTER I_18 ( .IN(N86), .OUT(N74) );
  NAND C161 ( .A(A[0]), .B(OUT[3]), .OUT(n1) );
  NAND C160 ( .A(A[1]), .B(OUT[2]), .OUT(n2) );
  NAND C159 ( .A(A[1]), .B(OUT[3]), .OUT(n3) );
  NAND C158 ( .A(A[2]), .B(OUT[3]), .OUT(n4) );
  INVERTER I_16 ( .IN(N54), .OUT(N55) );
  INVERTER I_15 ( .IN(A[0]), .OUT(N52) );
  INVERTER I_14 ( .IN(N50), .OUT(N51) );
  INVERTER I_12 ( .IN(N46), .OUT(N47) );
  NAND C145 ( .A(A[0]), .B(OUT[0]), .OUT(n5) );
  NAND C144 ( .A(A[1]), .B(OUT[0]), .OUT(n6) );
  NAND C143 ( .A(A[1]), .B(OUT[1]), .OUT(n7) );
  NAND C142 ( .A(A[2]), .B(OUT[0]), .OUT(n8) );
  INVERTER I_9 ( .IN(N32), .OUT(N33) );
  INVERTER I_7 ( .IN(N28), .OUT(N29) );
  INVERTER I_6 ( .IN(A[1]), .OUT(N26) );
  INVERTER I_5 ( .IN(N24), .OUT(N25) );
  INVERTER I_4 ( .IN(A[2]), .OUT(N22) );
  INVERTER I_2 ( .IN(Inst[1]), .OUT(N19) );
  NAND C117 ( .A(A[0]), .B(OUT[1]), .OUT(n9) );
  NAND C116 ( .A(A[0]), .B(OUT[2]), .OUT(n10) );
  NAND C115 ( .A(Inst[1]), .B(Inst[0]), .OUT(N18) );
  NAND C65 ( .A(N22), .B(N26), .OUT(N53) );
  NAND C61 ( .A(N22), .B(A[1]), .OUT(N49) );
  NAND C57 ( .A(A[2]), .B(N26), .OUT(N45) );
  NAND C35 ( .A(N22), .B(N26), .OUT(N31) );
  NAND C31 ( .A(N22), .B(A[1]), .OUT(N27) );
  NAND C27 ( .A(A[2]), .B(N26), .OUT(N23) );
  DFF \OUT_reg[0]  ( .D(N82), .CLK(clk), .Q(OUT[0]) );
  DFF \OUT_reg[3]  ( .D(N85), .CLK(clk), .Q(OUT[3]) );
  DFF \OUT_reg[1]  ( .D(N83), .CLK(clk), .Q(OUT[1]) );
  DFF \OUT_reg[2]  ( .D(N84), .CLK(clk), .Q(OUT[2]) );
  NAND U3 ( .A(n11), .B(n12), .OUT(N85) );
  NAND U4 ( .A(sum[3]), .B(n13), .OUT(n12) );
  AOI22 U5 ( .A(n14), .B(n15), .C(n16), .D(N74), .OUT(n11) );
  NAND U6 ( .A(n17), .B(n18), .OUT(n15) );
  NAND U7 ( .A(N33), .B(n19), .OUT(n18) );
  AOI22 U8 ( .A(N25), .B(N37), .C(N29), .D(N38), .OUT(n17) );
  NAND U9 ( .A(n20), .B(n21), .OUT(N84) );
  AOI22 U10 ( .A(n22), .B(N55), .C(n14), .D(n23), .OUT(n21) );
  INVERTER U11 ( .IN(n24), .OUT(n23) );
  AOI22 U12 ( .A(N29), .B(N39), .C(N33), .D(n25), .OUT(n24) );
  NOR U13 ( .A(n1), .B(n26), .OUT(n22) );
  AOI22 U14 ( .A(n16), .B(N75), .C(sum[2]), .D(n13), .OUT(n20) );
  NAND U15 ( .A(n27), .B(n28), .OUT(N83) );
  AOI22 U16 ( .A(n29), .B(n14), .C(n30), .D(n31), .OUT(n28) );
  INVERTER U17 ( .IN(n32), .OUT(n31) );
  AOI22 U18 ( .A(N51), .B(N60), .C(N55), .D(n19), .OUT(n32) );
  INVERTER U19 ( .IN(n10), .OUT(n19) );
  NOR U20 ( .A(n33), .B(N21), .OUT(n14) );
  NOR U21 ( .A(n5), .B(n34), .OUT(n29) );
  INVERTER U22 ( .IN(N33), .OUT(n34) );
  AOI22 U23 ( .A(n16), .B(N76), .C(sum[1]), .D(n13), .OUT(n27) );
  NAND U24 ( .A(n35), .B(n36), .OUT(N82) );
  NAND U25 ( .A(sum[0]), .B(n13), .OUT(n36) );
  INVERTER U26 ( .IN(n37), .OUT(n13) );
  NAND U27 ( .A(n38), .B(N19), .OUT(n37) );
  NOR U28 ( .A(RESET), .B(n39), .OUT(n38) );
  INVERTER U29 ( .IN(N18), .OUT(n39) );
  AOI22 U30 ( .A(n30), .B(n40), .C(n16), .D(N77), .OUT(n35) );
  NOR U31 ( .A(N18), .B(RESET), .OUT(n16) );
  NAND U32 ( .A(n41), .B(n42), .OUT(n40) );
  NAND U33 ( .A(N55), .B(n25), .OUT(n42) );
  INVERTER U34 ( .IN(n9), .OUT(n25) );
  AOI22 U35 ( .A(N47), .B(N59), .C(N51), .D(N61), .OUT(n41) );
  INVERTER U36 ( .IN(n26), .OUT(n30) );
  NAND U37 ( .A(N21), .B(n43), .OUT(n26) );
  INVERTER U38 ( .IN(n33), .OUT(n43) );
  NAND U39 ( .A(n44), .B(N18), .OUT(n33) );
  NOR U40 ( .A(RESET), .B(N19), .OUT(n44) );
  NAND U41 ( .A(n45), .B(n46), .OUT(N54) );
  INVERTER U42 ( .IN(N53), .OUT(n45) );
  NAND U43 ( .A(N52), .B(n47), .OUT(N50) );
  INVERTER U44 ( .IN(N49), .OUT(n47) );
  NAND U45 ( .A(N52), .B(n48), .OUT(N46) );
  INVERTER U46 ( .IN(N45), .OUT(n48) );
  NAND U47 ( .A(n46), .B(n49), .OUT(N32) );
  INVERTER U48 ( .IN(N31), .OUT(n49) );
  INVERTER U49 ( .IN(N52), .OUT(n46) );
  NAND U50 ( .A(N52), .B(n50), .OUT(N28) );
  INVERTER U51 ( .IN(N27), .OUT(n50) );
  NAND U52 ( .A(N52), .B(n51), .OUT(N24) );
  INVERTER U53 ( .IN(N23), .OUT(n51) );
  INVERTER U54 ( .IN(n8), .OUT(N37) );
  INVERTER U55 ( .IN(n7), .OUT(N38) );
  INVERTER U56 ( .IN(n6), .OUT(N39) );
  INVERTER U57 ( .IN(n4), .OUT(N59) );
  INVERTER U58 ( .IN(n3), .OUT(N60) );
  INVERTER U59 ( .IN(n2), .OUT(N61) );
  XOR \add_sub/C10  ( .A(A[0]), .B(Inst[0]), .OUT(\add_sub/w1 [0]) );
  XOR \add_sub/C11  ( .A(A[1]), .B(Inst[0]), .OUT(\add_sub/w1 [1]) );
  XOR \add_sub/C12  ( .A(A[2]), .B(Inst[0]), .OUT(\add_sub/w1 [2]) );
  XOR \add_sub/C13  ( .A(N21), .B(Inst[0]), .OUT(\add_sub/w1 [3]) );
  XOR \add_sub/fa0/U2  ( .A(\add_sub/w1 [0]), .B(OUT[0]), .OUT(
        \add_sub/fa0/s1 ) );
  XOR \add_sub/fa0/U1  ( .A(Inst[0]), .B(\add_sub/fa0/s1 ), .OUT(sum[0]) );
  NAND \add_sub/fa0/nand1  ( .A(\add_sub/fa0/s1 ), .B(Inst[0]), .OUT(
        \add_sub/fa0/c1 ) );
  NAND \add_sub/fa0/nand2  ( .A(OUT[0]), .B(\add_sub/w1 [0]), .OUT(
        \add_sub/fa0/c2 ) );
  NAND \add_sub/fa0/nand3  ( .A(\add_sub/fa0/c1 ), .B(\add_sub/fa0/c2 ), .OUT(
        \add_sub/c0 ) );
  XOR \add_sub/fa3/U2  ( .A(\add_sub/w1 [3]), .B(OUT[3]), .OUT(
        \add_sub/fa3/s1 ) );
  XOR \add_sub/fa3/U1  ( .A(\add_sub/c2 ), .B(\add_sub/fa3/s1 ), .OUT(sum[3])
         );
  XOR \add_sub/fa2/U2  ( .A(\add_sub/w1 [2]), .B(OUT[2]), .OUT(
        \add_sub/fa2/s1 ) );
  XOR \add_sub/fa2/U1  ( .A(\add_sub/c1 ), .B(\add_sub/fa2/s1 ), .OUT(sum[2])
         );
  NAND \add_sub/fa2/nand1  ( .A(\add_sub/fa2/s1 ), .B(\add_sub/c1 ), .OUT(
        \add_sub/fa2/c1 ) );
  NAND \add_sub/fa2/nand2  ( .A(OUT[2]), .B(\add_sub/w1 [2]), .OUT(
        \add_sub/fa2/c2 ) );
  NAND \add_sub/fa2/nand3  ( .A(\add_sub/fa2/c1 ), .B(\add_sub/fa2/c2 ), .OUT(
        \add_sub/c2 ) );
  XOR \add_sub/fa1/U2  ( .A(\add_sub/w1 [1]), .B(OUT[1]), .OUT(
        \add_sub/fa1/s1 ) );
  XOR \add_sub/fa1/U1  ( .A(\add_sub/c0 ), .B(\add_sub/fa1/s1 ), .OUT(sum[1])
         );
  NAND \add_sub/fa1/nand1  ( .A(\add_sub/fa1/s1 ), .B(\add_sub/c0 ), .OUT(
        \add_sub/fa1/c1 ) );
  NAND \add_sub/fa1/nand2  ( .A(OUT[1]), .B(\add_sub/w1 [1]), .OUT(
        \add_sub/fa1/c2 ) );
  NAND \add_sub/fa1/nand3  ( .A(\add_sub/fa1/c1 ), .B(\add_sub/fa1/c2 ), .OUT(
        \add_sub/c1 ) );
endmodule

