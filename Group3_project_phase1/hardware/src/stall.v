/*  @author : Adaptive & Secure Computing Systems (ASCS) Laboratory
 
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
 *  
 */

/*********************************************************************************
*                              control_unit.v                                    *
*********************************************************************************/


module stall_unit #(parameter CORE = 0)(
   // clock
    
);


    
reg [31: 0] cycles; 
always @ (posedge clock) begin 
    cycles <= reset? 0 : cycles + 1; 
    if (report)begin
        $display ("------ Core %d Control Unit - Current Cycle %d ------", CORE, cycles); 
        $display ("| Opcode      [%b]", opcode);
        $display ("| Branch_op   [%b]", branch_op);
        $display ("| memRead     [%b]", memRead);
        $display ("| memtoReg    [%b]", memtoReg);
        $display ("| memWrite    [%b]", memWrite);
        $display ("| RegWrite    [%b]", regWrite);
        $display ("| ALUOp       [%b]", ALUOp);
        $display ("| Extend_sel  [%b]", extend_sel);
        $display ("| ALUSrc_A    [%b]", operand_A_sel);
        $display ("| ALUSrc_B    [%b]", operand_B_sel);
        $display ("| Next PC     [%b]", next_PC_sel);
        $display ("----------------------------------------------------------------------");
    end
end
endmodule
