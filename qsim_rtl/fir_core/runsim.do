##################################################
#  Modelsim do file to run simuilation
#  MS 7/2015
##################################################

vlib work 
vmap work work

# Include Netlist and Testbench
vlog +acc -incr ../../rtl/CMEM/CMEM.v 
vlog +acc -incr ../../rtl/fir_cmem/fir_cmem.v
vlog +acc -incr ../../rtl/fir_fifo/fir_fifo.v
vlog +acc -incr ../../rtl/fir_alu/fir_alu.v
vlog +acc -incr ../../rtl/fir_shift_imem/fir_shift_imem.v
vlog +acc -incr ../../rtl/fir_core/fir_core.v
vlog +acc -incr fir_core_tb.v 

# Run Simulator 
vsim +acc -t ps -lib work fir_core_tb 
do waveformat.do   
run -all
