module fetch_buffer #(parameter CORE = 0, DATA_WIDTH = 32, INDEX_BITS = 6, 
                     OFFSET_BITS = 3, ADDRESS_BITS = 20)(
	clock,        
	instruction,
        inst_PC,
        valid,
        ready,
        reg_instruction,
        reg_inst_PC,
        reg_valid,
        reg_ready
); 

input [DATA_WIDTH-1:0]   instruction;
input [ADDRESS_BITS-1:0] inst_PC;  
input valid; 
input ready;
input clock; 

output reg [DATA_WIDTH-1:0]   reg_instruction;
output reg [ADDRESS_BITS-1:0] reg_inst_PC;  
output reg reg_valid; 
output reg reg_ready; 

always @ (posedge clock) begin

     reg_instruction <= instruction;
     reg_inst_PC <= inst_PC;
     reg_valid <= valid;
     reg_ready <= ready;

end




endmodule
