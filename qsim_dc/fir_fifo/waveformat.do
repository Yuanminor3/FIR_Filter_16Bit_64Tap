onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /fifo_testbench/clk1
add wave -noupdate /fifo_testbench/clk2
add wave -noupdate /fifo_testbench/rstn
add wave -noupdate /fifo_testbench/valid_in
add wave -noupdate -radix unsigned /fifo_testbench/din
add wave -noupdate -radix unsigned /fifo_testbench/fifo_empty
add wave -noupdate -radix unsigned /fifo_testbench/fifo_full
add wave -noupdate -radix unsigned /fifo_testbench/uut.fifo_mem
add wave -noupdate -radix unsigned /fifo_testbench/fifo_out_data
add wave -noupdate -radix unsigned /fifo_testbench/imem_inst.WEN
add wave -noupdate -radix unsigned /fifo_testbench/imem_inst.A
add wave -noupdate -radix unsigned /fifo_testbench/imem_inst.D
add wave -noupdate -radix unsigned /fifo_testbench/imem_inst.Q
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {3 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 223
configure wave -valuecolwidth 89
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ns} {10 ns}
