/** @module : stallControl.v                                    
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
 z
 *  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 *  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 *  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 *  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 *  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 *  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 *  THE SOFTWARE.
 *
 *  
 */

module stall_control_unit  (
    input clock,
    input [6:0] funct7,
    input [2:0] ALU_op,
    input stall_ALU,
    input stall_MULT,
    input [4:0] rs1,
    input [4:0] rs2,
    input regwrite_Decode,
    input regwrite_Execute,
    input regwrite_Memory,
    input regwrite_Writeback,
    input [4:0] rd_Execute,
    input [4:0] rd_Memory,
    input [4:0] rd_Writeback,
    input [4:0] write_reg_fetch,
      
    output stall_needed
);

reg stall;
wire stall_interupt;
              
assign stall_interupt =    
                       ((((rs1 == rd_Execute) & regwrite_Execute)           | 
                       ((rs1 == rd_Memory)  & regwrite_Memory)              |
                       ((rs1 == rd_Writeback)  & regwrite_Writeback)        |
                     //((rs1 == write_reg_fetch) & (regwrite_Decode & write_reg_fetch != 5'd0)))      |       
                       (((rs2 == rd_Execute) &  regwrite_Execute)           |
                       ((rs2 == rd_Memory)  & regwrite_Memory)              |
                       ((rs2 == rd_Writeback)  & regwrite_Writeback)        |
		       ((funct7 != 0000001) & stall_ALU)		    |
		       ((funct7 == 0000001 & ALU_op == 3'b000) & stall_MULT))))? 1:0; //		    |
                    // ((rs2 == write_reg_fetch)  & (regwrite_Decode & write_reg_fetch != 5'd0))))?  1:0;


assign stall_needed = stall_interupt | stall;

always @(posedge clock) begin 
    stall <= stall_interupt; 
end
    
endmodule
