DEBUG LAYER ONE
-----

iverilog -g2012 -o sim.out tb_l1.sv l1_test.v memory.v top_module_l1.v

DEBUG ANN
-----

iverilog -g2012 -o sim.out top_module2.v memory.v layer_one_fsm1.v layer_two_fsm1.v tb_singlw1.sv

SINGLE WORKING
------

iverilog -g2012 -o sim.out top_module.v memory.v layer_one_fsm1.v layer_two_fsm1.v tb_single.sv

ANN WITH DIRECT MULTIPLICATION
------
iverilog -g2012 -o sim.out top_module.v memory.v layer_one_fsm1.v layer_two_fsm1.v tb.sv



FILES
----------------------

Direct multiplication
------
layer_one_fsm1.v
layer_two_fsm1.v

Shift & add
------

layer_one_fsm.v 
layer_two_fsm.v
