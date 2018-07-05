module decode_buffer #(parameter CORE = 0, DATA_WIDTH = 32, INDEX_BITS = 6, 
                     OFFSET_BITS = 3, ADDRESS_BITS = 20)(
	clock,
	rs1_data, 
	rs2_data,
	rd,  
	opcode,
	funct7, 
	funct3,
	extend_imm,
	branch_target, 
	JAL_target,
        inst_PC,

	reg_rs1_data, 
	reg_rs2_data,
	reg_rd,  
	reg_opcode,
	reg_funct7, 
	reg_funct3,
	reg_extend_imm,
	reg_branch_target, 
	reg_JAL_target,
        reg_inst_PC
); 

input [31:0] rs1_data; 
input [31:0] rs2_data;
input [4:0]  rd;  
input [6:0]  opcode;
input [6:0]  funct7; 
input [2:0]  funct3;
input [31:0] extend_imm;
input [ADDRESS_BITS-1:0] branch_target; 
input [ADDRESS_BITS-1:0] JAL_target;
input clock;
input [ADDRESS_BITS-1:0] inst_PC;  

output reg [31:0] reg_rs1_data; 
output reg [31:0] reg_rs2_data;
output reg [4:0]  reg_rd;  
output reg [6:0]  reg_opcode;
output reg [6:0]  reg_funct7; 
output reg [2:0]  reg_funct3;
output reg [31:0] reg_extend_imm;
output reg [ADDRESS_BITS-1:0] reg_branch_target; 
output reg [ADDRESS_BITS-1:0] reg_JAL_target;

output reg [ADDRESS_BITS-1:0] reg_inst_PC;  


always @ (posedge clock) begin

	reg_rs1_data <= rs1_data;
	reg_rs2_data <= rs2_data;
	reg_rd <= rd;  
	reg_opcode <= opcode;
	reg_funct7 <= funct7; 
	reg_funct3 <= funct3;
	reg_extend_imm <= extend_imm;
	reg_branch_target <= branch_target; 
	reg_JAL_target <= JAL_target;
        reg_inst_PC <= inst_PC;



end




endmodule
