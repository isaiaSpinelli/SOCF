quietly WaveActivateNextPane {} 0
add wave -noupdate -radix hexadecimal /Md5CoreTest/clk
add wave -noupdate -radix hexadecimal /Md5CoreTest/reset
add wave -noupdate -radix hexadecimal /Md5CoreTest/test_all
add wave -noupdate -radix hexadecimal /Md5CoreTest/chunk
add wave -noupdate -radix hexadecimal /Md5CoreTest/valid_in
add wave -noupdate -radix hexadecimal /Md5CoreTest/footprint_out
add wave -noupdate -radix hexadecimal /Md5CoreTest/valid_out
add wave -noupdate -radix hexadecimal /Md5CoreTest/count
add wave -noupdate -radix hexadecimal /Md5CoreTest/test0
add wave -noupdate -radix hexadecimal /Md5CoreTest/test1
add wave -noupdate -radix hexadecimal /Md5CoreTest/test2
add wave -noupdate -radix hexadecimal /Md5CoreTest/test3
add wave -noupdate -radix hexadecimal /Md5CoreTest/test4
add wave -noupdate -radix hexadecimal /Md5CoreTest/test5
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {2671 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 124
configure wave -valuecolwidth 40
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
configure wave -timelineunits ns
update
WaveRestoreZoom {2309 ns} {3037 ns}
