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
	stall_in,
	prog_address, 
	  
	from_peripheral,
	from_peripheral_data, 
	from_peripheral_valid, 
	to_peripheral,
	to_peripheral_data, 
	to_peripheral_valid,
			
	report 
); 

input  clock, reset, start, stall_in; 
input  [ADDRESS_BITS - 1:0]  prog_address; 

// For I/O funstions
input  [1:0]   from_peripheral;
input  [31:0]  from_peripheral_data; 
input          from_peripheral_valid;
output [1:0]   to_peripheral;
output [31:0]  to_peripheral_data; 
output         to_peripheral_valid;

input  report; // performance reporting

wire [31:0]  instruction_fetch;
wire [31:0]  instruction_decode;
wire [ADDRESS_BITS-1: 0] inst_PC_fetch;
wire [ADDRESS_BITS-1: 0] inst_PC_decode;
wire i_valid, i_ready;
wire d_valid, d_ready;
wire [4:0] rs1_decode;
wire [4:0] rs2_decode;
wire stall;
wire [ADDRESS_BITS-1: 0] JAL_target_decode;
wire [ADDRESS_BITS-1: 0] JAL_target_execute; 
wire [ADDRESS_BITS-1: 0] JAL_target_memory;      
wire [ADDRESS_BITS-1: 0] JALR_target_execute;  
wire [ADDRESS_BITS-1: 0] JALR_target_memory;   
wire [ADDRESS_BITS-1: 0] branch_target_decode; 
wire [ADDRESS_BITS-1: 0] branch_target_execute; 
wire [ADDRESS_BITS-1: 0] branch_target_memory; 

wire  write_writeback;
wire  write_fetch;
wire  [4:0]  write_reg_writeback;   
wire  [4:0]  write_reg_fetch;  
wire  [DATA_WIDTH-1:0] write_data_writeback; 
wire  [DATA_WIDTH-1:0] write_data_fetch; 

wire [DATA_WIDTH-1:0]  rs1_data_decode; 
wire [DATA_WIDTH-1:0]  rs2_data_decode;
wire [4:0]   rd_decode;  
wire [6:0]  opcode_decode;
wire [6:0]  funct7_decode; 
wire [2:0]  funct3_decode;

wire [DATA_WIDTH-1:0]  rs1_data_execute; 
wire [DATA_WIDTH-1:0]  rs2_data_execute;
wire [DATA_WIDTH-1:0]  rs2_data_memory;
wire [4:0]   rd_execute;  

wire [ADDRESS_BITS-1: 0] PC_execute;
wire [6:0]  opcode_execute;
wire [6:0]  funct7_execute; 
wire [2:0]  funct3_execute;

wire memRead_decode; 
wire memRead_execute; 

wire memRead_memory;
wire memRead_writeback;
wire [4:0]  rd_memory; 
wire [4:0]  rd_writeback;
wire memtoReg;
wire [2:0] ALUOp_decode;
wire [2:0] ALUOp_execute;
wire branch_op_decode;
wire branch_op_execute;
wire [1:0] next_PC_sel_decode;
wire [1:0] next_PC_sel_execute;
wire [1:0] next_PC_sel_memory;
wire [1:0] operand_A_sel_decode; 
wire [1:0] operand_A_sel_execute; 
wire operand_B_sel_decode; 
wire operand_B_sel_execute; 
wire [1:0] extend_sel_decode;  
wire [DATA_WIDTH-1:0]  extend_imm_decode;
wire [DATA_WIDTH-1:0]  extend_imm_execute;

wire memWrite_decode;	
wire memWrite_execute;
wire memWrite_memory;
wire regWrite_execute;
wire regWrite_memory;
wire regWrite_writeback;
wire regWrite_fetch;

wire branch_execute;
wire branch_memory;
wire [DATA_WIDTH-1:0]   ALU_result_execute; 
wire [DATA_WIDTH-1:0]   ALU_result_memory;
wire [DATA_WIDTH-1:0]   ALU_result_writeback;
wire [ADDRESS_BITS-1:0] generated_addr = ALU_result_memory; // the case the address is not 32-bit


wire zero; // Have not done anything with this signal

wire [DATA_WIDTH-1:0]    memory_data_memory;
wire [DATA_WIDTH-1:0]    memory_data_writeback;
wire [ADDRESS_BITS-1: 0] memory_addr; // To use to check the address coming out the memory stage

reg  [1:0]   to_peripheral;
reg  [31:0]  to_peripheral_data; 
reg          to_peripheral_valid;

fetch_unit #(CORE, DATA_WIDTH, INDEX_BITS, OFFSET_BITS, ADDRESS_BITS) IF (
        .clock(clock), 
		.reset(reset), 
		.start(start), 
		.stall(stall),
        .PC_select(next_PC_sel_decode),
        .program_address(), 
        .JAL_target(JAL_target_decode),
        .JALR_target(JALR_target_execute),
		.branch(branch_execute), 
        .branch_target(branch_target_execute), 
        
        .instruction(instruction_fetch), 
        .inst_PC(inst_PC_fetch),
		.valid(i_valid),
		.ready(i_ready),
		
        .report(report)
); 

fetch_pipe_unit #(DATA_WIDTH, ADDRESS_BITS) IF_ID(
        .clock(clock),
        .reset(reset),       
        .stall(stall),
        .PC_select(next_PC_sel_decode),
        .instruction_fetch(instruction_fetch),
        .inst_PC_fetch(inst_PC_fetch),
        
        .instruction_decode(instruction_decode),     
        .inst_PC_decode(inst_PC_decode)      
 );
	  
decode_unit #(CORE, ADDRESS_BITS) ID (
        .clock(clock), 
		.reset(reset),  
		
        .instruction(instruction_decode), 
        .PC(inst_PC_decode),
		.extend_sel(extend_sel_decode),
	    .write(write_writeback), 
		.write_reg(write_reg_writeback), 
		.write_data(write_data_writeback), 
	  
	    .opcode(opcode_decode), 
		.funct3(funct3_decode), 
		.funct7(funct7_decode),
	    .rs1_data(rs1_data_decode), 
		.rs2_data(rs2_data_decode), 
		.rd(rd_decode), 
 
		.extend_imm(extend_imm_decode),
        .branch_target(branch_target_decode), 
        .JAL_target(JAL_target_decode),
	    .rs1(rs1_decode),  
		.rs2(rs2_decode),
        .report(report)
); 


wire stall_MULT, stall_ALU;

stall_control_unit ID_S (
        .clock(clock),
	.funct7(funct7_decode),
	.ALU_op(ALUOp_decode),
	.stall_ALU(stall_ALU),
	.stall_MULT(stall_MULT),
        .rs1(rs1_decode),
        .rs2(rs2_decode),
        .regwrite_Decode(regWrite_decode),         
        .regwrite_Execute(regWrite_execute),    
        .regwrite_Memory(regWrite_memory),     
        .regwrite_Writeback(regWrite_writeback), 
        .rd_Execute(rd_execute),     
        .rd_Memory(rd_memory),      
        .rd_Writeback(rd_writeback),   
        .write_reg_fetch(write_reg_fetch), 
        
        .stall_needed(stall)       
);

control_unit #(CORE) CU (
        .clock(clock), 
		.reset(reset),   
        
	    .opcode(opcode_decode),
		.branch_op(branch_op_decode), 
		.memRead(memRead_decode), 
		.memtoReg(memtoReg), 
		.ALUOp(ALUOp_decode), 
		.memWrite(memWrite_decode), 
		.next_PC_sel(next_PC_sel_decode), 
		.operand_A_sel(operand_A_sel_decode), 
		.operand_B_sel(operand_B_sel_decode),
        .extend_sel(extend_sel_decode),		
		.regWrite(regWrite_decode), 
		
        .report(report)
);

decode_pipe_unit #(DATA_WIDTH, ADDRESS_BITS) ID_EU(
        .clock(clock),
        .reset(reset), 
        .stall(stall),      
        .rs1_data_decode(rs1_data_decode),
        .rs2_data_decode(rs2_data_decode),
        .funct7_decode(funct7_decode),
        .funct3_decode(funct3_decode),
        .rd_decode(rd_decode),    
        .opcode_decode(opcode_decode),
        .extend_imm_decode(extend_imm_decode),
        .branch_target_decode(branch_target_decode),
        .JAL_target_decode(JAL_target_decode),
        .PC_decode(inst_PC_decode),
        .branch_op_decode(branch_op_decode),
        .memRead_decode(memRead_decode),
        .ALUOp_decode(ALUOp_decode),
        .memWrite_decode(memWrite_decode),
        .next_PC_sel_decode(next_PC_sel_decode),
        .operand_A_sel_decode(operand_A_sel_decode),
        .operand_B_sel_decode(operand_B_sel_decode),
        .regWrite_decode(regWrite_decode),
        
        .rs1_data_execute(rs1_data_execute),
        .rs2_data_execute(rs2_data_execute),
        .funct7_execute(funct7_execute),
        .funct3_execute(funct3_execute),
        .rd_execute(rd_execute),                          
        .opcode_execute(opcode_execute),
        .extend_imm_execute(extend_imm_execute),          
        .branch_target_execute(branch_target_execute),    
        .JAL_target_execute(JAL_target_execute),          
        .PC_execute(PC_execute),
        .branch_op_execute(branch_op_execute),
        .memRead_execute(memRead_execute),
        .ALUOp_execute(ALUOp_execute),
        .memWrite_execute(memWrite_execute),
        .next_PC_sel_execute(next_PC_sel_execute),
        .operand_A_sel_execute(operand_A_sel_execute),
        .operand_B_sel_execute(operand_B_sel_execute),
        .regWrite_execute(regWrite_execute)
);


wire MULT_ready;
execution_unit #(CORE, DATA_WIDTH, ADDRESS_BITS) EU (
        .clock(clock), 
		.reset(reset), 
		.stall(stall),
		
		.ALU_Operation(ALUOp_execute), 
		.funct3(funct3_execute), 
		.funct7(funct7_execute),
		.branch_op(branch_op_execute),
		.PC(PC_execute), 
		.ALU_ASrc(operand_A_sel_execute),
		.ALU_BSrc(operand_B_sel_execute),
		.regRead_1(rs1_data_execute), 
		.regRead_2(rs2_data_execute), 
		.extend(extend_imm_execute), 
		.ALU_result(ALU_result_execute), 
		.zero(zero), 
		.branch(branch_execute),
		.JALR_target(JALR_target_execute),
		.stall_ALU(stall_ALU),
		.stall_MULT(stall_MULT),
		.MULT_ready(MULT_ready),
		
        .report(report)
);

execute_pipe_unit #(DATA_WIDTH, ADDRESS_BITS) EU_MU(
        .clock(clock), 
        .reset(reset), 
        .ALU_result_execute(ALU_result_execute), 
        .store_data_execute(rs2_data_execute),       
        .JAL_target_execute(JAL_target_execute),  
        .JALR_target_execute(JALR_target_execute),
        .rd_execute(rd_execute),
        .branch_execute(branch_execute),  
        .memWrite_execute(memWrite_execute),    
        .memRead_execute(memRead_execute),    
        .next_PC_sel_execute(next_PC_sel_execute),
        .regWrite_execute(regWrite_execute),
        .branch_target_execute(branch_target_execute),    

        
        .ALU_result_memory(ALU_result_memory), 
        .store_data_memory(rs2_data_memory),       
        .JAL_target_memory(JAL_target_memory),  
        .JALR_target_memory(JALR_target_memory),
        .rd_memory(rd_memory),
        .branch_memory(branch_memory),  
        .memWrite_memory(memWrite_memory),    
        .memRead_memory(memRead_memory),
        .next_PC_sel_memory(next_PC_sel_memory),   
        .regWrite_memory(regWrite_memory),
        .branch_target_memory(branch_target_memory)    

);

wire [DATA_WIDTH-1:0]   ALU_result_MULT;
wire [4:0] rd_MULT;
wire regWrite_MULT;
wire MULT_writeback_ready;

MULT_pipe_unit #(DATA_WIDTH, ADDRESS_BITS) MULT_MU(
        .clock(clock), 
        .reset(reset),
	.MULT_ready(MULT_ready),
        .ALU_result_execute(ALU_result_execute), 
        .rd_execute(rd_execute),            
        .regWrite_execute(regWrite_execute),  
       
        .ALU_result_writeback(ALU_result_MULT), 
        .rd_writeback(rd_MULT),       
        .regWrite_writeback(regWrite_MULT),
	.MULT_writeback_ready(MULT_writeback_ready)

);

memory_unit #(CORE, DATA_WIDTH, INDEX_BITS, OFFSET_BITS, ADDRESS_BITS) MU (
        .clock(clock), 
		.reset(reset), 
		
        .load(memRead_memory), 
		.store(memWrite_memory),
        .address(generated_addr), 
        .store_data(rs2_data_memory),
        .data_addr(memory_addr), 
        .load_data(memory_data_memory),
		.valid(d_valid),
		.ready(d_ready),
		
        .report(report)
); 
memory_pipe_unit #(DATA_WIDTH, ADDRESS_BITS) MU_WB(
    
         .clock(clock), 
         .reset(reset),
         
         .ALU_result_memory(ALU_result_memory), 
         .load_data_memory(memory_data_memory),
         .opwrite_memory(regWrite_memory),
         .opsel_memory(memRead_memory),
         .opReg_memory(rd_memory),
         
         .ALU_result_writeback(ALU_result_writeback), 
         .load_data_writeback(memory_data_writeback),
         .opwrite_writeback(regWrite_writeback),     
         .opsel_writeback(memRead_writeback),       
         .opReg_writeback(rd_writeback)
             
);

//Determines whether the writeback data comes from the ALU or MULT unit
wire regWrite_select = (MULT_writeback_ready)?regWrite_MULT: regWrite_writeback;
wire [4:0] rd_select =(MULT_writeback_ready)?rd_MULT:rd_writeback;
wire [DATA_WIDTH-1:0] ALU_result_select =(MULT_writeback_ready)?ALU_result_MULT:ALU_result_writeback;
writeback_unit #(CORE, DATA_WIDTH) WB (
		.clock(clock), 
		.reset(reset),   
		.stall(stall),
		
		.opWrite(regWrite_select),
		.opSel(memRead_writeback), 
		.opReg(rd_select), 
		.ALU_Result(ALU_result_select), 
		.memory_data(memory_data_writeback), 
		.write(write_writeback), 
		.write_reg(write_reg_writeback), 
		.write_data(write_data_writeback), 
		
		.report(report)
); 

writeback_pipe_unit #(DATA_WIDTH, ADDRESS_BITS) WB_IF(
        .clock(clock), 
		.reset(reset),
		
		.regWrite_writeback(regWrite_select),
		.write_reg_writeback(write_reg_writeback),
        .write_data_writeback(write_data_writeback),
        .write_writeback(write_writeback),
        
        .regWrite_fetch(regWrite_fetch),
        .write_reg_fetch(write_reg_fetch),
        .write_data_fetch(write_data_fetch),
        .write_fetch(write_fetch)
);       
//Register s2-s11 [$x18-$x27] are saved across calls ... Using s2-s9 [x18-x25] for final results
always @ (posedge clock) begin            
         //if (write && ((write_reg >= 18) && (write_reg <= 25)))  begin
		 if (write_fetch && ((write_reg_fetch >= 10) && (write_reg_fetch <= 17)))  begin
              to_peripheral       <= 0;
			  to_peripheral_data  <= write_data_fetch; 
			  to_peripheral_valid <= 1;
    		  $display (" Core [%d] Register [%d] Value = %d", CORE, write_reg_fetch, write_data_fetch);
         end
         else to_peripheral_valid <= 0;  
end


always @ (posedge clock) begin
  // Debugging 
     $display ("----------------------------------- Core %d ------------------------------------------", CORE);   
     $display ("| PC [%h]", inst_PC_fetch);
     $display ("| Instruction [%h]", instruction_fetch);
	 
     $display ("|\t\t\t| PC [%h]", inst_PC_decode);
     $display ("|\t\t\t| Reg1 Data [%h]", rs1_data_decode);		 
     $display ("|\t\t\t| Reg2 Data [%h]", rs2_data_decode);
     $display ("|\t\t\t| Destination Reg [%d]", rd_decode);
     $display ("|\t\t\t| Funct7 [%h]", funct7_decode);
     $display ("|\t\t\t| Funct3 [%h]", funct3_decode);
     $display ("|\t\t\t| Extended Imm [%h]", extend_imm_decode);
     $display ("|\t\t\t| Branch Target [%h]", branch_target_decode);
     $display ("|\t\t\t| JAL Target [%h]", JAL_target_decode);
     $display ("|\t\t\t| Branch Operation [%b]", branch_op_decode);
     $display ("|\t\t\t| Memory Read [%b]", memRead_decode);
     $display ("|\t\t\t| ALULOp [%b]", ALUOp_decode);
     $display ("|\t\t\t| Memory Write [%b]", memWrite_decode);
     $display ("|\t\t\t| Next PC Select [%b]", next_PC_sel_decode);
     $display ("|\t\t\t| Operand A Sel [%b]", operand_A_sel_decode);
     $display ("|\t\t\t| Operand B Sel [%b]", operand_B_sel_decode);
     $display ("|\t\t\t| Reg Write [%b]", regWrite_decode);
     $display ("|\t\t\t| Stall [%b]", stall);
	 
     $display ("|\t\t\t|\t\t\t| PC [%h]", PC_execute);
     $display ("|\t\t\t|\t\t\t| Reg1 Data [%h]", rs1_data_execute);		 
     $display ("|\t\t\t|\t\t\t| Reg2 Data [%h]", rs2_data_execute);
     $display ("|\t\t\t|\t\t\t| Destination Reg [%d]", rd_execute);
     $display ("|\t\t\t|\t\t\t| Funct7 [%h]", funct7_execute);
     $display ("|\t\t\t|\t\t\t| Funct3 [%h]", funct3_execute);
     $display ("|\t\t\t|\t\t\t| Extended Imm [%h]", extend_imm_execute);
     $display ("|\t\t\t|\t\t\t| Branch Target [%h]", branch_target_execute);
     $display ("|\t\t\t|\t\t\t| JAL Target [%h]", JAL_target_execute);
     $display ("|\t\t\t|\t\t\t| Branch Operation [%b]", branch_op_execute);
     $display ("|\t\t\t|\t\t\t| Memory Read [%b]", memRead_execute);
     $display ("|\t\t\t|\t\t\t| ALULOp [%b]", ALUOp_execute);
     $display ("|\t\t\t|\t\t\t| Memory Write [%b]", memWrite_execute);
     $display ("|\t\t\t|\t\t\t| Next PC Select [%b]",next_PC_sel_execute);
     $display ("|\t\t\t|\t\t\t| Operand A Sel [%b]", operand_A_sel_execute);
     $display ("|\t\t\t|\t\t\t| Operand B Sel [%b]", operand_B_sel_execute);
     $display ("|\t\t\t|\t\t\t| Reg Write [%b]", regWrite_execute);
     $display ("|\t\t\t|\t\t\t| ALU Result [%h]", ALU_result_execute);
     $display ("|\t\t\t|\t\t\t| Branch [%b]", branch_execute);
     $display ("|\t\t\t|\t\t\t| JALR Target [%b]", JALR_target_execute);

	 
     $display ("|\t\t\t|\t\t\t|\t\t\t| Reg2 Data [%h]", rs2_data_memory);
     $display ("|\t\t\t|\t\t\t|\t\t\t| Destination Reg [%d]", rd_memory);
     $display ("|\t\t\t|\t\t\t|\t\t\t| Memory Read [%b]", memRead_memory);
     $display ("|\t\t\t|\t\t\t|\t\t\t| Memory Write [%b]", memWrite_memory);
     $display ("|\t\t\t|\t\t\t|\t\t\t| Memory Data [%h]", memory_data_memory);
	 
	 
	 
     $display ("|\t\t\t|\t\t\t|\t\t\t|\t\t\t| Destination Reg [%d]", rd_writeback);
     $display ("|\t\t\t|\t\t\t|\t\t\t|\t\t\t| Reg Write [%b]", regWrite_writeback);
     $display ("|\t\t\t|\t\t\t|\t\t\t|\t\t\t| Memory to Register [%b]", memRead_writeback);
     $display ("|\t\t\t|\t\t\t|\t\t\t|\t\t\t| ALU Result [%h]", ALU_result_writeback);
     $display ("|\t\t\t|\t\t\t|\t\t\t|\t\t\t| Memory Data [%h]", memory_data_writeback);
     $display ("|\t\t\t|\t\t\t|\t\t\t|\t\t\t| Write Signal [%b]", write_writeback);
     $display ("|\t\t\t|\t\t\t|\t\t\t|\t\t\t| Write Reg [%d]", write_reg_writeback);
     $display ("|\t\t\t|\t\t\t|\t\t\t|\t\t\t| Write Data [%h]", write_data_writeback);
     $display ("|\t\t\t|\t\t\t|\t\t\t|\t\t\t|\t\t\t| Reg Write Fetch [%b]", regWrite_fetch);
     $display ("|\t\t\t|\t\t\t|\t\t\t|\t\t\t|\t\t\t| Write Reg Fetch[%d]", write_reg_fetch);
     $display ("|\t\t\t|\t\t\t|\t\t\t|\t\t\t|\t\t\t| Write Data Fetch [%h]", write_data_fetch);
     $display ("|\t\t\t|\t\t\t|\t\t\t|\t\t\t|\t\t\t| Write Fetch [%h]", write_fetch);
     $display ("----------------------------------------------------------------------------------------");   
end
	
endmodule
