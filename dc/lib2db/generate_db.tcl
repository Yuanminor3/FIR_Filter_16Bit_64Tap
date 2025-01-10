enable_write_lib_mode
# Please change the below lib to your lib file
read_lib /user/stud/fall24/yj2848/EE4823FIR/rtl/IMEM/IMEM_tt_1p2v_25c_syn.lib
list_lib
# You can read your lib namei from list_lib and modify USERLIB accordingly; change the output filename if needed
write_lib USERLIB -output ./IMEM_tt_1p2v_25c_syn.db
#write_lib USERLIB 
quit
