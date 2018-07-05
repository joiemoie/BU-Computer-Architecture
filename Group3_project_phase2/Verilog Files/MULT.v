/** @module : ALU
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
 */

module MULT #(parameter DATA_WIDTH = 32)(
		clock,
		select, 
		operand_A, operand_B, 
		MULT_result, MULT_ready, stall_ALU, stall_MULT
); 
input select, clock; 
input [DATA_WIDTH-1:0]  operand_A ;
input [DATA_WIDTH-1:0]  operand_B ;
output [DATA_WIDTH-1:0] MULT_result;
output MULT_ready;
output stall_ALU;
output stall_MULT;
reg [2:0] cycles;
reg [DATA_WIDTH-1:0] reg_operand_A;
reg [DATA_WIDTH-1:0] reg_operand_B;
initial begin
	cycles = 0;
end

//assigns when the MULT calculation is ready
assign MULT_ready = (cycles==3);

//The stall signal for ALU so that ALU and MULT do not provide results at the same time
assign stall_ALU = (cycles == 2);

//The stall signal for the MULT
assign stall_MULT = (select & cycles == 0 | cycles < 2 & cycles >= 1);

//Assigns the result on the 3rd cycle
assign MULT_result   = 
            (cycles == 3) ? reg_operand_A * reg_operand_B: 0;           /* MULT */

always @ (posedge clock) begin
  
  //sets the cycle count when the MULT unit is first selected
	if (select & cycles == 0) begin
        cycles = 1;
	reg_operand_A = operand_A;
	reg_operand_B = operand_B;
        end
	else if (cycles > 0 && cycles < 3) cycles = cycles + 1;
	else if (cycles == 3) cycles = 0;
	else cycles = cycles;
end
endmodule
