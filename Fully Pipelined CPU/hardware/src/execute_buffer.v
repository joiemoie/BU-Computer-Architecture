module execute_buffer #(parameter CORE = 0, DATA_WIDTH = 32, INDEX_BITS = 6, 
                     OFFSET_BITS = 3, ADDRESS_BITS = 20)(
	clock,        
	ALU_result, zero, branch, 
        JALR_target,

        memRead, memWrite, rs2_data, regWrite, rd,
	branch_target,
	next_PC_sel,
	JAL_target,

        reg_ALU_result, reg_zero, reg_branch, 
        reg_JALR_target,

        reg_memRead, reg_memWrite, reg_rs2_data, reg_regWrite, reg_rd,
	reg_branch_target, reg_next_PC_sel, reg_JAL_target
); 

input zero, branch, regWrite, clock; 
input [DATA_WIDTH-1:0] ALU_result;
input [ADDRESS_BITS-1:0] JALR_target;

input memRead, memWrite;
input [31:0] rs2_data;
input [4:0] rd;
input [ADDRESS_BITS-1:0] branch_target; 
input [1:0] next_PC_sel;
input [ADDRESS_BITS-1: 0] JAL_target;   

output reg reg_zero, reg_branch; 
output reg [DATA_WIDTH-1:0] reg_ALU_result;
output reg [ADDRESS_BITS-1:0] reg_JALR_target;

output reg reg_memRead, reg_memWrite, reg_regWrite;
output reg [31:0] reg_rs2_data;
output reg [4:0] reg_rd;
output reg [ADDRESS_BITS-1:0] reg_branch_target; 
output reg [1:0] reg_next_PC_sel;
output reg [ADDRESS_BITS-1: 0] reg_JAL_target;   

always @ (posedge clock) begin
     reg_zero <= zero;
     reg_branch <= branch;
     reg_ALU_result <= ALU_result;
     reg_JALR_target <= JALR_target;
     reg_memRead <= memRead;
     reg_rs2_data <= rs2_data;
     reg_regWrite <= regWrite;
     reg_rd <= rd;
     reg_branch_target<= branch_target;
     reg_next_PC_sel<= next_PC_sel;
     reg_JAL_target <= JAL_target;
end




endmodule
