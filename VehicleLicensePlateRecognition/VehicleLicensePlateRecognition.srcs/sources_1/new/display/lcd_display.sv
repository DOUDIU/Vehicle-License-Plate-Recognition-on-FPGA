`timescale 1ns / 1ps
//****************************************Copyright (c)***********************************//
// Descriptions:        LCD显示模块
//                      LCD分辨率640*480
//****************************************************************************************//

module lcd_display(
    input             	lcd_clk,                  	//lcd驱动时钟
    input             	sys_rst_n,                	//复位信号
		
    input      	[9:0] 	pixel_xpos,               	//像素点横坐标
    input      	[9:0] 	pixel_ypos,               	//像素点纵坐标   
    
    output  	[3:0]   VGA_R,
    output  	[3:0]   VGA_G,
    output  	[3:0]   VGA_B ,
    
    input     	[9:0]  	left_pos  ,            		//整个车牌的位置	
    input     	[9:0]  	right_pos ,
    input     	[9:0]  	up_pos ,  	
    input     	[9:0]  	down_pos,
	
    input     	[9:0]  	char_left_pos  ,            		//字符区域的位置	
    input     	[9:0]  	char_right_pos ,
    input     	[9:0]  	char_up_pos ,  	
    input     	[9:0]  	char_down_pos,

	input       [20:0] 	char_boarder[7:0],			//车牌中字符的位置
    input     	[9:0]  	char_top	,  	
    input     	[9:0]  	char_down 
    );    

//parameter define  
parameter  H_LCD_DISP = 11'd640;                //LCD分辨率--行
parameter  V_LCD_DISP = 11'd480;                //LCD分辨率--行

localparam BLACK  = 16'b00000_000000_00000;     //RGB565 
localparam WHITE  = 16'b11111_111111_11111;     //RGB565 
localparam RED    = 16'b11111_000000_00000;     //RGB565 
localparam BLUE   = 16'b00000_000000_11111;     //RGB565 
localparam GREEN  = 16'b00000_111111_00000;     //RGB565 
localparam GRAY   = 16'b11000_110000_11000;     //RGB565 

reg border_flag;

//绘制一个大的方框，标记整个车牌

//判断坐标是否落在矩形方框边界上
always @(posedge lcd_clk or negedge sys_rst_n) begin
    if(!sys_rst_n) begin	//初始化
			border_flag <= 0;
		end
    else begin

            //判断上下边界
            if((pixel_xpos >  left_pos) && (pixel_xpos < right_pos) && ((pixel_ypos == up_pos) ||(pixel_ypos == down_pos)) )  
				border_flag <= 1;
           //判断左右边界
            else if((pixel_ypos > up_pos) && (pixel_ypos < down_pos) && ((pixel_xpos == left_pos) ||(pixel_xpos == right_pos)) )     
				border_flag <= 1;
            
			//字符上下边界
			else if((pixel_xpos >  char_left_pos) && (pixel_xpos < char_right_pos) && ((pixel_ypos == char_up_pos) ||(pixel_ypos == char_down_pos)) )  
				border_flag <= 1;
           //字符左右边界
            else if((pixel_ypos > char_up_pos) && (pixel_ypos < char_down_pos) && ((pixel_xpos == char_left_pos) ||(pixel_xpos == char_right_pos)) )     
				border_flag <= 1;
			
			else 
                border_flag <= 0;

    end 
end 

//绘制最大值方框
wire [7:0] char_flag;			    //各字符的有效标志
wire [9:0] char_left 	[7:0] ;		//各字符的左/右/上/下边界
wire [9:0] char_right 	[7:0] ;

wire [9:0] char_width 	[7:0] ;
wire [9:0] char_height 	 ;

generate
genvar i;
	for(i=0; i<8; i = i+1) begin
		assign char_flag[i]		= char_boarder[i][20];
		assign char_left[i]		= char_boarder[i][19:10];
		assign char_right[i] 	= char_boarder[i][ 9: 0];
				
		assign char_width[i] 	= char_boarder[i][ 9: 0] - char_boarder[i][19:10];
		assign char_height  	= char_down - char_top;
	end
endgenerate

//给每个字符绘制小的边框
integer j;
reg [7:0] char_border_flag;

always @(posedge lcd_clk or negedge sys_rst_n) begin
    if(!sys_rst_n) 	//初始化
			char_border_flag <= 8'd0;
    else begin
        for(j=0; j<8; j = j+1) begin	//未出现新的最大值，则根据灰度判断是否替换最大值列表中的元素
            //判断上下边界
            if((pixel_xpos >  char_left[j]) && (pixel_xpos < char_right[j]) && ((pixel_ypos == char_top) ||(pixel_ypos == char_down)) )  
				char_border_flag[j] <= char_flag[j];

           //判断左右边界
            else if((pixel_ypos > char_top) && (pixel_ypos < char_down) && ((pixel_xpos == char_left[j]) ||(pixel_xpos == char_right[j])) )     
				char_border_flag[j] <= char_flag[j];

            else 
                char_border_flag[j] <= 1'b0;	
        end
    end 
end

//将每个字符的边框再次划分8*5的小方框

reg [7:0] div_width  [7:0];
reg [7:0] div_height [7:0];

integer k;
always @(posedge lcd_clk) begin
	for(k=0;k<8;k=k+1) begin
		if(char_width[k] % 5 > 2)
			div_width[k]  <= (char_width[k] / 5) + 1;
		else
			div_width[k]  <= (char_width[k] / 5);
		
		if(char_height % 8 > 3)
			div_height[k] <= (char_height / 8) + 1;
		else
			div_height[k] <= (char_height / 8);
	end
end

integer m;
reg [7:0] div_border_flag;

always @(posedge lcd_clk or negedge sys_rst_n) begin
    if(!sys_rst_n) 	//初始化
			div_border_flag <= 8'd0;
    else begin
        for(m=0; m<8; m = m+1) begin	//未出现新的最大值，则根据灰度判断是否替换最大值列表中的元素
            //判断上下边界
            if((pixel_xpos >  char_left[m]) && (pixel_xpos < char_right[m]) && (pixel_ypos > char_top) && (pixel_ypos < char_down) )  begin
				if(((pixel_xpos-char_left[m])%div_width[m] == 0) || ((pixel_ypos-char_top)%div_height[m] == 0))
					div_border_flag[m] <= char_flag[m];
				else
					div_border_flag[m] <= 1'b0;
			end
			else 
                div_border_flag[m] <= 1'b0;
        end
    end 
end

wire div_border_flag_final;

assign div_border_flag_final = (div_border_flag > 8'd0)? 1'b1 : 1'b0;
    

//像素点落在任一矩形框上均会导致char_border_flag不为0
assign char_border_flag_final = (char_border_flag > 8'd0)? 1'b1 : 1'b0;

// assign VGA_R = border_flag ? 4'b1111 : (char_border_flag_final ? 4'b0000 : 4'b0000);
// assign VGA_G = border_flag ? 4'b0000 : (char_border_flag_final ? 4'b1111 : 4'b0000);
// assign VGA_B = border_flag ? 4'b0000 : (char_border_flag_final ? 4'b0000 : 4'b0000);

assign VGA_R = border_flag ? 4'b1111 : (char_border_flag_final ? 4'b0000 : (div_border_flag_final ? 4'b0000 : 4'b0000));
assign VGA_G = border_flag ? 4'b0000 : (char_border_flag_final ? 4'b1111 : (div_border_flag_final ? 4'b0000 : 4'b0000));
assign VGA_B = border_flag ? 4'b0000 : (char_border_flag_final ? 4'b0000 : (div_border_flag_final ? 4'b1111 : 4'b0000));

endmodule