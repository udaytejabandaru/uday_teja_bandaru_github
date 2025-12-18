$
.include "/proj/cad/library/mosis/GF65_LPe/cmos10lpe_CDS_oa_dl064_11_20160415/models/YI-SM00030/Hspice/models/design.inc"

$.include dff.pex.sp $include your design
.option post runlvl=5

.param Tc=800p $CLK preiod 
.param Di=100p  $Input delay after rising edge of clock

$xi gnd! Q vdd! CLK R D design  $instantiate your design

TPL GEN_VDD vdd VDD! GND! 1.2v

TPL GEN_RST rst 
TPL GEN_CLK clk

$Expected Output:               D1:1011-D2:1011-   D3:-err-D4:0000-D5:0000-D6:0000-                    D7:1111-D8:-err-D9:0111-D10:1101
TPL GEN_INP in_ready          00100000001000000000010000000100000001000000010000000000000000000000000001000000010000000100000001000000000000
TPL GEN_INP in                00010101010001010100000010100000000000000010000000001000000000000000000001111111100010111100101110001001100000

$The following lines are only to get an example of what the output should look like.
TPL GEN_INP out_ready_out_exp 00000000000010000000010000000000100000001000000010000000100000000000000000000000000010000000100000001000000010

TPL GEN_INP a3_out_exp        xxxxxxxxxxxx1xxxxxxxx1xxxxxxxxxxxxxxxxxx0xxxxxxx0xxxxxxx0xxxxxxxxxxxxxxxxxxxxxxxxxxx1xxxxxxxxxxxxxxx0xxxxxxx1x
TPL GEN_INP a2_out_exp        xxxxxxxxxxxx0xxxxxxxx0xxxxxxxxxxxxxxxxxx0xxxxxxx0xxxxxxx0xxxxxxxxxxxxxxxxxxxxxxxxxxx1xxxxxxxxxxxxxxx1xxxxxxx1x
TPL GEN_INP a1_out_exp        xxxxxxxxxxxx1xxxxxxxx1xxxxxxxxxxxxxxxxxx0xxxxxxx0xxxxxxx0xxxxxxxxxxxxxxxxxxxxxxxxxxx1xxxxxxxxxxxxxxx1xxxxxxx0x
TPL GEN_INP a0_out_exp        xxxxxxxxxxxx1xxxxxxxx1xxxxxxxxxxxxxxxxxx0xxxxxxx0xxxxxxx0xxxxxxxxxxxxxxxxxxxxxxxxxxx1xxxxxxxxxxxxxxx1xxxxxxx1x

TPL GEN_INP err_out_exp       xxxxxxxxxxxx0xxxxxxxx0xxxxxxxxxx1xxxxxxx0xxxxxxx0xxxxxxx0xxxxxxxxxxxxxxxxxxxxxxxxxxx0xxxxxxx1xxxxxxx0xxxxxxx0x

TPL GEN_RUN .tr 10ps 2  $Run for number of input clock cycles plus 2

.end

