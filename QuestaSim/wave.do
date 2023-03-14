onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -expand -group Vertical /bmp_sim_VIP_tb/u_VIP_vertical_projection/clk
add wave -noupdate -expand -group Vertical /bmp_sim_VIP_tb/u_VIP_vertical_projection/rst_n
add wave -noupdate -expand -group Vertical /bmp_sim_VIP_tb/u_VIP_vertical_projection/per_frame_vsync
add wave -noupdate -expand -group Vertical /bmp_sim_VIP_tb/u_VIP_vertical_projection/per_frame_href
add wave -noupdate -expand -group Vertical /bmp_sim_VIP_tb/u_VIP_vertical_projection/per_frame_clken
add wave -noupdate -expand -group Vertical /bmp_sim_VIP_tb/u_VIP_vertical_projection/per_img_Bit
add wave -noupdate -expand -group Vertical /bmp_sim_VIP_tb/u_VIP_vertical_projection/post_frame_vsync
add wave -noupdate -expand -group Vertical /bmp_sim_VIP_tb/u_VIP_vertical_projection/post_frame_href
add wave -noupdate -expand -group Vertical /bmp_sim_VIP_tb/u_VIP_vertical_projection/post_frame_clken
add wave -noupdate -expand -group Vertical /bmp_sim_VIP_tb/u_VIP_vertical_projection/post_img_Bit
add wave -noupdate -expand -group Vertical /bmp_sim_VIP_tb/u_VIP_vertical_projection/max_line_right
add wave -noupdate -expand -group Vertical /bmp_sim_VIP_tb/u_VIP_vertical_projection/max_line_left
add wave -noupdate -expand -group horizon -radix unsigned /bmp_sim_VIP_tb/u_VIP_horizon_projection/clk
add wave -noupdate -expand -group horizon -radix unsigned /bmp_sim_VIP_tb/u_VIP_horizon_projection/rst_n
add wave -noupdate -expand -group horizon -radix unsigned /bmp_sim_VIP_tb/u_VIP_horizon_projection/per_frame_vsync
add wave -noupdate -expand -group horizon -radix unsigned /bmp_sim_VIP_tb/u_VIP_horizon_projection/per_frame_href
add wave -noupdate -expand -group horizon -radix unsigned /bmp_sim_VIP_tb/u_VIP_horizon_projection/per_img_Bit
add wave -noupdate -expand -group horizon -radix unsigned /bmp_sim_VIP_tb/u_VIP_horizon_projection/post_frame_vsync
add wave -noupdate -expand -group horizon -radix unsigned /bmp_sim_VIP_tb/u_VIP_horizon_projection/post_frame_href
add wave -noupdate -expand -group horizon -radix unsigned /bmp_sim_VIP_tb/u_VIP_horizon_projection/post_frame_clken
add wave -noupdate -expand -group horizon -radix unsigned /bmp_sim_VIP_tb/u_VIP_horizon_projection/post_img_Bit
add wave -noupdate -expand -group horizon -radix unsigned /bmp_sim_VIP_tb/u_VIP_horizon_projection/max_line_up
add wave -noupdate -expand -group horizon -radix unsigned /bmp_sim_VIP_tb/u_VIP_horizon_projection/max_line_down
add wave -noupdate -expand -group horizon -radix unsigned /bmp_sim_VIP_tb/u_VIP_horizon_projection/x_cnt
add wave -noupdate -expand -group horizon -radix unsigned /bmp_sim_VIP_tb/u_VIP_horizon_projection/y_cnt
add wave -noupdate -expand -group horizon /bmp_sim_VIP_tb/u_VIP_horizon_projection/ram_wr
add wave -noupdate -expand -group horizon /bmp_sim_VIP_tb/u_VIP_horizon_projection/ram_wr_data
add wave -noupdate -expand -group horizon -radix unsigned /bmp_sim_VIP_tb/u_VIP_horizon_projection/u_dual_port_ram/wr_en
add wave -noupdate -expand -group horizon -radix unsigned /bmp_sim_VIP_tb/u_VIP_horizon_projection/u_dual_port_ram/wr_addr
add wave -noupdate -expand -group horizon -radix unsigned /bmp_sim_VIP_tb/u_VIP_horizon_projection/u_dual_port_ram/wr_data
add wave -noupdate -expand -group horizon -radix unsigned /bmp_sim_VIP_tb/u_VIP_horizon_projection/ram_rd_addr
add wave -noupdate -expand -group horizon -radix unsigned /bmp_sim_VIP_tb/u_VIP_horizon_projection/per_img_Bit
add wave -noupdate -expand -group horizon -radix unsigned /bmp_sim_VIP_tb/u_VIP_horizon_projection/per_frame_clken
add wave -noupdate -expand -group horizon -color Gold -radix unsigned /bmp_sim_VIP_tb/u_VIP_horizon_projection/ram_rd_data
add wave -noupdate -expand -group horizon -color Gold -radix unsigned /bmp_sim_VIP_tb/u_VIP_horizon_projection/rd_data_d2
add wave -noupdate -expand -group horizon -color Magenta /bmp_sim_VIP_tb/u_VIP_horizon_projection/u_dual_port_ram/memory
add wave -noupdate -expand -group horizon -radix unsigned /bmp_sim_VIP_tb/u_VIP_horizon_projection/EDGE_THROD
add wave -noupdate -expand -group horizon -radix unsigned /bmp_sim_VIP_tb/u_VIP_horizon_projection/rise_flag
add wave -noupdate -expand -group horizon -radix unsigned /bmp_sim_VIP_tb/u_VIP_horizon_projection/max_y1
add wave -noupdate -expand -group horizon -radix unsigned /bmp_sim_VIP_tb/u_VIP_horizon_projection/max_y2
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 6} {7414970582 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
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
WaveRestoreZoom {7414722981 ps} {7415539127 ps}
bookmark add wave bookmark0 {{3016230134 ps} {42475143932 ps}} 0
