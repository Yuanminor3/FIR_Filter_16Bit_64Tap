##################################################
#  Modelsim do file to run simuilation
#  MS 7/2015
##################################################

#Setup
 vlib work 
 vmap work work

#Include Netlist and Testbench
 vlog +acc -incr /courses/ee6321/share/ibm13rflpvt/verilog/ibm13rflpvt.v
vlog +acc -incr ../../rtl/CMEM/CMEM.v 
vlog +acc -incr ../../dc/fir_cmem/fir_cmem.nl.v
vlog +acc -incr ../../dc/fir_fifo/fir_fifo.nl.v
vlog +acc -incr ../../dc/fir_alu/fir_alu.nl.v
vlog +acc -incr ../../dc/fir_shift_imem/fir_shift_imem.nl.v
 vlog +acc -incr ../../dc/fir_core/fir_core.nl.v
 vlog +acc -incr fir_core_tb.v

#Run Simulator 
#SDF from DC is annotated for the timing check 
vsim -voptargs=+acc -t ps -lib work -sdftyp uut=../../dc/fir_core/fir_core.syn.sdf fir_core_tb 
 do waveformat.do   
 run -all
