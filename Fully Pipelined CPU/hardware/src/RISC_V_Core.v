/** @module : RISC_V_Core
 *  @author : Adaptive & Secure Computing Systems (ASCS) Laboratory
 
 *  Copyright (c) 2018 BRISC-V (ASCS/ECE/BU)
 *  Permission is hereby granted, free of charge, to any person obtaining a copy
 *  of this software and associated documentation files (the "Software"), to deal
 *  in the Software without restriction, including without limitation the rights
 *  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 *  copies of the Software, and to permit persons to whom the Software is
 *  furnished to do so, subject to the following conditions:
 *  The above copyright notice and this permission notice shall be included in
 *  all copies or substantial portions of the Software.

 *  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 *  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 *  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 *  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 *  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 *  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 *  THE SOFTWARE.
 *
 */

module RISC_V_Core #(parameter CORE = 0, DATA_WIDTH = 32, INDEX_BITS = 6, 
                     OFFSET_BITS = 3, ADDRESS_BITS = 20)(
    clock, 
    reset, 
    start,
    prog_address, 
      
    from_peripheral,
    from_peripheral_data, 
    from_peripheral_valid, 
    to_peripheral,
    to_peripheral_data, 
    to_peripheral_valid,
            
    report 
); 

input  clock, reset, start; 
input  [ADDRESS_BITS - 1:0]  prog_address; 

// For I/O funstions
input  [1:0]   from_peripheral;
input  [31:0]  from_peripheral_data; 
input          from_peripheral_valid;
output [1:0]   to_peripheral;
output [31:0]  to_peripheral_data; 
output         to_peripheral_valid;

input  report; // performance reporting

wire [31:0]  instruction;
wire [ADDRESS_BITS-1: 0] inst_PC;
wire i_valid, i_ready;
wire d_valid, d_ready;

wire [ADDRESS_BITS-1: 0] JAL_target;   
wire [ADDRESS_BITS-1: 0] JALR_target;   
wire [ADDRESS_BITS-1: 0] branch_target; 

wire  write;
wire  [4:0]  write_reg;    
wire  [DATA_WIDTH-1:0] write_data; 

wire [DATA_WIDTH-1:0]  rs1_data; 
wire [DATA_WIDTH-1:0]  rs2_data;
wire [4:0]   rd;  

wire [6:0]  opcode;
wire [6:0]  funct7; 
wire [2:0]  funct3;

wire memRead; 
wire memtoReg;
wire [2:0] ALUOp;
wire branch_op;
wire [1:0] next_PC_sel;
wire [1:0] operand_A_sel; 
wire operand_B_sel; 
wire [1:0] extend_sel; 
wire [DATA_WIDTH-1:0]  extend_imm;
    
wire memWrite;
wire regWrite;

wire branch;
wire [DATA_WIDTH-1:0]   ALU_result; 


wire ALU_branch; 
wire zero; // Have not done anything with this signal

wire [DATA_WIDTH-1:0]    memory_data;
wire [ADDRESS_BITS-1: 0] memory_addr; // To use to check the address coming out the memory stage

reg  [1:0]   to_peripheral;
reg  [31:0]  to_peripheral_data; 
reg          to_peripheral_valid;

wire [ADDRESS_BITS-1: 0] e_JALR_target;
wire [ADDRESS_BITS-1:0] e_branch_target; 
wire [1:0] e_next_PC_sel;
wire [ADDRESS_BITS-1: 0] e_JAL_target;
wire e_branch;

fetch_unit #(CORE, DATA_WIDTH, INDEX_BITS, OFFSET_BITS, ADDRESS_BITS) IF (
        .clock(clock), 
        .reset(reset), 
        .start(start), 
        
        .PC_select(e_next_PC_sel),
        .program_address(prog_address), 
        .JAL_target(e_JAL_target),
        .JALR_target(e_JALR_target),
        .branch(e_branch), 
        .branch_target(e_branch_target), 
        
        .instruction(instruction), 
        .inst_PC(inst_PC),
        .valid(i_valid),
        .ready(i_ready),
        
        .report(report)
);

wire [DATA_WIDTH-1:0]  f_instruction;
wire [ADDRESS_BITS-1: 0] f_inst_PC;
wire f_i_valid, f_i_ready;

fetch_buffer #(CORE, DATA_WIDTH, INDEX_BITS, OFFSET_BITS, ADDRESS_BITS) IFB (
	.clock(clock),        
	.instruction(instruction),
        .inst_PC(inst_PC),
        .valid(i_valid),
        .ready(i_ready),
        .reg_instruction(f_instruction),
        .reg_inst_PC(f_inst_PC),
        .reg_valid(f_i_valid),
        .reg_ready(f_i_ready)
);
      
decode_unit #(CORE, ADDRESS_BITS) ID (
        .clock(clock), 
        .reset(reset),  
        
        .instruction(f_instruction), 
        .PC(f_inst_PC),
        .extend_sel(extend_sel),
        .write(write), 
        .write_reg(write_reg), 
        .write_data(write_data), 
      
        .opcode(opcode), 
        .funct3(funct3), 
        .funct7(funct7),
        .rs1_data(rs1_data), 
        .rs2_data(rs2_data), 
        .rd(rd), 
 
        .extend_imm(extend_imm),
        .branch_target(branch_target), 
        .JAL_target(JAL_target),
        
        .report(report)
);

wire [31:0] d_rs1_data; 
wire [31:0] d_rs2_data;
wire [4:0] d_rd;  
wire [6:0] d_opcode;
wire [6:0] d_funct7; 
wire [2:0] d_funct3;
wire [31:0] d_extend_imm;
wire [ADDRESS_BITS-1:0] d_branch_target; 
wire [ADDRESS_BITS-1:0] d_JAL_target;
wire [ADDRESS_BITS-1:0] d_inst_PC;  
//wire d_stall;
decode_buffer #(CORE) DB (
	.clock(clock),
	//.stall(stall),	
	.rs1_data(rs1_data),
	.rs2_data(rs1_data),
	.rd(rd),  
	.opcode(opcode),
	.funct7(funct7), 
	.funct3(funct3),
	.extend_imm(extend_imm),
	.branch_target(branch_target), 
	.JAL_target(JAL_target),
	.inst_PC(f_inst_PC),

	//.reg_stall(d_stall);
	.reg_rs1_data(d_rs1_data), 
	.reg_rs2_data(d_rs2_data),
	.reg_rd(d_rd),  
	.reg_opcode(d_opcode),
	.reg_funct7(d_funct7), 
	.reg_funct3(d_funct3),
	.reg_extend_imm(d_extend_imm),
	.reg_branch_target(d_branch_target), 
	.reg_JAL_target(d_JAL_target),
	.reg_inst_PC(d_inst_PC)
);

control_unit #(CORE) CU (
        .clock(clock), 
        .reset(reset),   
        
        .opcode(opcode),
        .branch_op(branch_op), 
        .memRead(memRead), 
        .memtoReg(memtoReg), 
        .ALUOp(ALUOp), 
        .memWrite(memWrite), 
        .next_PC_sel(next_PC_sel), 
        .operand_A_sel(operand_A_sel), 
        .operand_B_sel(operand_B_sel),
        .extend_sel(extend_sel),        
        .regWrite(regWrite), 
        
        .report(report)
);

    wire cu_branch_op;
    wire cu_memRead; 
    wire cu_memtoReg; 
    wire [2:0] cu_ALUOp; 
    wire cu_memWrite;
    wire [1:0] cu_next_PC_sel;
    wire [1:0] cu_operand_A_sel; 
    wire cu_operand_B_sel; 
    wire [1:0] cu_extend_sel; 
    wire cu_regWrite;

control_unit_buffer #(CORE) CUB (
    .clock(clock),
    .branch_op(branch_op),
    .memRead(memRead),
    .memtoReg(memtoReg), 
    .ALUOp(ALUOp),
    .memWrite(memWrite),
    .next_PC_sel(next_PC_sel),
    .operand_A_sel(operand_A_sel), 
    .operand_B_sel(operand_B_sel), 
    .extend_sel(extend_sel),
    .regWrite(regWrite),

    .reg_branch_op(cu_branch_op),
    .reg_memRead(cu_memRead),
    .reg_memtoReg(cu_memtoReg), 
    .reg_ALUOp(cu_ALUOp),
    .reg_memWrite(cu_memWrite),
    .reg_next_PC_sel(cu_next_PC_sel),
    .reg_operand_A_sel(cu_operand_A_sel), 
    .reg_operand_B_sel(cu_operand_B_sel), 
    .reg_extend_sel(cu_extend_sel),
    .reg_regWrite(cu_regWrite)
);


execution_unit #(CORE, DATA_WIDTH, ADDRESS_BITS) EU (
        .clock(clock), 
        .reset(reset), 
        
        .ALU_Operation(cu_ALUOp), 
        .funct3(d_funct3), 
        .funct7(d_funct7),
        .branch_op(cu_branch_op),
        .PC(d_inst_PC), 
        .ALU_ASrc(cu_operand_A_sel),
        .ALU_BSrc(cu_operand_B_sel),
        .regRead_1(d_rs1_data), 
        .regRead_2(d_rs2_data), 
        .extend(d_extend_imm), 
        .ALU_result(ALU_result), 
        .zero(zero), 
        .branch(branch),
        .JALR_target(JALR_target),
        
        .report(report)
);

wire e_zero, e_memRead, e_memWrite, e_regWrite;
wire [31:0] e_rs2_data;
wire [4:0] e_rd;
wire [DATA_WIDTH-1:0]   e_ALU_result; 


execute_buffer #(CORE, DATA_WIDTH, INDEX_BITS, OFFSET_BITS, ADDRESS_BITS) EB (
	.clock(clock),        
	.ALU_result(ALU_result),
        .zero(zero),
        .branch(branch),
        .JALR_target(JALR_target),
	.memRead(cu_memRead),
	.memWrite(cu_memWrite),
	.rs2_data(d_rs2_data),
	.regWrite(cu_regWrite),
	.rd(d_rd),
	.branch_target(branch_target), 
        .next_PC_sel(next_PC_sel),
	.JAL_target,
        .reg_ALU_result(e_ALU_result),
        .reg_zero(e_zero),
        .reg_branch(e_branch),
        .reg_JALR_target(e_JALR_target),
	.reg_memRead(e_memRead),
	.reg_memWrite(e_memWrite),
	.reg_rs2_data(e_rs2_data),
	.reg_regWrite(e_regWrite),
	.reg_rd(e_rd),
	.reg_branch_target(e_branch_target),
    	.reg_next_PC_sel(e_next_PC_sel),
	.reg_JAL_target(e_JAL_target)
);

wire [ADDRESS_BITS-1:0] generated_addr = e_ALU_result; // the case the address is not 32-bit

memory_unit #(CORE, DATA_WIDTH, INDEX_BITS, OFFSET_BITS, ADDRESS_BITS) MU (
        .clock(clock), 
        .reset(reset), 
        
        .load(e_memRead), 
        .store(e_memWrite),
        .address(generated_addr), 
        .store_data(e_rs2_data),
        .data_addr(memory_addr), 
        .load_data(memory_data),
        .valid(d_valid),
        .ready(d_ready),
        .report(report)
); 


wire [ADDRESS_BITS-1:0] m_data_addr;
wire [DATA_WIDTH-1:0]   m_load_data;
wire m_valid;
wire m_ready, m_regWrite, m_memRead;
wire [4:0] m_rd;
wire [DATA_WIDTH-1:0] m_ALU_result;

memory_buffer #(CORE, DATA_WIDTH, INDEX_BITS, OFFSET_BITS, ADDRESS_BITS) MB (
	.clock(clock),        
	.data_addr(memory_addr),
	.load_data(memory_data),
	.valid(d_valid),
	.ready(d_ready),
	.regWrite(e_regWrite),
	.memRead(e_memRead),
	.rd(e_rd),
	.ALU_result(e_ALU_result),
	.reg_data_addr(m_data_addr),
	.reg_load_data(m_load_data),
	.reg_valid(m_valid),
	.reg_ready(m_ready),
	.reg_regWrite(m_regWrite),
	.reg_memRead(m_memRead),
	.reg_rd(m_rd),
	.reg_ALU_result(m_ALU_result)
);

writeback_unit #(CORE, DATA_WIDTH) WB (
        .clock(clock), 
        .reset(reset),   
        
        .opWrite(m_regWrite),
        .opSel(m_memRead), 
        .opReg(m_rd), 
        .ALU_Result(m_ALU_result), 
        .memory_data(m_load_data), 
        .write(write), 
        .write_reg(write_reg), 
        .write_data(write_data), 
        
        .report(report)
); 


//Registers s1-s11 [$9,$x18-$x27] are saved across calls ... Using s1-s9 [$9,x18-x25] for final results
always @ (posedge clock) begin        
         if (write && (((write_reg >= 18) && (write_reg <= 25))|| (write_reg == 9)))  begin
              to_peripheral       <= 0;
              to_peripheral_data  <= write_data; 
              to_peripheral_valid <= 1;
              $display (" Core [%d] Register [%d] Value = %d", CORE, write_reg, write_data);
         end
         else to_peripheral_valid <= 0;  
end
    
endmodule
