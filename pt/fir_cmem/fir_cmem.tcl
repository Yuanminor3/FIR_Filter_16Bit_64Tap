#################################################
# Primetime 
# Script for static timing analysis
# MS 7/2015
#################################################

#################################################
# Units are defined in the .lib file
# time: ns
#################################################

## Global
set sh_enable_page_mode true
set power_enable_analysis true

## Setting files/paths
set verilog_files {../../dc/fir_cmem/fir_cmem.nl.v}
set my_toplevel fir_cmem
set search_path "/homes/user/stud/fall24/yj2848/EE4823FIR/dc/lib2db/"
set link_path "* CMEM_tt_1p2v_25c_syn.db" 

## Read design
read_db "CMEM_tt_1p2v_25c_syn.db"
read_verilog $verilog_files
link_design $my_toplevel

## Timing Constraints
source ./timing.tcl


###################################################
## Run STA 
###################################################
set rpt_file "./fir_cmem_pt.rpt"
check_timing
report_design >> ${rpt_file}
report_reference >> ${rpt_file}
report_constraint >> ${rpt_file}
report_constraint -all_violators -significant_digits 4 >> ${rpt_file}
report_timing -significant_digits 4 -delay_type min_max >> ${rpt_file}

## Power analysis
set power_analysis_mode "time_based"
read_vcd "../../qsim_dc/fir_cmem/fir_cmem.vcd" -strip_path "testbench/uut"
report_switching_activity >> ${rpt_file}
report_switching_activity -list_not_annotated >> ${rpt_file}
update_power
report_power >> ${rpt_file}
report_power -hierarchy  >> ${rpt_file}

write_sdf -context verilog "./fir_cmem.sdf"

# Exiting primetime
quit
