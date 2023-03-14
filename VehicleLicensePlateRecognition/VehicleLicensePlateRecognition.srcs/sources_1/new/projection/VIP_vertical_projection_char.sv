`timescale 1ns/1ns
module VIP_vertical_projection_char
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
	output				post_frame_vsync,	//Processed Image data vsync valid signal
	output				post_frame_href,	//Processed Image data href vaild  signal
	output				post_frame_clken,	//Processed Image data output/capture enable clock
	output				post_img_Bit, 		//Processed Image Bit flag outout(1: Value, 0:inValid)

	output reg [20:0] 	char_boarder[7:0],  //{valid_flag[0],left_boarder[9:0],right_boarder[9:0]}
	
    input      [9:0] 	vertical_start,		//投影起�?��??
    input      [9:0] 	vertical_end,		//投影结束�?	

    input       [9:0] 	plate_boarder_left 	,
    input       [9:0] 	plate_boarder_right	 	
);

reg [9:0] 	max_line_left ;		//边沿坐标
reg [9:0] 	max_line_right;

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
//对输入的像素进�?�“�??/场”方向�?�数，得到其纵横坐标
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
//寄存“�??/场”方向�?�数
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
//竖直方向投影
reg  		ram_wr;
wire [9:0] 	ram_wr_data;
wire [9:0] 	ram_rd_data;

always @ (posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        ram_wr <= 1'b0;
    end
    else if(per_frame_clken)
        ram_wr <= 1'b1;
    else
        ram_wr <= 1'b0;
end

//对整帧进行投�?
// assign ram_wr_data = (y_cnt == 10'd0) ? 10'd0 : 					//�?一行，初�?�化RAM�?0
//                         per_img_Bit_r ? ram_rd_data + 1'b1 :
//                             ram_rd_data;

//在指定的行数之间进�?�投�?

assign ram_wr_data = (y_cnt == 10'd0) ? 10'd0 : 					//�?一行，初�?�化RAM�?0
                        ((y_cnt > vertical_start) && (y_cnt < vertical_end)) ? (ram_rd_data + per_img_Bit_r) :  
                            ram_rd_data;


dual_port_ram #(
    .RAM_WIDTH  (10            ),
    .ADDR_LINE  (10            )
)u_dual_port_ram(
    .clk        (clk 			),
    .wr_en      (ram_wr 		),
    .wr_addr    (x_cnt_r 		),
    .wr_data    (ram_wr_data 	),

    .rd_addr    (x_cnt 			),
    .rd_data    (ram_rd_data 	)
);

// blk_mem_gen_0 u_projection_ram (
//   .clka		(clk 			),  // input wire clka
//   .wea		(ram_wr 		),  // input wire [0 : 0] wea
//   .addra	(x_cnt_r 		),  // input wire [9 : 0] addra
//   .dina		(ram_wr_data 	),  // input wire [9 : 0] dina
//   .clkb		(clk 			),  // input wire clkb
//   .addrb	(x_cnt 			),  // input wire [9 : 0] addrb
//   .doutb	(ram_rd_data 	)  	// output wire [9 : 0] doutb
// );

// ram u_projection_ram (
//   .clka		(clk 			),  // input wire clka
//   .wea		(ram_wr 		),  // input wire [0 : 0] wea
//   .addra	(x_cnt_r 		),  // input wire [9 : 0] addra
//   .dina		(ram_wr_data 	),  // input wire [9 : 0] dina

//   .clkb		(clk 			),  // input wire clkb
//   .addrb	(x_cnt 			),  // input wire [9 : 0] addrb
//   .doutb	(ram_rd_data 	)  	// output wire [9 : 0] doutb
// );
	
reg [9:0] rd_data_d1;
reg [9:0] rd_data_d2;
reg [9:0] rd_data_d3;

always @ (posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        rd_data_d1 <= 10'd0;
        rd_data_d2 <= 10'd0;
    end
    else if(per_frame_clken) begin
        rd_data_d1 <= ram_rd_data;
        rd_data_d2 <= rd_data_d1;
        rd_data_d3 <= rd_data_d2;
	end
end

//计算车牌宽度
wire [9:0] plate_width;
assign plate_width = plate_boarder_right - plate_boarder_left;


reg [2:0] char_cnt	;
reg [20:0] char_boarder_reg[7:0];

integer i;

//根据RAM�?统�?�的投影结果，判�?字�?�边�?
always @ (posedge clk or negedge rst_n) begin
    if(!rst_n) begin
		char_cnt <= 3'd0;
		
		for(i=0;i<8; i++) begin
			char_boarder_reg[i] <= 31'd0;	//初�?�化输出列表	
		end
		
    end
    else if(per_frame_clken) begin

        if(y_cnt == IMG_VDISP - 1'b1) begin    
		
			if((rd_data_d1 == 10'd0) && (ram_rd_data > 10'd0)) begin //上升�?
				
				if(char_cnt == 3'd1) begin										//对待汉字进�?�特殊判�?
					if(x_cnt_r - char_boarder_reg[0][19:10] < plate_width[9:3])	//�?二个上升沿小于汉字�?�度（大致等于车牌尺寸的1/8），则�?�定为左右结构的汉字
						char_cnt <= 3'd0;   									//此时忽略�?二个上升沿，同时将�?�数器置0，这样可以在�?二个下降沿到达时，重新更新汉字的右边�?
					else
						char_boarder_reg[char_cnt][19:10] <= x_cnt_r - 1;		//左边�?
				end 

				else begin
					char_boarder_reg[char_cnt][19:10] <= x_cnt_r - 1;			//左边�?
				end
			end	
			
			if((rd_data_d1 > 10'd0) && (ram_rd_data == 10'd0)) begin //下降�?

				char_boarder_reg[char_cnt][9:0] <= x_cnt_r;						//右边�?
				char_boarder_reg[char_cnt][20]  <= 1'b1;						//有效标志�?
			
				if(char_cnt != 3'd2) begin										//对字符的宽度进�?�判�?，�?�果小于一定的数值，则�?�为�?车牌上的污点
					if(x_cnt_r - char_boarder_reg[char_cnt][19:10] < 3)
						char_cnt <= char_cnt;									//重新等待新的上升�?/下降�?
					else 
						char_cnt <= char_cnt + 1'b1;
				end
				else
					char_cnt <= char_cnt + 1'b1;
			end		
        end
	end
	else if(vsync_pos_flag) begin
		for(i=0;i<8; i++) begin
			char_boarder_reg[i] <= 31'd0;	//初�?�化输出列表	
		end
		
		char_cnt <= 3'd0;
	end
end

//寄存输出结果
integer j;

always @ (posedge clk or negedge rst_n) begin
    if(!rst_n) begin
		for(j=0;j<8; j++) begin
			char_boarder[j] <= 31'd0;	//初�?�化输出列表	
		end
    end
    else if(vsync_neg_flag) begin
		for(j=0;j<8; j++) begin
			char_boarder[j] <= char_boarder_reg[j];	//初�?�化输出列表	
		end
    end   
end

endmodule
