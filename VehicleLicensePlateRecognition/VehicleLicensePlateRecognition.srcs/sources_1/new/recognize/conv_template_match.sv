
//------------------------------------------
//通过卷积模板匹配对各字符进行识别

module conv_template_match(
	input				clk,  				//cmos video pixel clock
	input				rst_n,				//global reset
	
	input 		[4:0] 	char_feature  [7:0] [7:0],
    input               char_feature_valid, //输入特征值有效标志，一个时钟周期
	
	output reg [7:0]	char_index [7:0],	//匹配的字符索引
	output reg 			match_valid			//匹配成功标志
);

localparam CHAR_NUM  = 34;	//英文+数字  总数
localparam ENG_NUM 	 = 24;	//英文总数
localparam CHINA_NUM = 31;	//汉字总数


wire [4:0] CHAR  [33:0] [7:0]; //A至Z  0至9，除去英文O和英文I，共计34个字符（不包含汉字）；每个字符8行，每行由5个点组成
wire [4:0] CHINA [30:0] [7:0]; //中文字符，各省市的中文


reg [3:0] step;

reg [7:0] china_match_cnt;  //中文对比数目
reg [7:0] char_match_cnt ;   //英文对比数目

reg [2:0] plate_char_cnt;	//对匹配的字符计数
reg [2:0] plate_line_cnt;	//对字符中的行计数
reg [2:0] plate_bit_cnt	;	//对行中的bit位计数

reg [7:0] match_score	 ;	//匹配得分
reg [7:0] match_score_max;  //寄存最高得分
reg [7:0] score_max_index;	//最高得分所对应的索引

reg [4:0] compare_char [7:0];	//用于寄存比较对象: 车牌的字符
reg [4:0] compare_temp [7:0];	//用于寄存比较对象，字符模板

integer i; 
 
always @(posedge clk or negedge rst_n)begin
    if(!rst_n) begin
        step            <=  4'd0;
		
        plate_char_cnt  <=  3'd0;
        plate_line_cnt  <=  3'd0;
        plate_bit_cnt	<=  3'd0;
		
		china_match_cnt	<=  8'd0;
		char_match_cnt 	<=  8'd0;
		
		match_score	 	<=  8'd0;
		match_score_max <=  8'd0;
		score_max_index <= 	8'd0;
		
		match_valid		<= 	1'b0;
    end
    else begin
        case (step)
        
            4'd0 : begin
				plate_char_cnt  <=  3'd0;
				plate_line_cnt  <=  3'd0;
				plate_bit_cnt	<=  3'd0;
				
				china_match_cnt	<=  8'd0;
				char_match_cnt 	<=  8'd0;
				
				match_score	 	<=  8'd0;
				match_score_max <=  8'd0;
				score_max_index <= 	8'd0;
				
				match_valid		<= 	1'b0;
				
                if(char_feature_valid)      	//特征值有效时，启动识别过程
                    step	<= 4'd1;
                else
                    step	<= step;
            end
			
            4'd1 : begin
				china_match_cnt	<= 	8'd0;
				char_match_cnt 	<=  8'd0;
				match_score_max <=	8'd0;
				score_max_index <= 	8'd0;
			
                case (plate_char_cnt)  
				
                    3'd0 : begin                     //中文字符，各省市的中文
                        step  <= 4'd2; 
						for(i=0;i<8;i++)			
							compare_char[i] <= char_feature[0][i];				//寄存用于比较的车牌字符（汉字）
					end

                    3'd2 :	begin					//点
                        step  <= 4'd1;           
						plate_char_cnt <= plate_char_cnt + 1'b1;
					end
					
                    default: begin					//英文字母或者数字 
                        step  <= 4'd6;           
						for(i=0;i<8;i++)
							compare_char[i] <= char_feature[plate_char_cnt][i];//寄存用于比较的车牌字符
					end
                endcase
            end
			
			//——————————————————————————————————————————————————————————————————————————————————
			//进行汉字的匹配过程
			
            4'd2 : begin		
				for(i=0;i<8;i++)					//寄存用于比较的汉字模板
					compare_temp[i] <= CHINA[china_match_cnt][i];
					
				match_score	 	<=	8'd128;			//匹配得分初始化为中间值128
				
				plate_line_cnt  <=  3'd0;
				plate_bit_cnt	<=  3'd0;
				
				step  			<= 	4'd3;
            end
			
            4'd3 : begin							//遍历40个特征值，进行匹配
				
				if(compare_char[plate_line_cnt][plate_bit_cnt]==compare_temp[plate_line_cnt][plate_bit_cnt])
					match_score <= match_score + 1'b1;	//每个bit匹配成功，则得分加1
				else
					match_score <= match_score - 1'b1;	//每个bit匹配不成功，则得分减1
					
				if(plate_bit_cnt < 3'd4)
					plate_bit_cnt <= plate_bit_cnt + 1'b1;
				else begin
					plate_bit_cnt <= 3'd0;
					
					if(plate_line_cnt < 3'd7)
						plate_line_cnt <= plate_line_cnt + 1'b1;
					else
						step <= 4'd4;					//字符匹配过程结束 
				end
            end
			
            4'd4 : begin								//求出匹配结果的最大值
				if(match_score > match_score_max) begin
					match_score_max <= match_score;
					score_max_index <= china_match_cnt;
				end
				
				if(china_match_cnt < CHINA_NUM -1) begin //进行下一个字符模板的比较
					china_match_cnt <= china_match_cnt + 1'b1;
					step <= 4'd2;					
				end
				else 
					step <= 4'd5;
            end
            4'd5 : begin								//寄存汉字匹配结果的最大值			
				char_index[0] 	<= score_max_index;
				plate_char_cnt	<= plate_char_cnt + 1'b1;
				step <= 4'd1;
            end
			
			//——————————————————————————————————————————————————————————————————————————————————
			//进行英文/数字的匹配过程

            4'd6 : begin		
				for(i=0;i<8;i++)					//寄存用于比较的汉字模板
					compare_temp[i] <= CHAR[char_match_cnt][i];
					
				match_score	 	<=	8'd128;			//匹配得分初始化为中间值128
				
				plate_line_cnt  <=  3'd0;
				plate_bit_cnt	<=  3'd0;
				
				step  			<= 	4'd7;
            end

            4'd7 : begin							//遍历40个特征值，进行匹配
				
				if(compare_char[plate_line_cnt][plate_bit_cnt]==compare_temp[plate_line_cnt][plate_bit_cnt])
					match_score <= match_score + 1'b1;	//每个bit匹配成功，则得分加1
				else
					match_score <= match_score - 1'b1;	//每个bit匹配不成功，则得分减1
					
				if(plate_bit_cnt < 3'd4)
					plate_bit_cnt <= plate_bit_cnt + 1'b1;
				else begin
					plate_bit_cnt <= 3'd0;
					
					if(plate_line_cnt < 3'd7)
						plate_line_cnt <= plate_line_cnt + 1'b1;
					else
						step <= 4'd8;					//字符匹配过程结束 
				end
            end
			
            4'd8 : begin								//求出匹配结果的最大值
				if(match_score >= match_score_max) begin
					match_score_max <= match_score;
					score_max_index <= char_match_cnt;
				end
				
				if((plate_char_cnt == 3'd1)&&(char_match_cnt == ENG_NUM -1))		//车牌第二个字符为英文，不为数字 
					step <= 4'd9;
				else if((plate_char_cnt > 3'd2)&&(char_match_cnt == CHAR_NUM -1))//后面的字符可能为英文/数字 
					step <= 4'd9;
				else begin 												
					char_match_cnt <= char_match_cnt + 1'b1;				//进行下一个字符模板的比较
					step <= 4'd6;					
				end
            end
            4'd9 : begin								//寄存英文字母匹配结果的最大值			
				char_index[plate_char_cnt] 	<= score_max_index;
				if(plate_char_cnt < 3'd7) begin
					plate_char_cnt 	<= plate_char_cnt + 1'b1;
					step <= 4'd1;
				end
				else begin
					step <= 4'd10;						//所有车牌字符识别完毕
				end
            end
			
            4'd10 : begin
				match_valid	<=	1'b1;					//输出识别结果有效标志，拉高一个时钟周期
				step 		<=  4'd0;
            end
        
        endcase
    
    end

end

//字母 A
assign CHAR[0] = {
	5'b00100,
	5'b01110,
	5'b01110,
	5'b01110,
	5'b01010,
	5'b01011,
	5'b11111,
	5'b10001
};

//字母 B
assign CHAR[1] = {
	5'b11110,
	5'b10001,
	5'b10010,
	5'b11110,
	5'b10011,
	5'b10001,
	5'b10010,
	5'b11110
};

//字母 C
assign CHAR[2] = {
	5'b01111,
	5'b10001,
	5'b10000,
	5'b10000,
	5'b10000,
	5'b10001,
	5'b10001,
	5'b01110
};

//字母 D
assign CHAR[3] = {
	5'b11110,
	5'b10010,
	5'b10001,
	5'b10001,
	5'b10001,
	5'b10001,
	5'b10001,
	5'b11110
};

//字母 E
assign CHAR[4] = {
	5'b11111,
	5'b10000,
	5'b10000,
	5'b11110,
	5'b10000,
	5'b10000,
	5'b10000,
	5'b11111
};

//字母 F
assign CHAR[5] = {
	5'b11111,
	5'b11000,
	5'b10000,
	5'b11000,
	5'b11110,
	5'b10000,
	5'b10000,
	5'b10000
};

//字母 G
assign CHAR[6] = {
	5'b01110,
	5'b10001,
	5'b10000,
	5'b10111,
	5'b10001,
	5'b10001,
	5'b11011,
	5'b01110
};

//字母 H
assign CHAR[7] = {
	5'b10001,
	5'b10001,
	5'b10001,
	5'b10011,
	5'b11111,
	5'b10001,
	5'b10001,
	5'b10001
};

//字母 J
assign CHAR[8] = {
	5'b00001,
	5'b00001,
	5'b00001,
	5'b00001,
	5'b00001,
	5'b00001,
	5'b10001,
	5'b01110
};

//字母 K
assign CHAR[9] = {
	5'b10001,
	5'b10010,
	5'b10110,
	5'b11110,
	5'b11010,
	5'b10010,
	5'b10001,
	5'b10001
};

//字母 L
assign CHAR[10] = {
	5'b10000,
	5'b10000,
	5'b10000,
	5'b10000,
	5'b10000,
	5'b10000,
	5'b10000,
	5'b11111
};

//字母 M
assign CHAR[11] = {
	5'b11011,
	5'b11111,
	5'b11111,
	5'b10001,
	5'b10001,
	5'b10001,
	5'b10001,
	5'b10001
};

//字母 N
assign CHAR[12] = {
	5'b11001,
	5'b11001,
	5'b11001,
	5'b10101,
	5'b10101,
	5'b10011,
	5'b10011,
	5'b10001
};

//字母 P
assign CHAR[13] = {
	5'b11110,
	5'b10001,
	5'b10001,
	5'b11011,
	5'b11110,
	5'b10000,
	5'b10000,
	5'b10000
};

//字母 Q
assign CHAR[14] = {
	5'b01110,
	5'b10001,
	5'b10001,
	5'b10001,
	5'b10001,
	5'b10101,
	5'b10011,
	5'b01111
};

//字母 R
assign CHAR[15] = {
	5'b11110,
	5'b10001,
	5'b10001,
	5'b11111,
	5'b11110,
	5'b10010,
	5'b10011,
	5'b10001
};

//字母 S
assign CHAR[16] = {
	5'b01110,
	5'b10001,
	5'b10000,
	5'b01110,
	5'b00011,
	5'b00001,
	5'b10011,
	5'b01110
};

//字母 T
assign CHAR[17] = {
	5'b11111,
	5'b00100,
	5'b00100,
	5'b00100,
	5'b00100,
	5'b00100,
	5'b00100,
	5'b00100
};

//字母 U
assign CHAR[18] = {
	5'b10001,
	5'b10001,
	5'b10001,
	5'b10001,
	5'b10001,
	5'b10001,
	5'b10001,
	5'b01110
};

//字母 V
assign CHAR[19] = {
	5'b10001,
	5'b11001,
	5'b01011,
	5'b01010,
	5'b01110,
	5'b01110,
	5'b00110,
	5'b00100
};

//字母 W
assign CHAR[20] = {
	5'b10001,
	5'b10001,
	5'b10101,
	5'b11111,
	5'b11111,
	5'b01011,
	5'b01011,
	5'b01001
};

//字母 X
assign CHAR[21] = {
	5'b11001,
	5'b01010,
	5'b01110,
	5'b00100,
	5'b00110,
	5'b01110,
	5'b01011,
	5'b10001
};

//字母 Y
assign CHAR[22] = {
	5'b11011,
	5'b01010,
	5'b00110,
	5'b00100,
	5'b00100,
	5'b00100,
	5'b00100,
	5'b00100
};

//字母 Z
assign CHAR[23] = {
	5'b11111,
	5'b00010,
	5'b00010,
	5'b00100,
	5'b00100,
	5'b01000,
	5'b01000,
	5'b11110
};

//数字 0
assign CHAR[24] = {
	5'b01110,
	5'b10001,
	5'b10001,
	5'b10001,
	5'b10001,
	5'b10001,
	5'b10001,
	5'b01110
};

//数字 1
assign CHAR[25] = {
	5'b01110,
	5'b01110,
	5'b01110,
	5'b01110,
	5'b01110,
	5'b01110,
	5'b01110,
	5'b01110
};

//数字 2
assign CHAR[26] = {
	5'b01110,
	5'b11011,
	5'b00011,
	5'b00010,
	5'b00100,
	5'b01100,
	5'b01000,
	5'b11111
};

//数字 3
assign CHAR[27] = {
	5'b11111,
	5'b00010,
	5'b00100,
	5'b00110,
	5'b00001,
	5'b00001,
	5'b10001,
	5'b01110
};

//数字 4
assign CHAR[28] = {
	5'b00010,
	5'b00110,
	5'b00110,
	5'b01010,
	5'b01010,
	5'b11010,
	5'b11111,
	5'b00010
};

//数字 5
assign CHAR[29] = {
	5'b11111,
	5'b10000,
	5'b10000,
	5'b11110,
	5'b00001,
	5'b00001,
	5'b10001,
	5'b01110
};

//数字 6
assign CHAR[30] = {
	5'b00010,
	5'b00100,
	5'b01000,
	5'b01000,
	5'b11111,
	5'b10001,
	5'b11001,
	5'b01110
};

//数字 7
assign CHAR[31] = {
	5'b11111,
	5'b00011,
	5'b00010,
	5'b00010,
	5'b00100,
	5'b00100,
	5'b00100,
	5'b00100
};

//数字 8
assign CHAR[32] = {
	5'b01111,
	5'b11001,
	5'b11001,
	5'b01110,
	5'b11011,
	5'b10001,
	5'b10001,
	5'b01110
};

//数字 9
assign CHAR[33] = {
	5'b01111,
	5'b10001,
	5'b10001,
	5'b01111,
	5'b00011,
	5'b00010,
	5'b00100,
	5'b01000
};

//————————————————————————————————————————————————————————


//————————————————————————————————————————————————————————


//汉字 京
assign CHINA[0] = {
	5'b00000,
	5'b00001,
	5'b01000,
	5'b00000,
	5'b01110,
	5'b00100,
	5'b00101,
	5'b00100
};

//汉字 鄂
assign CHINA[1] = {
	5'b10011,
	5'b10000,
	5'b00011,
	5'b00010,
	5'b01010,
	5'b00100,
	5'b00101,
	5'b00000
};

//汉字 皖
assign CHINA[2] = {
	5'b00010,
	5'b11110,
	5'b11110,
	5'b11110,
	5'b11110,
	5'b11010,
	5'b11010,
	5'b00111
};

//汉字 沪
assign CHINA[3] = {
	5'b00000,
	5'b00000,
	5'b00101,
	5'b00101,
	5'b00111,
	5'b10100,
	5'b10100,
	5'b00000
};

//汉字 苏
assign CHINA[4] = {
	5'b01010,
	5'b01111,
	5'b00000,
	5'b01110,
	5'b00110,
	5'b10011,
	5'b01010,
	5'b00010
};

//汉字 蒙
assign CHINA[5] = {
	5'b00000,
	5'b01110,
	5'b10111,
	5'b00100,
	5'b01100,
	5'b00110,
	5'b00010,
	5'b00000
};

//汉字 湘
assign CHINA[6] = {
	5'b00000,
	5'b00111,
	5'b00111,
	5'b00110,
	5'b00111,
	5'b01111,
	5'b00111,
	5'b00101
};

//汉字 浙
assign CHINA[7] = {
	5'b00010,
	5'b00000,
	5'b01010,
	5'b00000,
	5'b01000,
	5'b00010,
	5'b00000,
	5'b00000
};

//汉字 鲁
assign CHINA[8] = {
	5'b00000,
	5'b11110,
	5'b00111,
	5'b00101,
	5'b00000,
	5'b00000,
	5'b01001,
	5'b01001
};

//汉字 粤
assign CHINA[9] = {
	5'b11111,
	5'b11111,
	5'b11111,
	5'b11111,
	5'b11111,
	5'b11111,
	5'b01111,
	5'b00110
};

//汉字 豫
assign CHINA[10] = {
	5'b00000,
	5'b01110,
	5'b11111,
	5'b11110,
	5'b00110,
	5'b00110,
	5'b10111,
	5'b00000
};

//汉字 M
assign CHINA[11] = {
	5'b00000,
	5'b00000,
	5'b00000,
	5'b00000,
	5'b00000,
	5'b00000,
	5'b00000,
	5'b00000
};

//汉字 N
assign CHINA[12] = {
	5'b00000,
	5'b00000,
	5'b00000,
	5'b00000,
	5'b00000,
	5'b00000,
	5'b00000,
	5'b00000
};

//汉字 P
assign CHINA[13] = {
	5'b00000,
	5'b00000,
	5'b00000,
	5'b00000,
	5'b00000,
	5'b00000,
	5'b00000,
	5'b00000
};

//汉字 Q
assign CHINA[14] = {
	5'b00000,
	5'b00000,
	5'b00000,
	5'b00000,
	5'b00000,
	5'b00000,
	5'b00000,
	5'b00000
};

//汉字 R
assign CHINA[15] = {
	5'b00000,
	5'b00000,
	5'b00000,
	5'b00000,
	5'b00000,
	5'b00000,
	5'b00000,
	5'b00000
};

//汉字 S
assign CHINA[16] = {
	5'b00000,
	5'b00000,
	5'b00000,
	5'b00000,
	5'b00000,
	5'b00000,
	5'b00000,
	5'b00000
};

//汉字 T
assign CHINA[17] = {
	5'b00000,
	5'b00000,
	5'b00000,
	5'b00000,
	5'b00000,
	5'b00000,
	5'b00000,
	5'b00000
};

//汉字 U
assign CHINA[18] = {
	5'b00000,
	5'b00000,
	5'b00000,
	5'b00000,
	5'b00000,
	5'b00000,
	5'b00000,
	5'b00000
};

//汉字 V
assign CHINA[19] = {
	5'b00000,
	5'b00000,
	5'b00000,
	5'b00000,
	5'b00000,
	5'b00000,
	5'b00000,
	5'b00000
};

//汉字 W
assign CHINA[20] = {
	5'b00000,
	5'b00000,
	5'b00000,
	5'b00000,
	5'b00000,
	5'b00000,
	5'b00000,
	5'b00000
};

//汉字 X
assign CHINA[21] = {
	5'b00000,
	5'b00000,
	5'b00000,
	5'b00000,
	5'b00000,
	5'b00000,
	5'b00000,
	5'b00000
};

//汉字 Y
assign CHINA[22] = {
	5'b00000,
	5'b00000,
	5'b00000,
	5'b00000,
	5'b00000,
	5'b00000,
	5'b00000,
	5'b00000
};

//汉字 Z
assign CHINA[23] = {
	5'b00000,
	5'b00000,
	5'b00000,
	5'b00000,
	5'b00000,
	5'b00000,
	5'b00000,
	5'b00000
};

//汉字 0
assign CHINA[24] = {
	5'b00000,
	5'b00000,
	5'b00000,
	5'b00000,
	5'b00000,
	5'b00000,
	5'b00000,
	5'b00000
};

//汉字 1
assign CHINA[25] = {
	5'b00000,
	5'b00000,
	5'b00000,
	5'b00000,
	5'b00000,
	5'b00000,
	5'b00000,
	5'b00000
};

//汉字 2
assign CHINA[26] = {
	5'b00000,
	5'b00000,
	5'b00000,
	5'b00000,
	5'b00000,
	5'b00000,
	5'b00000,
	5'b00000
};

//汉字 3
assign CHINA[27] = {
	5'b00000,
	5'b00000,
	5'b00000,
	5'b00000,
	5'b00000,
	5'b00000,
	5'b00000,
	5'b00000
};

//汉字 4
assign CHINA[28] = {
	5'b00000,
	5'b00000,
	5'b00000,
	5'b00000,
	5'b00000,
	5'b00000,
	5'b00000,
	5'b00000
};

//汉字 5
assign CHINA[29] = {
	5'b00000,
	5'b00000,
	5'b00000,
	5'b00000,
	5'b00000,
	5'b00000,
	5'b00000,
	5'b00000
};

//汉字 6
assign CHINA[30] = {
	5'b00000,
	5'b00000,
	5'b00000,
	5'b00000,
	5'b00000,
	5'b00000,
	5'b00000,
	5'b00000
};

endmodule