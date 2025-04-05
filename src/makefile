all:
	iverilog  PCS.v
	iverilog  TRANSMIT_ORDERED_SET.v
	iverilog  TRANSMIT_CODE_GROUP.v
	iverilog  synch.v
	iverilog  RECEIVE.v
	iverilog tester.v
	iverilog testbench.v
	iverilog -o salida.vvp testbench.v
	vvp salida.vvp
	gtkwave pcs.vcd

