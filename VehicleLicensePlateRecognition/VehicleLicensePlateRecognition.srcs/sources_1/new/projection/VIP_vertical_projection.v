`timescale 1ns/1ns
module VIP_vertical_projection
#(
	parameter	[9:0]	IMG_HDISP = 10'd640,	//640*480
	parameter	[9:0]	IMG_VDISP = 10'd480,
	
	parameter   [9:0]   EDGE_THROD = 10'd50
	
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

    output reg [9:0] 	max_line_left ,		//鏉堣�勯儴閸ф劖鐖�
    output reg [9:0] 	max_line_right,
	
    input      [9:0] 	vertical_start,		//閹舵洖濂栫挧宄帮拷瀣�锟斤拷
    input      [9:0] 	vertical_end		//閹舵洖濂栫紒鎾存将鐞涳拷	     
);

reg [9:0] 	max_pixel_left ;
reg [9:0] 	max_pixel_right;

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
//鐎电�呯翻閸忋儳娈戦崓蹇曠�屾潻娑滐拷灞糕偓婊嗭拷锟�/閸﹁　鈧�婵囨煙閸氭垼锟解剝鏆熼敍灞界繁閸掓澘鍙剧痪鍨�铆閸ф劖鐖�
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
//鐎靛嫬鐡ㄩ垾婊嗭拷锟�/閸﹁　鈧�婵囨煙閸氭垼锟解剝鏆�
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
//缁旀牜娲块弬鐟版倻閹舵洖濂�
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

//鐎佃�勬殻鐢�褑绻樼悰灞惧�囪ぐ锟�
// assign ram_wr_data = (y_cnt == 10'd0) ? 10'd0 : 					//缁楋拷娑撯偓鐞涘矉绱濋崚婵嗭拷瀣�瀵睷AM娑擄拷0
//                         per_img_Bit_r ? ram_rd_data + 1'b1 :
//                             ram_rd_data;

//閸︺劍瀵氱€规氨娈戠悰灞炬殶娑斿��妫挎潻娑滐拷灞惧�囪ぐ锟�

assign ram_wr_data = (y_cnt == 10'd0) ? 10'd0 : 					//缁楋拷娑撯偓鐞涘矉绱濋崚婵嗭拷瀣�瀵睷AM娑擄拷0
                        ((y_cnt > vertical_start) && (y_cnt < vertical_end)) ? (ram_rd_data + per_img_Bit_r) :  
                            ram_rd_data;

// ram	u_projection_ram (
// 	.wrclock 	( clk 			),
// 	.wren 		( ram_wr 		),
// 	.wraddress 	( x_cnt_r 		),
// 	.data 		( ram_wr_data 	),
	
// 	.rdclock 	( clk 			),
// 	.rdaddress 	( x_cnt 		),
// 	.q 			( ram_rd_data 	)
// 	);

// blk_mem_gen_0 u_projection_ram (
//   .clka		(clk 			),  // input wire clka
//   .wea		(ram_wr 		),  // input wire [0 : 0] wea
//   .addra	    (x_cnt_r 		),  // input wire [9 : 0] addra
//   .dina		(ram_wr_data 	),  // input wire [9 : 0] dina
//   .clkb		(clk 			),  // input wire clkb
//   .addrb	    (x_cnt 			),  // input wire [9 : 0] addrb
//   .doutb	    (ram_rd_data 	)  	// output wire [9 : 0] doutb
// );


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

	
reg [9:0] rd_data_d1;
reg [9:0] rd_data_d2;

always @ (posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        rd_data_d1 <= 10'd0;
        rd_data_d2 <= 10'd0;
    end
    else if(per_frame_clken) begin
        rd_data_d1 <= ram_rd_data;
        rd_data_d2 <= rd_data_d1;
	end
end

reg [9:0] max_num1  ;
reg [9:0] max_x1    ;
reg [9:0] max_num2  ;
reg [9:0] max_x2    ;

reg rise_flag;	//閺嶅洤绻旈惈鈧�閹舵洖濂栭惃鍕�锟斤拷娑撯偓娑擄拷娑撳﹤宕屽▽鎸庢Ц閸氾箑鍤�閻滐拷

always @ (posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        max_num1 	<= 10'd0;
        max_x1   	<= 10'd0;
        max_num2 	<= 10'd0;
        max_x2   	<= 10'd0;
			
		rise_flag	<= 1'b0;
    end
    else if(per_frame_clken) begin

        if(y_cnt == IMG_VDISP - 1'b1) begin 

			if((rise_flag == 1'b0) && (ram_rd_data > rd_data_d2 + EDGE_THROD)) begin	//缁楋拷娑撯偓娑擄拷娑撳﹤宕屽▽锟�
			    max_x1		<= x_cnt_r;
				max_num1	<= ram_rd_data;
				rise_flag 	<= 1'b1;
			end	
			
			if(rd_data_d2 > ram_rd_data + EDGE_THROD) begin	//娑撳��妾峰▽澶哥瑝閺傦拷鏉╋拷娴狅綇绱濋惄鏉戝煂閺堚偓閸氬簼绔存稉锟芥稉瀣�妾峰▽锟�
			    max_x2   	<= x_cnt_r-5;
				max_num2  	<= rd_data_d2;
			end		
        end
	end
	else if(vsync_pos_flag) begin
		max_num1 	<= 10'd0;
		max_x1   	<= 10'd0;
		max_num2 	<= 10'd0;
		max_x2   	<= 10'd0;
		
		rise_flag	<= 1'b0;
	end
end

always @ (posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        max_line_left  <= 10'd0;
        max_line_right <= 10'd0;
        max_pixel_left  <= 10'd0;
        max_pixel_right <= 10'd0;
    end
    else if(vsync_neg_flag) begin
		max_line_left   <= max_x1;
		max_pixel_left  <= max_num1;
		
		max_line_right  <= max_x2;
		max_pixel_right <= max_num2;
    end   
end

/*
reg [9:0] max_num1  ;
reg [9:0] max_x1    ;
reg [9:0] max_num2  ;
reg [9:0] max_x2    ;

always @ (posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        max_num1 <= 10'd0;
        max_x1   <= 10'd0;
        max_num2 <= 10'd0;
        max_x2   <= 10'd0;
    end
    else if(per_frame_clken) begin

        if(y_cnt == IMG_VDISP - 1'b1) begin    
            if(ram_rd_data >= max_num1) begin
                max_num1 <= ram_rd_data;
                max_x1   <= x_cnt_r;
                
                if(x_cnt_r - 3 > max_x1 ) begin  //閹烘帡娅庨惄鎼佸仸閸戠姳閲滈弸浣搞亣閸婏拷
                    max_num2 <= max_num1;
                    max_x2   <= max_x1;
                end
                
            end
            else if(ram_rd_data > max_num2) begin
            
                if(x_cnt_r - 3 > max_x1) begin
                    max_num2 <= ram_rd_data;
                    max_x2   <= x_cnt_r;
                end
            end
        end
        else begin
            max_num1 <= 10'd0;
            max_x1   <= 10'd0;
            max_num2 <= 10'd0;
            max_x2   <= 10'd0;
        end
        
    end
end

always @ (posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        max_line_left  <= 10'd0;
        max_line_right <= 10'd0;
        max_pixel_left  <= 10'd0;
        max_pixel_right <= 10'd0;
    end
    else if((y_cnt == IMG_VDISP) && vsync_neg_flag) begin
            if(max_x1 > max_x2) begin
                max_line_left   <= max_x2;
                max_pixel_left  <= max_num2;
                
                max_line_right  <= max_x1;
                max_pixel_right <= max_num1;
            end
            else begin 
                max_line_left   <= max_x1;
                max_pixel_left  <= max_num1;
                
                max_line_right  <= max_x2;
                max_pixel_right <= max_num2;
            end
    end   
end
*/
endmodule
