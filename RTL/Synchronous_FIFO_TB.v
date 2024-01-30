`timescale 1ns/1ns
module Synchronous_FIFO_TB();

    parameter DATA_WIDTH = 8;
    parameter ADDR_WIDTH = 3;

    reg                         clk;
    reg                         rst_n;
    reg                         wr_en;
    reg     [DATA_WIDTH-1:0]    wr_data;
    reg                         rd_en;
    wire    [DATA_WIDTH-1:0]    rd_data;
    wire                        empty;
    wire                        full;
    wire    [ADDR_WIDTH :0]     data_cnt;
    wire                        wr_err;
    wire                        rd_err;

Synchronous_FIFO #( DATA_WIDTH , ADDR_WIDTH ) TB_FIFO 
(
    .clk        (clk),
    .rst_n      (rst_n),
    .wr_en      (wr_en),
    .wr_data    (wr_data),
    .rd_en      (rd_en),
    .rd_data    (rd_data),
    .empty      (empty),
    .full       (full),
    .data_cnt   (data_cnt),
    .wr_err     (wr_err),
    .rd_err     (rd_err)     
);

localparam CYCLE = 20;

initial begin
	clk = 0;
	forever begin
		#(CYCLE/2);
		clk = 1;
		#(CYCLE/2);
		clk = 0;
	end
end

initial begin 
	rst_n = 0;
	#(2*CYCLE)
	rst_n = 1;
end 

integer i;

initial	begin                                                  
rd_en = 0;
wr_en = 0;

wr_data = 8'b0;

#(6*CYCLE)
wr_en = 1'b1;

for(i = 0; i < 8; i = i + 1) begin
    @(posedge clk);
    wr_data = wr_data + 1'b1;
end

#(6*CYCLE)
wr_en = 1'b0;
rd_en = 1'b1;

#(10*CYCLE); $stop;                                          
$display("Running testbench");                       
end                                                    
                                                    
endmodule 