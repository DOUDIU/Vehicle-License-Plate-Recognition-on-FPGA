module dual_port_ram#(
    parameter RAM_WIDTH = 16,
    parameter ADDR_LINE = 7
)(
    clk,
    wr_en,
    wr_data,
    rd_data,
    wr_addr,
    rd_addr
);

// ********************************************
//                                             
//    Input/Output DECLARATION                    
//                                             
// ********************************************
    input                       clk;          // clock in
    input                       wr_en;        // write enable, high active
    input   [ADDR_LINE-1:0]     wr_addr;      // wr address input
    input   [ADDR_LINE-1:0]     rd_addr;      // rd address input
    input   [RAM_WIDTH-1:0]     wr_data;      // data input
    output  [RAM_WIDTH-1:0]     rd_data;      // data output
// ********************************************
    reg     [RAM_WIDTH-1:0]     memory[(1<<ADDR_LINE)-1:0];
    reg     [RAM_WIDTH-1:0]     data_r;	
    reg     [RAM_WIDTH-1:0]     rd_data_tem;

integer i; 
initial begin
    for (i = 0; i < (1<<ADDR_LINE); i = i + 1) begin
        memory[i]   <=  0;
    end 
end 


//д
always @(posedge clk)begin
    if (wr_en)
        memory[wr_addr] <= wr_data;
    else
        memory[wr_addr] <= memory[wr_addr];
end

always@(posedge clk) begin
    rd_data_tem     <=      memory[rd_addr];
end


assign rd_data = rd_data_tem;

endmodule
