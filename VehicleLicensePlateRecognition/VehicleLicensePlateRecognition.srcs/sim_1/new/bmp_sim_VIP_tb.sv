`timescale 1ns / 1ns

//使用BMP图片格式仿真VIP视频图像处理算法
module bmp_sim_VIP_tb();
 
integer iBmpFileId;                 //输入BMP图片

integer oBmpFileId_1;                 //输出BMP图片 1
integer oBmpFileId_2;                 //输出BMP图片 2
integer oBmpFileId_3;                 //输出BMP图片 3
integer oBmpFileId_4;                 //输出BMP图片 3

integer oTxtFileId;                 //输入TXT文本
        
integer iIndex = 0;                 //输出BMP数据索引
integer pixel_index = 0;            //输出像素数据索引 
        
integer iCode;      
        
integer iBmpWidth;                  //输入BMP 宽度
integer iBmpHight;                  //输入BMP 高度
integer iBmpSize;                   //输入BMP 字节数
integer iDataStartIndex;            //输入BMP 像素数据偏移量
    
reg [ 7:0] rBmpData [0:2000000];    //用于寄存输入BMP图片中的字节数据（包括54字节的文件头）

reg [ 7:0] Vip_BmpData_1 [0:2000000]; //用于寄存视频图像处理之后 的BMP图片 数据  
reg [ 7:0] Vip_BmpData_2 [0:2000000]; //用于寄存视频图像处理之后 的BMP图片 数据 
reg [ 7:0] Vip_BmpData_3 [0:2000000]; //用于寄存视频图像处理之后 的BMP图片 数据 
reg [ 7:0] Vip_BmpData_4 [0:2000000]; //用于寄存视频图像处理之后 的BMP图片 数据 

reg [31:0] rBmpWord;                //输出BMP图片时用于寄存数据（以word为单位，即4byte）

reg [ 7:0] pixel_data;              //输出视频流时的像素数据

reg clk;
reg rst_n;

//reg [ 7:0] vip_pixel_data [0:230400];   	//320x240x3
reg [ 7:0] vip_pixel_data_1 [0:921600];   	//640x480x3
reg [ 7:0] vip_pixel_data_2 [0:921600];   	//640x480x3
reg [ 7:0] vip_pixel_data_3 [0:921600];   	//640x480x3
reg [ 7:0] vip_pixel_data   [0:921600];     //640x480x3

integer i;
integer j;
wire [0:4] 	char_feature  [7:0] [7:0] ;		//特征结果

`define QuestaSim

`ifndef QuestaSim
//---------------------------------------------
initial begin
	iBmpFileId	= 	$fopen("../../../../../pic/PIC/21_Su_A65NF7/21_Su_A65NF7.bmp","rb");

//将输入BMP图片加载到数组中 21_Su_A65NF7
	iCode = $fread(rBmpData,iBmpFileId);
 
    //根据BMP图片文件头的格式，分别计算出图片的 宽度 /高度 /像素数据偏移量 /图片字节数
	iBmpWidth       = {rBmpData[21],rBmpData[20],rBmpData[19],rBmpData[18]};
	iBmpHight       = {rBmpData[25],rBmpData[24],rBmpData[23],rBmpData[22]};
	iBmpSize        = {rBmpData[ 5],rBmpData[ 4],rBmpData[ 3],rBmpData[ 2]};
	iDataStartIndex = {rBmpData[13],rBmpData[12],rBmpData[11],rBmpData[10]};
    
    //关闭输入BMP图片
	$fclose(iBmpFileId);
        
    //延迟13ms，等待第一帧VIP处理结束
    #13000000    
	
    //加载图像处理后，BMP图片的文件头和像素数据

//---------------------------------------------		
	oBmpFileId_1 	= 	$fopen("../../../../../pic/PIC/21_Su_A65NF7/output_file_1.bmp","wb+");
	//输出第一张
	for (iIndex = 0; iIndex < iBmpSize; iIndex = iIndex + 1) begin
		if(iIndex < 54)
            Vip_BmpData_1[iIndex] = rBmpData[iIndex];
        else
            Vip_BmpData_1[iIndex] = vip_pixel_data_1[iIndex-54];
	end
    //将数组中的数据写到输出BMP图片中    
	for (iIndex = 0; iIndex < iBmpSize; iIndex = iIndex + 1) begin
		rBmpWord = Vip_BmpData_1[iIndex];
		$fwrite(oBmpFileId_1,"%c",rBmpWord);
	end
	$fclose(oBmpFileId_1);

//---------------------------------------------		
	oBmpFileId_2 	= 	$fopen("../../../../../pic/PIC/21_Su_A65NF7/output_file_2.bmp","wb+");
	//输出第二张
	for (iIndex = 0; iIndex < iBmpSize; iIndex = iIndex + 1) begin
		if(iIndex < 54)
            Vip_BmpData_2[iIndex] = rBmpData[iIndex];
        else
            Vip_BmpData_2[iIndex] = vip_pixel_data_2[iIndex-54];
	end
    //将数组中的数据写到输出BMP图片中  
	for (iIndex = 0; iIndex < iBmpSize; iIndex = iIndex + 1) begin
		rBmpWord = Vip_BmpData_2[iIndex];
		$fwrite(oBmpFileId_2,"%c",rBmpWord);
	end
	$fclose(oBmpFileId_2);

//---------------------------------------------
//延迟13ms，等待第二帧VIP处理结束
    #13000000 	

//---------------------------------------------	
	//输出第三张
	oBmpFileId_3 	= 	$fopen("../../../../../pic/PIC/21_Su_A65NF7/output_file_3.bmp","wb+");
	for (iIndex = 0; iIndex < iBmpSize; iIndex = iIndex + 1) begin
		if(iIndex < 54)
            Vip_BmpData_3[iIndex] = rBmpData[iIndex];
        else
            Vip_BmpData_3[iIndex] = vip_pixel_data_3[iIndex-54];
	end
    //将数组中的数据写到输出BMP图片中    
	for (iIndex = 0; iIndex < iBmpSize; iIndex = iIndex + 1) begin
		rBmpWord = Vip_BmpData_3[iIndex];
		$fwrite(oBmpFileId_3,"%c",rBmpWord);
	end
	$fclose(oBmpFileId_3);
	
//---------------------------------------------
//延迟13ms，等待第三帧VIP处理结束
    #17000000 	
//---------------------------------------------		
	//输出第四张
	oBmpFileId_4 	= 	$fopen("../../../../../pic/PIC/21_Su_A65NF7/output_file_4.bmp","wb+");
	for (iIndex = 0; iIndex < iBmpSize; iIndex = iIndex + 1) begin
		if(iIndex < 54)
            Vip_BmpData_4[iIndex] = rBmpData[iIndex];
        else
            Vip_BmpData_4[iIndex] = vip_pixel_data[iIndex-54];
	end
    //将数组中的数据写到输出BMP图片中    
	for (iIndex = 0; iIndex < iBmpSize; iIndex = iIndex + 1) begin
		rBmpWord = Vip_BmpData_4[iIndex];
		$fwrite(oBmpFileId_4,"%c",rBmpWord);
	end
	$fclose(oBmpFileId_4);

//---------------------------------------------	
	//打开输出的Txt文本
	oTxtFileId 		= $fopen("../../../../../pic/PIC/21_Su_A65NF7/output_file.txt","w+");
	//输出特征值
	for(i=0;i<8;i++)begin
		for(j=0;j<8;j++) begin
			$fdisplay(oTxtFileId,"%b",char_feature[i][7-j]);
		end
		$fdisplay(oTxtFileId,"\n");
	end    
	//关闭Txt文本
    $fclose(oTxtFileId);

end  
//initial end
//--------------------------------------------- 
`else
//---------------------------------------------
initial begin

    //打开输入BMP图片
	iBmpFileId      = $fopen("E:\\github\\Vehicle-License-Plate-Recognition\\pic\\PIC\\21_Su_A65NF7\\21_Su_A65NF7.bmp","rb");

    //将输入BMP图片加载到数组中 21_Su_A65NF7
	iCode = $fread(rBmpData,iBmpFileId);
 
    //根据BMP图片文件头的格式，分别计算出图片的 宽度 /高度 /像素数据偏移量 /图片字节数
	iBmpWidth       = {rBmpData[21],rBmpData[20],rBmpData[19],rBmpData[18]};
	iBmpHight       = {rBmpData[25],rBmpData[24],rBmpData[23],rBmpData[22]};
	iBmpSize        = {rBmpData[ 5],rBmpData[ 4],rBmpData[ 3],rBmpData[ 2]};
	iDataStartIndex = {rBmpData[13],rBmpData[12],rBmpData[11],rBmpData[10]};
    
    //关闭输入BMP图片
	$fclose(iBmpFileId);

//---------------------------------------------		
	//打开输出BMP图片
	oBmpFileId_1 = $fopen("E:\\github\\Vehicle-License-Plate-Recognition\\pic\\PIC\\21_Su_A65NF7\\output_file_1.bmp","wb+");
	oBmpFileId_2 = $fopen("E:\\github\\Vehicle-License-Plate-Recognition\\pic\\PIC\\21_Su_A65NF7\\output_file_2.bmp","wb+");
	oBmpFileId_3 = $fopen("E:\\github\\Vehicle-License-Plate-Recognition\\pic\\PIC\\21_Su_A65NF7\\output_file_4.bmp","wb+");
	oBmpFileId_4 = $fopen("E:\\github\\Vehicle-License-Plate-Recognition\\pic\\PIC\\21_Su_A65NF7\\output_file_3.bmp","wb+");
        
    //延迟13ms，等待第一帧VIP处理结束
    #13000000    
	
    //加载图像处理后，BMP图片的文件头和像素数据
	
//---------------------------------------------		
	//输出第一张
	for (iIndex = 0; iIndex < iBmpSize; iIndex = iIndex + 1) begin
		if(iIndex < 54)
            Vip_BmpData_1[iIndex] = rBmpData[iIndex];
        else
            Vip_BmpData_1[iIndex] = vip_pixel_data_1[iIndex-54];
	end
    //将数组中的数据写到输出BMP图片中    
	for (iIndex = 0; iIndex < iBmpSize; iIndex = iIndex + 4) begin
		rBmpWord = {Vip_BmpData_1[iIndex+3],Vip_BmpData_1[iIndex+2],Vip_BmpData_1[iIndex+1],Vip_BmpData_1[iIndex]};
		$fwrite(oBmpFileId_1,"%u",rBmpWord);
	end

//---------------------------------------------		
	//输出第二张
	for (iIndex = 0; iIndex < iBmpSize; iIndex = iIndex + 1) begin
		if(iIndex < 54)
            Vip_BmpData_2[iIndex] = rBmpData[iIndex];
        else
            Vip_BmpData_2[iIndex] = vip_pixel_data_2[iIndex-54];
	end
    //将数组中的数据写到输出BMP图片中    
	for (iIndex = 0; iIndex < iBmpSize; iIndex = iIndex + 4) begin
		rBmpWord = {Vip_BmpData_2[iIndex+3],Vip_BmpData_2[iIndex+2],Vip_BmpData_2[iIndex+1],Vip_BmpData_2[iIndex]};
		$fwrite(oBmpFileId_2,"%u",rBmpWord);
	end
	
//---------------------------------------------
//延迟13ms，等待第二帧VIP处理结束
    #13000000 	
	
//---------------------------------------------		
	//输出第三张
	for (iIndex = 0; iIndex < iBmpSize; iIndex = iIndex + 1) begin
		if(iIndex < 54)
            Vip_BmpData_3[iIndex] = rBmpData[iIndex];
        else
            Vip_BmpData_3[iIndex] = vip_pixel_data_3[iIndex-54];
	end
    //将数组中的数据写到输出BMP图片中    
	for (iIndex = 0; iIndex < iBmpSize; iIndex = iIndex + 4) begin
		rBmpWord = {Vip_BmpData_3[iIndex+3],Vip_BmpData_3[iIndex+2],Vip_BmpData_3[iIndex+1],Vip_BmpData_3[iIndex]};
		$fwrite(oBmpFileId_3,"%u",rBmpWord);
	end

//---------------------------------------------
//延迟13ms，等待第三帧VIP处理结束
    #17000000 	
	
//---------------------------------------------		
	//输出第四张
	for (iIndex = 0; iIndex < iBmpSize; iIndex = iIndex + 1) begin
		if(iIndex < 54)
            Vip_BmpData_4[iIndex] = rBmpData[iIndex];
        else
            Vip_BmpData_4[iIndex] = vip_pixel_data[iIndex-54];
	end
    //将数组中的数据写到输出BMP图片中    
	for (iIndex = 0; iIndex < iBmpSize; iIndex = iIndex + 4) begin
		rBmpWord = {Vip_BmpData_4[iIndex+3],Vip_BmpData_4[iIndex+2],Vip_BmpData_4[iIndex+1],Vip_BmpData_4[iIndex]};
		$fwrite(oBmpFileId_4,"%u",rBmpWord);
	end	
    	
    //关闭输出BMP图片
	$fclose(oBmpFileId_1);
	$fclose(oBmpFileId_2);
	$fclose(oBmpFileId_3);
	$fclose(oBmpFileId_4);
		
//---------------------------------------------	
	//打开输出的Txt文本
	oTxtFileId = $fopen("E:\\github\\Vehicle-License-Plate-Recognition\\pic\\PIC\\21_Su_A65NF7\\output_file.txt","w+");

	//输出特征值
	for(i=0;i<8;i++)begin
		for(j=0;j<8;j++) begin
			$fdisplay(oTxtFileId,"%b",char_feature[i][7-j]);
		end
		$fdisplay(oTxtFileId,"\n");
	end


    //将数组中的数据写到输出Txt文本中
	//$fwrite(oTxtFileId,"%p",rBmpData);
	
    //关闭Txt文本
    $fclose(oTxtFileId);

end  
//initial end
//--------------------------------------------- 
`endif


//---------------------------------------------		
//初始化时钟和复位信号
initial begin
    clk     = 1;
    rst_n   = 0;
    #110
    rst_n   = 1;
end 

//产生50MHz时钟
always #10 clk = ~clk;
 
//---------------------------------------------		
//在时钟驱动下，从数组中读出像素数据，用于在Modelsim中查看BMP中的数据 
always@(posedge clk or negedge rst_n)begin
    if(!rst_n) begin
        pixel_data  <=  8'd0;
        pixel_index <=  0;
    end
    else begin
        pixel_data  <=  rBmpData[pixel_index];
        pixel_index <=  pixel_index+1;
    end
end
 
//---------------------------------------------
//产生摄像头时序 

wire		cmos_vsync ;
reg			cmos_href;
wire        cmos_clken;
reg	[23:0]	cmos_data;	
		 
reg         cmos_clken_r;

reg [31:0]  cmos_index;

parameter [10:0] IMG_HDISP = 11'd640;
parameter [10:0] IMG_VDISP = 11'd480;

localparam H_SYNC = 11'd5;		
localparam H_BACK = 11'd5;		
localparam H_DISP = IMG_HDISP;	
localparam H_FRONT = 11'd5;		
localparam H_TOTAL = H_SYNC + H_BACK + H_DISP + H_FRONT;	

localparam V_SYNC = 11'd1;		
localparam V_BACK = 11'd0;		
localparam V_DISP = IMG_VDISP;	
localparam V_FRONT = 11'd1;		
localparam V_TOTAL = V_SYNC + V_BACK + V_DISP + V_FRONT;

//---------------------------------------------
//模拟 OV7725/OV5640 驱动模块输出的时钟使能
always@(posedge clk or negedge rst_n) begin
	if(!rst_n)
		cmos_clken_r <= 0;
	else
        cmos_clken_r <= ~cmos_clken_r;
end

//---------------------------------------------
//水平计数器
reg	[10:0]	hcnt;
always@(posedge clk or negedge rst_n) begin
	if(!rst_n)
		hcnt <= 11'd0;
	else if(cmos_clken_r) 
		hcnt <= (hcnt < H_TOTAL - 1'b1) ? hcnt + 1'b1 : 11'd0;
end

//---------------------------------------------
//竖直计数器
reg	[10:0]	vcnt;
always@(posedge clk or negedge rst_n) begin
	if(!rst_n)
		vcnt <= 11'd0;		
	else if(cmos_clken_r) begin
		if(hcnt == H_TOTAL - 1'b1)
			vcnt <= (vcnt < V_TOTAL - 1'b1) ? vcnt + 1'b1 : 11'd0;
		else
			vcnt <= vcnt;
    end
end

//---------------------------------------------
//场同步
reg	cmos_vsync_r;
always@(posedge clk or negedge rst_n) begin
	if(!rst_n)
		cmos_vsync_r <= 1'b0;			//H: Vaild, L: inVaild
	else begin
		if(vcnt <= V_SYNC - 1'b1)
			cmos_vsync_r <= 1'b0; 	//H: Vaild, L: inVaild
		else
			cmos_vsync_r <= 1'b1; 	//H: Vaild, L: inVaild
    end
end
assign	cmos_vsync	= cmos_vsync_r;

//---------------------------------------------
//行有效
wire	frame_valid_ahead =  ( vcnt >= V_SYNC + V_BACK  && vcnt < V_SYNC + V_BACK + V_DISP
                            && hcnt >= H_SYNC + H_BACK  && hcnt < H_SYNC + H_BACK + H_DISP ) 
						? 1'b1 : 1'b0;
      
reg			cmos_href_r;      
always@(posedge clk or negedge rst_n) begin
	if(!rst_n)
		cmos_href_r <= 0;
	else begin
		if(frame_valid_ahead)
			cmos_href_r <= 1;
		else
			cmos_href_r <= 0;
    end
end

always@(posedge clk or negedge rst_n) begin
	if(!rst_n)
		cmos_href <= 0;
	else
        cmos_href <= cmos_href_r;
end

assign cmos_clken = cmos_href & cmos_clken_r;

//-------------------------------------
//从数组中以视频格式输出像素数据
wire [10:0] x_pos;
wire [10:0] y_pos;

assign x_pos = frame_valid_ahead ? (hcnt - (H_SYNC + H_BACK )) : 0;
assign y_pos = frame_valid_ahead ? (vcnt - (V_SYNC + V_BACK )) : 0;

always@(posedge clk or negedge rst_n)begin
   if(!rst_n) begin
       cmos_index   <=  0;
       cmos_data    <=  24'd0;
   end
   else begin
       //cmos_index   <=  y_pos * 960  + x_pos*3 + 54;        //  3*(y*320 + x) + 54
       cmos_index   <=  y_pos * 1920  + x_pos*3 + 54;         //  3*(y*640 + x) + 54
       cmos_data    <=  {rBmpData[cmos_index], rBmpData[cmos_index+1] , rBmpData[cmos_index+2]};
   end
end
 
//-------------------------------------
//VIP算法——彩色转灰度

wire 		per_frame_vsync	=	cmos_vsync ;	
wire 		per_frame_href	=	cmos_href;	
wire 		per_frame_clken	=	cmos_clken;	
wire [7:0]	per_img_red		=	cmos_data[ 7: 0];	   	
wire [7:0]	per_img_green	=	cmos_data[15: 8];   	            
wire [7:0]	per_img_blue	=	cmos_data[23:16];   	            


wire 		post0_frame_vsync;   
wire 		post0_frame_href ;   
wire 		post0_frame_clken;    
wire [7:0]	post0_img_Y      ;   
wire [7:0]	post0_img_Cb     ;   
wire [7:0]	post0_img_Cr     ;   

VIP_RGB888_YCbCr444	u_VIP_RGB888_YCbCr444
(
	//global clock
	.clk				(clk),					
	.rst_n				(rst_n),				

	//Image data prepred to be processd
	.per_frame_vsync	(per_frame_vsync),		
	.per_frame_href		(per_frame_href),		
	.per_frame_clken	(per_frame_clken),		
	.per_img_red		(per_img_red),			
	.per_img_green		(per_img_green),		
	.per_img_blue		(per_img_blue),			
	
	//Image data has been processd
	.post_frame_vsync	(post0_frame_vsync),	
	.post_frame_href	(post0_frame_href),		
	.post_frame_clken	(post0_frame_clken),	
	.post_img_Y			(post0_img_Y ),			
	.post_img_Cb		(post0_img_Cb),			
	.post_img_Cr		(post0_img_Cr)			
);

//--------------------------------------
//VIP算法——二值化

wire			post1_frame_vsync;
wire			post1_frame_href ;
wire			post1_frame_clken;
wire	     	post1_img_Bit    ;

binarization u_binarization (
	.clk					(clk				),  				
	.rst_n					(rst_n				),				

	//Image data prepred to be processd
	.per_frame_vsync		(post0_frame_vsync	),	
	.per_frame_href			(post0_frame_href	),		
	.per_frame_clken		(post0_frame_clken	),	
	.per_img_Y				(post0_img_Cb		),			
    
	//Image data has been processd
	.post_frame_vsync		(post1_frame_vsync	),	
	.post_frame_href		(post1_frame_href	),		
	.post_frame_clken		(post1_frame_clken	),	
	.post_img_Bit			(post1_img_Bit		),		
	
	//二值化阈值 
	.Binary_Threshold		(150				)				
);


//--------------------------------------
//VIP算法——腐蚀
wire			post2_frame_vsync;	
wire			post2_frame_href;	
wire			post2_frame_clken;	
wire			post2_img_Bit;		

VIP_Bit_Erosion_Detector#(
	.IMG_HDISP				(IMG_HDISP			),	//640*480
	.IMG_VDISP				(IMG_VDISP			)
)u_VIP_Bit_Erosion_Detector(
	//global clock
	.clk					(clk				),  				
	.rst_n					(rst_n				),				

	//Image data prepred to be processd
	.per_frame_vsync		(post1_frame_vsync	),	
	.per_frame_href			(post1_frame_href	),		
	.per_frame_clken		(post1_frame_clken	),	
	.per_img_Bit			(post1_img_Bit		),		

	//Image data has been processd
	.post_frame_vsync		(post2_frame_vsync	),	
	.post_frame_href		(post2_frame_href	),		
	.post_frame_clken		(post2_frame_clken	),	
	.post_img_Bit			(post2_img_Bit		)			
);

//--------------------------------------
//VIP 算法——Sobel边缘检测

wire			post4_frame_vsync;	 
wire			post4_frame_href;	 
wire			post4_frame_clken;	 
wire			post4_img_Bit;		 

VIP_Sobel_Edge_Detector #(
	.IMG_HDISP				(IMG_HDISP	),	 
	.IMG_VDISP				(IMG_VDISP	)
) u_VIP_Sobel_Edge_Detector (
	.clk					(clk		),  				
	.rst_n					(rst_n		),				

	//Image data prepred to be processd
	.per_frame_vsync		(post2_frame_vsync	),	
	.per_frame_href			(post2_frame_href	),		
	.per_frame_clken		(post2_frame_clken	),	
	.per_img_Y				({8{post2_img_Bit}}	),			

	//Image data has been processd
	.post_frame_vsync		(post4_frame_vsync	),	
	.post_frame_href		(post4_frame_href	),		
	.post_frame_clken		(post4_frame_clken	),	
	.post_img_Bit			(post4_img_Bit		),		
	
	//User interface
	.Sobel_Threshold		(128)					
);

//--------------------------------------
//VIP算法——投影前先进行线条的膨胀，防止角度偏移1到2个像素
wire			post5_frame_vsync;	
wire			post5_frame_href;	
wire			post5_frame_clken;	
wire			post5_img_Bit;	
	
VIP_Bit_Dilation_Detector#(
	.IMG_HDISP	(IMG_HDISP),	//640*480
	.IMG_VDISP	(IMG_VDISP)
)u_VIP_Bit_Dilation_Detector(
	//global clock
	.clk					(clk				),  				
	.rst_n					(rst_n				),				

	//Image data prepred to be processd
	.per_frame_vsync		(post4_frame_vsync	),	
	.per_frame_href			(post4_frame_href	),		
	.per_frame_clken		(post4_frame_clken	),	
	.per_img_Bit			(post4_img_Bit		),		

	//Image data has been processd
	.post_frame_vsync		(post5_frame_vsync	),	
	.post_frame_href		(post5_frame_href	),		
	.post_frame_clken		(post5_frame_clken	),	
	.post_img_Bit			(post5_img_Bit		)			
);


//--------------------------------------
//VIP算法——对整帧图像进行竖直投影

wire [9:0] 		max_line_left ;  
wire [9:0] 		max_line_right;
	
VIP_vertical_projection#(
	.IMG_HDISP	(IMG_HDISP),	//640*480
	.IMG_VDISP	(IMG_VDISP),
	
	.EDGE_THROD	(45)			//边缘阈值
)u_VIP_vertical_projection(
	//global clock
	.clk					(clk),  				
	.rst_n					(rst_n),				

	//Image data prepred to be processd
	.per_frame_vsync		(post5_frame_vsync	),	
	.per_frame_href			(post5_frame_href	),		
	.per_frame_clken		(post5_frame_clken	),	
	.per_img_Bit			(post5_img_Bit		),		

	//Image data has been processd
	.post_frame_vsync		(),	
	.post_frame_href		(),	
	.post_frame_clken		(),	
	.post_img_Bit			(),


	.max_line_left 			(max_line_left 		),  
	.max_line_right			(max_line_right		),
                             
	.vertical_start			(0					), 
	.vertical_end			(IMG_VDISP - 1		)   
);

//--------------------------------------
//VIP算法——对整帧图像进行水平投影
wire [9:0] 		max_line_up  ;  
wire [9:0] 		max_line_down;
	
VIP_horizon_projection#(
	.IMG_HDISP	(IMG_HDISP),	//640*480
	.IMG_VDISP	(IMG_VDISP),
	
	.EDGE_THROD	(100)			//边缘阈值
)u_VIP_horizon_projection(
	//global clock
	.clk					(clk				),  				
	.rst_n					(rst_n				),				

	//Image data prepred to be processd
	.per_frame_vsync		(post5_frame_vsync	),	
	.per_frame_href			(post5_frame_href	),		
	.per_frame_clken		(post5_frame_clken	),	
	.per_img_Bit			(post5_img_Bit		),		

	//Image data has been processd
	.post_frame_vsync		(),	
	.post_frame_href		(),	
	.post_frame_clken		(),	
	.post_img_Bit			(),

	.max_line_up  			(max_line_up  		),  
	.max_line_down			(max_line_down		),
                             
	.horizon_start			(0					), 
	.horizon_end			(IMG_HDISP - 1		)   
);




//-------------------------------------
//修正车牌的边界，使其只包含字符区域

wire [9:0] 	plate_boarder_up 	;  	//调整后的边框
wire [9:0] 	plate_boarder_down	; 
wire [9:0] 	plate_boarder_left 	;
wire [9:0] 	plate_boarder_right	;

plate_boarder_adjust u_plate_boarder_adjust(
	//global clock
	.clk					(clk				),  				
	.rst_n					(rst_n				),				

	//Image data prepred to be processd
	.per_frame_vsync		(post5_frame_vsync	),	

	.max_line_up  			(max_line_up  		),  
	.max_line_down			(max_line_down		),
	.max_line_left 			(max_line_left 		),  
	.max_line_right			(max_line_right		),
	
    .plate_boarder_up 	    (plate_boarder_up 	),
    .plate_boarder_down	    (plate_boarder_down	),
    .plate_boarder_left     (plate_boarder_left ),
    .plate_boarder_right    (plate_boarder_right),

	.plate_exist_flag	    ()	
);


//--------------------------------------
//VIP算法——对字符区域进行二值化


wire			post8_frame_vsync;
wire			post8_frame_href ;
wire			post8_frame_clken;
wire	     	post8_img_Bit    ;

binarization_char #(
	.IMG_HDISP	(IMG_HDISP),	//640*480
	.IMG_VDISP	(IMG_VDISP)
)u_binarization_char (
	.clk					(clk				),  				
	.rst_n					(rst_n				),				

	//Image data prepred to be processd	
	.per_frame_vsync		(per_frame_vsync	),		
	.per_frame_href			(per_frame_href		),		
	.per_frame_clken		(per_frame_clken	),		
	.per_img_Y				(per_img_red		),			
    
	//Image data has been processd
	.post_frame_vsync		(post8_frame_vsync	),	
	.post_frame_href		(post8_frame_href	),		
	.post_frame_clken		(post8_frame_clken	),	
	.post_img_Bit			(post8_img_Bit		),
	
	//二值化阈值 
	.Binary_Threshold		(128				),

    .plate_boarder_up 	    (plate_boarder_up 	),
    .plate_boarder_down	    (plate_boarder_down	),
	
    .plate_boarder_left     (plate_boarder_left ),
    .plate_boarder_right    (plate_boarder_right) 
);

//--------------------------------------
//VIP算法——腐蚀
wire			post9_frame_vsync;	
wire			post9_frame_href;	
wire			post9_frame_clken;	
wire			post9_img_Bit;		

VIP_Bit_Erosion_Detector#(
	.IMG_HDISP	(IMG_HDISP),	//640*480
	.IMG_VDISP	(IMG_VDISP)
)u_VIP_Bit_Erosion_Detector_red(
	//global clock
	.clk					(clk				),  				
	.rst_n					(rst_n				),				

	//Image data prepred to be processd
	.per_frame_vsync		(post8_frame_vsync	),	
	.per_frame_href			(post8_frame_href	),		
	.per_frame_clken		(post8_frame_clken	),	
	.per_img_Bit			(post8_img_Bit		),		

	//Image data has been processd
	.post_frame_vsync		(post9_frame_vsync	),	
	.post_frame_href		(post9_frame_href	),		
	.post_frame_clken		(post9_frame_clken	),	
	.post_img_Bit			(post9_img_Bit		)			
);


//--------------------------------------
//VIP算法——膨胀
wire			post10_frame_vsync;	
wire			post10_frame_href;	
wire			post10_frame_clken;	
wire			post10_img_Bit;	
	
VIP_Bit_Dilation_Detector#(
	.IMG_HDISP				(IMG_HDISP			),	//640*480
	.IMG_VDISP				(IMG_VDISP			)
)u_VIP_Bit_Dilation_Detector_red(
	//global clock
	.clk					(clk				),  				
	.rst_n					(rst_n				),				

	//Image data prepred to be processd
	.per_frame_vsync		(post9_frame_vsync	),	
	.per_frame_href			(post9_frame_href	),		
	.per_frame_clken		(post9_frame_clken	),	
	.per_img_Bit			(post9_img_Bit		),		

	//Image data has been processd
	.post_frame_vsync		(post10_frame_vsync	),	
	.post_frame_href		(post10_frame_href	),		
	.post_frame_clken		(post10_frame_clken	),	
	.post_img_Bit			(post10_img_Bit		)			
);


//--------------------------------------
//VIP算法——字符区域进行竖直投影
wire			post11_frame_vsync;	
wire			post11_frame_href;	
wire			post11_frame_clken;	
wire			post11_img_Bit;	

wire [20:0] 	char_boarder[7:0];
	
VIP_vertical_projection_char#(
	.IMG_HDISP				(IMG_HDISP				),	//640*480
	.IMG_VDISP				(IMG_VDISP				)
)u_VIP_vertical_projection_char(
	//global clock
	.clk					(clk					),  				
	.rst_n					(rst_n					),				

	//Image data prepred to be processd
	.per_frame_vsync		(post10_frame_vsync		),	
	.per_frame_href			(post10_frame_href		),		
	.per_frame_clken		(post10_frame_clken		),	
	.per_img_Bit			(post10_img_Bit			),		

	//Image data has been processd
	.post_frame_vsync		(post11_frame_vsync		),	
	.post_frame_href		(post11_frame_href		),		
	.post_frame_clken		(post11_frame_clken		),	
	.post_img_Bit			(post11_img_Bit			),

	.char_boarder			(char_boarder			),
	
	.vertical_start			(0						), 	//车牌范围以外的其他行，已经在二值化的时候被过滤掉了
	.vertical_end			(IMG_VDISP - 1			),
	
    .plate_boarder_left     (plate_boarder_left 	),  //车牌横向坐标，用于排除第一个汉字为左右结构时，导致识别成两个字符
    .plate_boarder_right    (plate_boarder_right	) 	
);

//--------------------------------------
//VIP算法——字符区域进行水平投影

wire [9:0] 	char_top  ;
wire [9:0] 	char_down;
	
VIP_horizon_projection_char#(
	.IMG_HDISP	(IMG_HDISP),	//640*480
	.IMG_VDISP	(IMG_VDISP),
	
	.EDGE_THROD	(14)			//像素变化超过7*2次，表示到达边界位置
)u_VIP_horizon_projection_char(
	//global clock
	.clk					(clk),  				
	.rst_n					(rst_n),				

	//Image data prepred to be processd
	.per_frame_vsync		(post10_frame_vsync	),	
	.per_frame_href			(post10_frame_href	),		
	.per_frame_clken		(post10_frame_clken	),	
	.per_img_Bit			(post10_img_Bit		),			

	//Image data has been processd
	.post_frame_vsync		(),	
	.post_frame_href		(),	
	.post_frame_clken		(),	
	.post_img_Bit			(),

	.char_top 				(char_top ),
	.char_down				(char_down),
                             
	.horizon_start			(0				), //车牌范围以外的其他列，已经在二值化的时候被过滤掉了
	.horizon_end			(IMG_HDISP - 1	)
);

//--------------------------------------
//VIP算法——特征识别
	
//腐蚀和膨胀后会在竖直方向差生偏移，需要进行调整
	
plate_feature_recognize
#(
	.IMG_HDISP	(IMG_HDISP),	//640*480
	.IMG_VDISP	(IMG_VDISP)
)
u_plate_feature_recognize
(
	//global clock
	.clk					(clk),  				
	.rst_n					(rst_n),				

	//Image data prepred to be processd
	.per_frame_vsync		(post11_frame_vsync),	
	.per_frame_href			(post11_frame_href),		
	.per_frame_clken		(post11_frame_clken),	
	.per_img_Bit			(post11_img_Bit),		

	//Image data has been processd
	// .post_frame_vsync		(post10_frame_vsync),	
	// .post_frame_href			(post10_frame_href),		
	// .post_frame_clken		(post10_frame_clken),	
	// .post_img_Bit			(post10_img_Bit),

	.char_top       (char_top ),
    .char_down      (char_down),
	.char_boarder	(char_boarder),
	
	.char_feature	(char_feature)
);

wire exist;
//--------------------------------------
// //VIP算法——卷积模板匹配

// wire [0:4] 	char_feature_updown  [7:0] [7:0] ;		//特征结果上下翻转

// assign char_feature_updown[j][0] = char_feature[j][7];
// assign char_feature_updown[j][1] = char_feature[j][6];
// assign char_feature_updown[j][2] = char_feature[j][5];
// assign char_feature_updown[j][3] = char_feature[j][4];
// assign char_feature_updown[j][4] = char_feature[j][3];
// assign char_feature_updown[j][5] = char_feature[j][2];
// assign char_feature_updown[j][6] = char_feature[j][1];
// assign char_feature_updown[j][7] = char_feature[j][0];

wire [7:0]	char_index [7:0];	//匹配的字符索引
wire		match_valid		;	//匹配成功标志

conv_template_match conv_template_match(
	.clk					(clk),  				
	.rst_n					(rst_n),
	
	.char_feature			(char_feature),
    .char_feature_valid		(~post11_frame_vsync), 
	
	.char_index 			(char_index ),
	.match_valid			(match_valid)
);

//-------------------------------------
//视频显示驱动

wire video_hs;
wire video_vs;
wire video_de;

wire [10:0]  pixel_xpos;          //像素点横坐标
wire [10:0]  pixel_ypos;          //像素点纵坐标   

//例化视频显示驱动模块
video_driver u_video_driver(
    .pixel_clk      (clk),
    .sys_rst_n      (rst_n),

    .video_hs       (video_hs),
    .video_vs       (video_vs),
    .video_de       (video_de),
    .video_rgb      (),
   
    .pixel_xpos     (pixel_xpos),
    .pixel_ypos     (pixel_ypos),
    .pixel_data     ()
    );

    wire   [3:0]         VGA_R;
    wire   [3:0]         VGA_G;
    wire   [3:0]         VGA_B;
	

//lcd显示模块    
lcd_display u_lcd_display(          
    .lcd_clk        (clk),    
    .sys_rst_n      (rst_n ),
    
    .pixel_xpos     (pixel_xpos), 
    .pixel_ypos     (pixel_ypos),
    
    .VGA_R          (VGA_R),
    .VGA_G          (VGA_G),
    .VGA_B          (VGA_B),
    
    .up_pos       	(max_line_up    ),  
    .down_pos      	(max_line_down  ),
	.left_pos       (max_line_left 	),
    .right_pos      (max_line_right	),

    .char_up_pos	(char_top ),  
    .char_down_pos	(char_down),
	.char_left_pos	(plate_boarder_left ),
    .char_right_pos	(plate_boarder_right),

	.char_top       (char_top ),
    .char_down      (char_down),
	.char_boarder	(char_boarder) 
    );




//-------------------------------------

wire 		PIC1_vip_out_frame_vsync;   
wire 		PIC1_vip_out_frame_href ;   
wire 		PIC1_vip_out_frame_clken;    
wire [7:0]	PIC1_vip_out_img_R     ;   
wire [7:0]	PIC1_vip_out_img_G     ;   
wire [7:0]	PIC1_vip_out_img_B     ;  

wire 		PIC2_vip_out_frame_vsync;   
wire 		PIC2_vip_out_frame_href ;   
wire 		PIC2_vip_out_frame_clken;    
wire [7:0]	PIC2_vip_out_img_R     ;   
wire [7:0]	PIC2_vip_out_img_G     ;   
wire [7:0]	PIC2_vip_out_img_B     ;   

wire 		PIC3_vip_out_frame_vsync;   
wire 		PIC3_vip_out_frame_href ;   
wire 		PIC3_vip_out_frame_clken;    
wire [7:0]	PIC3_vip_out_img_R     ;   
wire [7:0]	PIC3_vip_out_img_G     ;   
wire [7:0]	PIC3_vip_out_img_B     ; 


//第一张输出Sobel边缘检测之后的结果
assign PIC1_vip_out_frame_vsync 	= 	post4_frame_vsync ;   
assign PIC1_vip_out_frame_href  	= 	post4_frame_href  ;   
assign PIC1_vip_out_frame_clken 	= 	post4_frame_clken ;  
assign PIC1_vip_out_img_R        	= 	{8{post4_img_Bit}};   
assign PIC1_vip_out_img_G        	= 	{8{post4_img_Bit}};   
assign PIC1_vip_out_img_B        	= 	{8{post4_img_Bit}}; 

//第二张输出中值滤波之后的结果
assign PIC2_vip_out_frame_vsync 	=  	post5_frame_vsync ;   
assign PIC2_vip_out_frame_href  	=  	post5_frame_href  ;   
assign PIC2_vip_out_frame_clken 	=  	post5_frame_clken ; 
assign PIC2_vip_out_img_R 			=  	{8{post5_img_Bit}};
assign PIC2_vip_out_img_G 			=  	{8{post5_img_Bit}};
assign PIC2_vip_out_img_B 			=  	{8{post5_img_Bit}};


//第三张输出灰度转换之后的Cb
 assign PIC3_vip_out_frame_vsync 	=	post10_frame_vsync ; 	   
 assign PIC3_vip_out_frame_href  	=	post10_frame_href  ; 	   
 assign PIC3_vip_out_frame_clken 	=	post10_frame_clken ; 	 
 assign PIC3_vip_out_img_R 			=	{8{post10_img_Bit}};	
 assign PIC3_vip_out_img_G 			=	{8{post10_img_Bit}};	
 assign PIC3_vip_out_img_B 			=	{8{post10_img_Bit}};



//寄存图像处理之后的像素数据

//-------------------------------------
//第一张图
reg [31:0]  PIC1_vip_cnt;
reg         PIC1_vip_vsync_r;    //寄存VIP输出的场同步 
reg         PIC1_vip_out_en;     //寄存VIP处理图像的使能信号，仅维持一帧的时间

always@(posedge clk or negedge rst_n)begin
   if(!rst_n) 
        PIC1_vip_vsync_r   <=  1'b0;
   else 
        PIC1_vip_vsync_r   <=  PIC1_vip_out_frame_vsync;
end

always@(posedge clk or negedge rst_n)begin
   if(!rst_n) 
        PIC1_vip_out_en    <=  1'b1;
   else if(PIC1_vip_vsync_r & (!PIC1_vip_out_frame_vsync))  //第一帧结束之后，使能拉低
        PIC1_vip_out_en    <=  1'b0;
end

always@(posedge clk or negedge rst_n)begin
   if(!rst_n) begin
        PIC1_vip_cnt <=  32'd0;
   end
   else if(PIC1_vip_out_en) begin
        if(PIC1_vip_out_frame_href & PIC1_vip_out_frame_clken) begin
            PIC1_vip_cnt <=  PIC1_vip_cnt + 3;
            vip_pixel_data_1[PIC1_vip_cnt+0] <= PIC1_vip_out_img_R;
            vip_pixel_data_1[PIC1_vip_cnt+1] <= PIC1_vip_out_img_G;
            vip_pixel_data_1[PIC1_vip_cnt+2] <= PIC1_vip_out_img_B;
        end
   end
end

//-------------------------------------
//第二张图

reg [31:0]  PIC2_vip_cnt;
reg         PIC2_vip_vsync_r;    //寄存VIP输出的场同步 
reg         PIC2_vip_out_en;     //寄存VIP处理图像的使能信号，仅维持一帧的时间

always@(posedge clk or negedge rst_n)begin
   if(!rst_n) 
        PIC2_vip_vsync_r   <=  1'b0;
   else 
        PIC2_vip_vsync_r   <=  PIC2_vip_out_frame_vsync;
end

always@(posedge clk or negedge rst_n)begin
   if(!rst_n) 
        PIC2_vip_out_en    <=  1'b1;
   else if(PIC2_vip_vsync_r & (!PIC2_vip_out_frame_vsync))  //第一帧结束之后，使能拉低
        PIC2_vip_out_en    <=  1'b0;
end

always@(posedge clk or negedge rst_n)begin
   if(!rst_n) begin
        PIC2_vip_cnt <=  32'd0;
   end
   else if(PIC2_vip_out_en) begin
        if(PIC2_vip_out_frame_href & PIC2_vip_out_frame_clken) begin
            PIC2_vip_cnt <=  PIC2_vip_cnt + 3;
            vip_pixel_data_2[PIC2_vip_cnt+0] <= PIC2_vip_out_img_R;
            vip_pixel_data_2[PIC2_vip_cnt+1] <= PIC2_vip_out_img_G;
            vip_pixel_data_2[PIC2_vip_cnt+2] <= PIC2_vip_out_img_B;
        end
   end
end

//-------------------------------------
//第三张图
reg [31:0]  PIC3_vip_cnt;
reg         PIC3_vip_vsync_r;    //寄存VIP输出的场同步 
reg         PIC3_vip_out_en;     //寄存VIP处理图像的使能信号，仅维持一帧的时间

always@(posedge clk or negedge rst_n)begin
   if(!rst_n) 
        PIC3_vip_vsync_r   <=  1'b0;
   else 
        PIC3_vip_vsync_r   <=  PIC3_vip_out_frame_vsync;
end

reg frame_2nd_en;

always@(posedge clk or negedge rst_n)begin
	if(!rst_n) begin
        PIC3_vip_out_en	<=	1'b0;
		frame_2nd_en 	<= 	1'b0;
	end
	else if(PIC1_vip_out_en == 1) begin
		PIC3_vip_out_en	<=  1'b0;
		frame_2nd_en 	<= 	1'b0;
	end
	else if((!frame_2nd_en) & PIC3_vip_out_frame_vsync & (!PIC3_vip_vsync_r)) begin //第一帧结束之后，拉高第二帧使能
        PIC3_vip_out_en	<=  1'b1;
		frame_2nd_en 	<= 	1'b1;
	end
	else if(PIC3_vip_vsync_r & (!PIC3_vip_out_frame_vsync))  //第二帧结束之后，使能拉低
        PIC3_vip_out_en    <=  1'b0;
end

always@(posedge clk or negedge rst_n)begin
   if(!rst_n) begin
        PIC3_vip_cnt <=  32'd0;
   end
   else if(PIC3_vip_out_en) begin
        if(PIC3_vip_out_frame_href & PIC3_vip_out_frame_clken) begin
            PIC3_vip_cnt <=  PIC3_vip_cnt + 3;
            vip_pixel_data_3[PIC3_vip_cnt+0] <= PIC3_vip_out_img_R;
            vip_pixel_data_3[PIC3_vip_cnt+1] <= PIC3_vip_out_img_G;
            vip_pixel_data_3[PIC3_vip_cnt+2] <= PIC3_vip_out_img_B;
        end
   end
end

//-------------------------------------
//第四张图
reg [31:0] vip_cnt;

wire [7:0]	vip_out_img_R;   
wire [7:0]	vip_out_img_G;   
wire [7:0]	vip_out_img_B;  

assign vip_out_img_R       = {VGA_R,  VGA_R};   
assign vip_out_img_G       = {VGA_G,  VGA_G};   
assign vip_out_img_B       = {VGA_B,  VGA_B};

wire out_border_flag;

assign out_border_flag = VGA_R[0] | VGA_G[0] | VGA_B[0];

 
reg    vip_vsync_r;    //寄存VIP输出的场同步 
reg    vip_out_en;     //寄存VIP处理图像的使能信号，仅维持一帧的时间

always@(posedge clk or negedge rst_n)begin
   if(!rst_n) 
        vip_vsync_r   <=  1'b0;
   else 
        vip_vsync_r   <=  video_vs;
end

reg frame_3rd_en;

always@(posedge clk or negedge rst_n)begin
	if(!rst_n) begin
        vip_out_en		<=	1'b0;
		frame_3rd_en	<= 1'b0;
	end
	else if((PIC1_vip_out_en == 1)||(PIC3_vip_out_en == 1)) begin 		//前两帧图像处理过程中，使能拉低
		vip_out_en    	<=	1'b0;
		frame_3rd_en	<=	1'b0;
	end
	else  if((!frame_3rd_en) & video_vs & (!vip_vsync_r)) begin //第二帧结束之后，使能拉高
        vip_out_en    	<=  1'b1;
		frame_3rd_en	<= 	1'b1;
	end
	else if(vip_vsync_r & (!video_vs))  
        vip_out_en    <=  1'b0;
end

always@(posedge clk or negedge rst_n)begin
   if(!rst_n) begin
        vip_cnt <=  32'd0;
   end
   else if(vip_out_en) begin
        if(video_de) begin
            vip_cnt <=  vip_cnt + 3;
            // vip_pixel_data[vip_cnt+0] <= (vip_out_img_R == 8'b1111_0000) ? 8'h00 : vip_pixel_data_3[vip_cnt+0];
            // vip_pixel_data[vip_cnt+1] <= (vip_out_img_G == 8'b1111_0000) ? 8'h00 : vip_pixel_data_3[vip_cnt+1];
            // vip_pixel_data[vip_cnt+2] <= (vip_out_img_B == 8'b1111_0000) ? 8'hFF : vip_pixel_data_3[vip_cnt+2];
			
            vip_pixel_data[vip_cnt+0] <= out_border_flag ? vip_out_img_B : vip_pixel_data_3[vip_cnt+0];
            vip_pixel_data[vip_cnt+1] <= out_border_flag ? vip_out_img_G : vip_pixel_data_3[vip_cnt+1];
            vip_pixel_data[vip_cnt+2] <= out_border_flag ? vip_out_img_R : vip_pixel_data_3[vip_cnt+2];
        end
   end
end
 


endmodule 