`timescale 1ns/1ns
module VIP_horizon_projection_char
#(
	parameter	[9:0]	IMG_HDISP = 10'd640,	//640*480
	parameter	[9:0]	IMG_VDISP = 10'd480,
	
	parameter   [9:0]   EDGE_THROD = 10'd14
)
(
	//global clock
	input				clk,  				//cmos video pixel clock
	input				rst_n,				//global reset

	//Image data prepred to be processd
	input				per_frame_vsync,	//Prepared Image data vsync valid signal
	input				per_frame_href,		//Prepared Image data href vaild  signal
	input				per_frame_clken,	//Prepared Image data output/capture enable clock
	input				per_img_Bit,		//Prepared Image Bit flag outout(1: Value, 0:inValid)
	
	//Image data has been processd
	output				post_frame_vsync,	//Processed Image data vsync valid signal
	output				post_frame_href,	//Processed Image data href vaild  signal
	output				post_frame_clken,	//Processed Image data output/capture enable clock
	output				post_img_Bit, 		//Processed Image Bit flag outout(1: Value, 0:inValid)

    output reg [9:0] 	char_top ,        //边沿坐标
    output reg [9:0] 	char_down,
	
    input      [9:0] 	horizon_start,		//投影起始列
    input      [9:0] 	horizon_end			//投影结束列  
);

reg [9:0] 	max_pixel_up  ;
reg [9:0] 	max_pixel_down;

reg			per_frame_vsync_r;
reg			per_frame_href_r;	
reg			per_frame_clken_r;
reg  		per_img_Bit_r;

reg			per_frame_vsync_r2;
reg			per_frame_href_r2;	
reg			per_frame_clken_r2;
reg         per_img_Bit_r2;

assign	post_frame_vsync 	= 	per_frame_vsync_r2;
assign	post_frame_href 	= 	per_frame_href_r2;	
assign	post_frame_clken 	= 	per_frame_clken_r2;
assign  post_img_Bit     	=   per_img_Bit_r2;

//------------------------------------------
//lag 1 clocks signal sync  

always@(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		begin
		per_frame_vsync_r2 	<= 0;
		per_frame_href_r2 	<= 0;
		per_frame_clken_r2 	<= 0;
		per_img_Bit_r2		<= 0;
		end
	else
		begin
		per_frame_vsync_r2 	<= 	per_frame_vsync_r 	;
		per_frame_href_r2	<= 	per_frame_href_r 	;
		per_frame_clken_r2 	<= 	per_frame_clken_r 	;
		per_img_Bit_r2		<= 	per_img_Bit_r		;
		end
end

//------------------------------------------
//lag 1 clocks signal sync  

always@(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		begin
		per_frame_vsync_r 	<= 0;
		per_frame_href_r 	<= 0;
		per_frame_clken_r 	<= 0;
		per_img_Bit_r		<= 0;
		end
	else
		begin
		per_frame_vsync_r 	<= 	per_frame_vsync	;
		per_frame_href_r	<= 	per_frame_href	;
		per_frame_clken_r 	<= 	per_frame_clken	;
		per_img_Bit_r	    <= 	per_img_Bit		;
		end
end

wire vsync_pos_flag;
wire vsync_neg_flag;

assign vsync_pos_flag = per_frame_vsync    & (~per_frame_vsync_r);
assign vsync_neg_flag = (~per_frame_vsync) & per_frame_vsync_r;

//------------------------------------------
//对输入的像素进行“行/场”方向计数，得到其纵横坐标
reg [9:0]  	x_cnt;
reg [9:0]   y_cnt;

always@(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		begin
			x_cnt <= 10'd0;
			y_cnt <= 10'd0;
		end
	else
		if(vsync_pos_flag)begin
			x_cnt <= 10'd0;
			y_cnt <= 10'd0;
		end
		else if(per_frame_clken) begin
			if(x_cnt < IMG_HDISP - 1) begin
				x_cnt <= x_cnt + 1'b1;
				y_cnt <= y_cnt;
			end
			else begin
				x_cnt <= 10'd0;
				y_cnt <= y_cnt + 1'b1;
			end
		end
end

//------------------------------------------
//寄存“行/场”方向计数
reg [9:0]  	x_cnt_r;
reg [9:0]   y_cnt_r;

always@(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		begin
			x_cnt_r <= 10'd0;
			y_cnt_r <= 10'd0;
		end
	else begin
			x_cnt_r <= x_cnt;
            y_cnt_r <= y_cnt;
		end
end

//------------------------------------------
//水平计数像素跳变

reg [9:0] 	change_cnt;

reg 		img_bit_reg;

reg 		char_top_flag;
reg [9:0]   char_top_reg ;
reg [9:0]   char_down_reg;


always@(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		char_top_flag	<= 0;
		char_top_reg 	<= 0;
		char_down_reg	<= 0;
		img_bit_reg 	<= 0;
		change_cnt 		<= 0;
	end
	else if(vsync_pos_flag) begin			//一帧开始初始化
		char_top_flag	<= 0;
		char_top_reg 	<= 0;
		char_down_reg	<= 0;
		img_bit_reg 	<= 0;
		change_cnt 		<= 0;
	end
	else if(post_frame_href == 1'b0) begin	//一行开始初始化
		img_bit_reg	<= 0;
		change_cnt  <= 0;	
	end
	else if(per_frame_clken) begin
		
		img_bit_reg	<= per_img_Bit;
		
		if((img_bit_reg != per_img_Bit))
			change_cnt <= change_cnt + 1'b1;

		//下边界
		if((x_cnt == IMG_HDISP -1) && (char_top_flag == 0) && (change_cnt >= EDGE_THROD -1) ) begin
			char_top_reg 	<= y_cnt ; //+ 1
			char_top_flag 	<= 1'b1;
		end
		
		//上边界
		if((x_cnt == IMG_HDISP -1) && (char_top_flag == 1) && (change_cnt >= EDGE_THROD -1) ) begin
			char_down_reg 	<= y_cnt + 1;
		end
	end
end

always @ (posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        char_top  <= 10'd0;
        char_down <= 10'd0;
    end
    else if(vsync_neg_flag) begin
		char_top  <= char_top_reg ;
		char_down <= char_down_reg;
    end   
end
	
endmodule
