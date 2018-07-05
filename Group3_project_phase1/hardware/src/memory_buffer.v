module memory_buffer #(parameter CORE = 0, DATA_WIDTH = 32, INDEX_BITS = 6, 
                     OFFSET_BITS = 3, ADDRESS_BITS = 20)(
	clock,        
	data_addr, 
        load_data,
        valid, 
        ready,
	regWrite,
	memRead,
	rd,
	ALU_result,
	reg_data_addr,
	reg_load_data,
	reg_valid,
	reg_ready,
	reg_regWrite,
	reg_memRead,
	reg_rd,
	reg_ALU_result
); 

input [ADDRESS_BITS-1:0] data_addr;
input [DATA_WIDTH-1:0]   load_data;
input valid; 
input ready, regWrite, memRead;
input [DATA_WIDTH-1:0] ALU_result;
input clock;
input [4:0] rd;
output reg [ADDRESS_BITS-1:0] reg_data_addr;
output reg [DATA_WIDTH-1:0]   reg_load_data;
output reg reg_valid;
output reg reg_ready, reg_regWrite, reg_memRead;
output reg [DATA_WIDTH-1:0] reg_ALU_result;
output reg [4:0] reg_rd;

always @ (posedge clock) begin
     reg_data_addr <= data_addr;
     reg_load_data <= load_data;
     reg_valid <= valid;
     reg_ready <= ready;
     reg_regWrite <= regWrite;
     reg_memRead <= memRead;
     reg_rd <= rd;
     reg_ALU_result <= ALU_result;
end




endmodule
