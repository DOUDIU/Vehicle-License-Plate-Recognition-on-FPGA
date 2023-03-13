//对字符区域进行二值化，其他区域显示黑色

module binarization_char
#(
	parameter	[9:0]	IMG_HDISP = 10'd640,	//640*480
	parameter	[9:0]	IMG_VDISP = 10'd480
)
(
    input               clk             ,   // 时钟信号
    input               rst_n           ,   // 复位信号（低有效）

	input				per_frame_vsync,
	input				per_frame_href ,	
	input				per_frame_clken,
	input		[7:0]	per_img_Y,		

	output	reg 		post_frame_vsync,	
	output	reg 		post_frame_href ,	
	output	reg 		post_frame_clken,	
	output	reg 		post_img_Bit,		

	input		[7:0]	Binary_Threshold,
	
    input       [9:0] 	plate_boarder_up 	,  	//调整后的边框
    input       [9:0] 	plate_boarder_down	, 
    input       [9:0] 	plate_boarder_left 	,
    input       [9:0] 	plate_boarder_right	 
);

//------------------------------------------
reg			per_frame_vsync_r;

always@(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		per_frame_vsync_r 	<= 0;
	else
		per_frame_vsync_r 	<= 	per_frame_vsync	;
end

wire 	vsync_pos_flag;
assign 	vsync_pos_flag = per_frame_vsync & (~per_frame_vsync_r);

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
	else begin
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
end

//二值化
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        post_img_Bit <= 1'b0;
    else begin
		if((x_cnt > plate_boarder_left) && (x_cnt < plate_boarder_right) && 
			(y_cnt >  plate_boarder_up) && (y_cnt < plate_boarder_down)) begin
			
			if(per_img_Y > Binary_Threshold)  //阈值
				post_img_Bit <= 1'b1;
			else
				post_img_Bit <= 1'b0;		
		end
		else begin
			post_img_Bit <= 1'b0;
		end
	end
end


always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        post_frame_vsync <= 1'd0;
        post_frame_href  <= 1'd0;
        post_frame_clken <= 1'd0;
    end
    else begin
        post_frame_vsync <= per_frame_vsync;
        post_frame_href  <= per_frame_href ;
        post_frame_clken <= per_frame_clken;
    end
end

endmodule
