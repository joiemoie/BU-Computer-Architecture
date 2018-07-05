module control_unit_buffer #(parameter CORE = 0)(
    clock,
    branch_op,
    memRead,
    memtoReg, 
    ALUOp,
    memWrite,
    next_PC_sel,
    operand_A_sel, 
    operand_B_sel, 
    extend_sel,
    regWrite,


    reg_branch_op,
    reg_memRead,
    reg_memtoReg, 
    reg_ALUOp,
    reg_memWrite,
    reg_next_PC_sel,
    reg_operand_A_sel, 
    reg_operand_B_sel,
    reg_extend_sel,
    reg_regWrite
); 

    input branch_op;
    input memRead; 
    input memtoReg; 
    input [2:0] ALUOp; 
    input memWrite;
    input [1:0] next_PC_sel;
    input [1:0] operand_A_sel; 
    input operand_B_sel; 
    input [1:0] extend_sel; 
    input regWrite;
    input clock;

    output reg reg_branch_op;
    output reg reg_memRead; 
    output reg reg_memtoReg; 
    output reg [2:0] reg_ALUOp; 
    output reg reg_memWrite;
    output reg [1:0] reg_next_PC_sel;
    output reg [1:0] reg_operand_A_sel; 
    output reg reg_operand_B_sel; 
    output reg [1:0] reg_extend_sel; 
    output reg reg_regWrite; 


always @ (posedge clock) begin
    reg_branch_op <= branch_op;
    reg_memRead <= memRead; 
    reg_memtoReg <= memtoReg; 
    reg_ALUOp <= ALUOp; 
    reg_memWrite <= memWrite;
    reg_next_PC_sel <= next_PC_sel;
    reg_operand_A_sel <= operand_A_sel; 
    reg_operand_B_sel <= operand_B_sel; 
    reg_extend_sel <= extend_sel; 
    reg_regWrite <= regWrite;  
end




endmodule
