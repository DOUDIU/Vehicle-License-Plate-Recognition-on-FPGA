module plate_feature_recognize
#(
	parameter	[9:0]	IMG_HDISP = 10'd640,	//640*480
	parameter	[9:0]	IMG_VDISP = 10'd480
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
	// output				post_frame_vsync,	//Processed Image data vsync valid signal
	// output				post_frame_href,	//Processed Image data href vaild  signal
	// output				post_frame_clken,	//Processed Image data output/capture enable clock
	// output				post_img_Bit, 		//Processed Image Bit flag outout(1: Value, 0:inValid)

	input       [20:0] 	char_boarder[7:0],			//车牌中字符的位置
    input     	[9:0]  	char_top	,  	
    input     	[9:0]  	char_down ,

	output reg  [0:4] 	char_feature  [7:0] [7:0] //各字符的特征值，以二维数组的形式存在
);

//------------------------------------------
//lag 1 clocks signal sync  

reg			per_frame_vsync_r;
reg			per_frame_href_r;	
reg			per_frame_clken_r;
reg  		per_img_Bit_r;

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
//寄存纵横坐标
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
wire [7:0] char_flag			;		//各字符的有效标志
wire [9:0] char_left 	[7:0] 	;		//各字符的左/右边界
wire [9:0] char_right 	[7:0] 	;

wire [9:0] char_width 	[7:0] 	;		//各字符的宽/高
wire [9:0] char_height 	 		;


reg [9:0] x_div_num	[7:0]	;		//当前像素对于各字符方框的方格序号
reg [9:0] y_div_num	[7:0]	;		//当前像素对于各字符方框的方格序号

reg [7:0] div_width  [7:0];				//单个字符划分成8*5方格
reg [7:0] div_height [7:0];

reg [7:0] div_pixel_sum[7:0];			//每个字符方格中像素总和

wire[9:0] x_div_num_ok	[7:0]	;		//当前像素对于各字符方框的方格序号（排除超过4的部分）
wire[9:0] y_div_num_ok	[7:0]	;		//当前像素对于各字符方框的方格序号（排除超过7的部分）

generate
genvar i;
	for(i=0; i<8; i = i+1) begin
		assign char_flag[i]		= char_boarder[i][20];
		assign char_left[i]		= char_boarder[i][19:10];
		assign char_right[i] 	= char_boarder[i][ 9: 0];
				
		assign char_width[i] 	= char_boarder[i][ 9: 0] - char_boarder[i][19:10] ;
		assign char_height  	= char_down - char_top ;
		
		assign x_div_num_ok[i]  = (x_div_num[i] > 4) ? 4 : x_div_num[i];
		assign y_div_num_ok[i]  = (y_div_num[i] > 7) ? 7 : y_div_num[i];
	end
endgenerate

//------------------------------------------

//计算分割字符所用8x5方格的 宽度/高度/以及当前像素点的方格编号
integer k;
always @(posedge clk) begin
	for(k=0;k<8;k=k+1) begin
		if(char_width[k] % 5 > 2)
			div_width[k]  <= (char_width[k] / 5) + 1;
		else
			div_width[k]  <= (char_width[k] / 5);
		
		if(char_height % 8 > 3)
			div_height[k] <= (char_height / 8) + 1;
		else
			div_height[k] <= (char_height / 8);
			
		if(x_cnt > char_left[k]) begin					//提前一个时钟周期计算当前像素点落在字符的哪个方格中
			x_div_num[k] <= (x_cnt-char_left[k]) / div_width[k] ;
		end
		
		if(y_cnt > char_top) begin
			y_div_num[k] <= (y_cnt-char_top) / div_height[k];
		end		
		
		div_pixel_sum[k] <= (div_width[k] * div_height[k])/2;
        
		//div_pixel_sum[k] <= (3 * div_width[k] * div_height[k]) / 5;
			
            
	end
end




//------------------------------------------
//对每个字符的40个方格中亮度为1的像素进行计数
reg [7:0] pixel_cnt [7:0] [7:0] [4:0];	// 8个字符 | 8行 | 5列  

integer m;
integer n;
integer p;

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin						//初始化
		for(m=0; m<8; m = m+1) begin			//遍历8个字符
			for(n=0; n<8; n = n+1) begin		//遍历8行
				for(p=0; p<5; p = p+1) begin	//遍历5列
					pixel_cnt[m][n][p] <= 8'd0;
				end			
			end			
		end
	end
	else if(y_cnt_r == 1)begin   						//在一帧开始进行初始化
		for(m=0; m<8; m = m+1) begin			//遍历8个字符
			for(n=0; n<8; n = n+1) begin		//遍历8行
				for(p=0; p<5; p = p+1) begin	//遍历5列
					pixel_cnt[m][n][p] <= 8'd0;
				end			
			end			
		end
	end 	
    else if(y_cnt_r <= char_down) begin
        for(m=0; m<8; m = m+1) begin	
            //判断当前像素落在哪个字符的区域内
            if((x_cnt_r >=  char_left[m]) && (x_cnt_r < char_right[m]) && (y_cnt_r > char_top) && (y_cnt_r < char_down) )  begin
				if(per_img_Bit_r && per_frame_clken_r) //当前像素为1
					pixel_cnt[m][y_div_num_ok[m]][x_div_num_ok[m]] <= pixel_cnt[m][y_div_num_ok[m]][x_div_num_ok[m]] + 1'b1;
			end
        end
    end	 
end

//------------------------------------------
//计算各字符的特征值，以二维数组的形式存在

integer r;
integer s;
integer t;

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin							//初始化
		for(r=0; r<8; r = r+1) begin			//遍历8个字符
			for(s=0; s<8; s = s+1) begin
				char_feature[r][s]  <= 5'd0;
			end
		end
	end
	else if(y_cnt_r == char_down + 1)begin			//在各方格中为1的像素数统计完成后，统计特征值
		for(r=0; r<8; r = r+1) begin			//遍历8个字符
			for(s=0; s<8; s = s+1) begin		//遍历8行
				for(t=0; t<5; t = t+1) begin	//遍历5列
				
					if(pixel_cnt[r][s][t] > div_pixel_sum[r])			//方格中为1的像素数超过1/2，判定特征值为1
						char_feature[r][s][t] <= 1'b1;			 
					else
						char_feature[r][s][t] <= 1'b0;
				end			
			end			
		end
	end 	
end

endmodule