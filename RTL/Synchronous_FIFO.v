module Synchronous_FIFO #(
    parameter DATA_WIDTH = 8,
    parameter ADDR_WIDTH = 3
) 
(
    input                       clk         ,
    input                       rst_n       ,
    input                       wr_en       , 
    input      [DATA_WIDTH-1:0] wr_data     , 
    input                       rd_en       , 
    output reg [DATA_WIDTH-1:0] rd_data     , 
    output                      empty       , 
    output                      full        , 
    output reg [ADDR_WIDTH :0]  data_cnt    , 
    output                      wr_err      , 
    output                      rd_err      
);

localparam FIFO_DEPTH = 1 << ADDR_WIDTH; 

// Memory
reg [DATA_WIDTH-1:0] fifo_mem [FIFO_DEPTH-1:0];

// Address
reg [ADDR_WIDTH-1:0] wr_address;
reg [ADDR_WIDTH-1:0] rd_address;

integer i;

// Write Data
always @(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        for(i=0; i<{(ADDR_WIDTH){1'b1}}; i=i+1) begin
            fifo_mem[i] <= {DATA_WIDTH{1'b0}};
        end
    end else if(wr_en & (~full)) begin 
        fifo_mem[wr_address] <= wr_data;
    end else begin
        fifo_mem[wr_address] <= fifo_mem[wr_address];
    end
end

// Read Data
always @(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        rd_data <= {DATA_WIDTH{1'b0}};
    end else if( rd_en & (~empty) ) begin
        rd_data <= fifo_mem[rd_address];
    end else begin
        rd_data <= rd_data;
    end
end 

// Write Address
always @(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        wr_address <= {ADDR_WIDTH{1'b0}};
    end else if(wr_en & (~full)) begin
        if( &wr_address == 1'b1) begin
            wr_address <= {ADDR_WIDTH{1'b0}};
        end else begin
            wr_address <= wr_address + 1'b1;
        end
    end else begin
        wr_address <= wr_address;
    end
end

// Read Address
always @(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        rd_address <= {ADDR_WIDTH{1'b0}};
    end else if(rd_en & (~empty)) begin
        if(&rd_address == 1'b1) begin
            rd_address <= {ADDR_WIDTH{1'b0}};
        end else begin
            rd_address <= rd_address + 1'b1;
        end
    end else begin
        rd_address <= rd_address;
    end
end

// Data Count
always @(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        data_cnt <= {ADDR_WIDTH{1'b0}};
    end else if(wr_en & (~full) & (~(rd_en & (~empty)))) begin
        data_cnt <= data_cnt + 1'b1;
    end else if(rd_en & (~empty) & (~(wr_en & (~full)))) begin
        data_cnt <= data_cnt - 1'b1;
    end else begin
        data_cnt <= data_cnt;
    end
end

assign empty    = (data_cnt == {ADDR_WIDTH{1'b0}});
assign full     = (data_cnt == ({ADDR_WIDTH{1'b1}}) + 1'b1 );
assign wr_err   = (full & wr_en);
assign rd_err   = (empty & rd_en);

endmodule 