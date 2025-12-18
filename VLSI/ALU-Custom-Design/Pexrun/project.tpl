$
.include "/proj/cad/library/mosis/GF65_LPe/cmos10lpe_CDS_oa_dl064_11_20160415/models/YI-SM00030/Hspice/models/design.inc"
 
.include Top_alu.pex.netlist
.option post runlvl=5
 
.param Tc=0.46n $CLK period
.param Di=5p  $Input delay after rising edge of clock
 
xi GND! OUT<3> OUT<1> OUT<0> OUT<2> VDD! INST<0> CLK A<3> A<1>
+ A<2> A<0> INST<1> RESET Top_alu 
 
TPL GEN_VDD vdd VDD! GND! 1.2v
 
TPL GEN_INP INST<0> 000111000000000011
TPL GEN_INP INST<1> 000000001100111111
TPL GEN_INP A<3>    000000000000001111
TPL GEN_INP A<2>    001100000000000011
TPL GEN_INP A<1>    000011000000001100
TPL GEN_INP A<0>    001111111111110011

TPL GEN_INP RESET   1000000000000000000
TPL GEN_INP CLK     0101010101010101010
 
TPL GEN_RUN .tr 10ps 2  $Run for number of input clock cycles plus 2
 
.end
