/** @module : execute_pipe_unit
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

// A separate pipeline for the MULT unit
module MULT_pipe_unit #(parameter  DATA_WIDTH = 32,
                             ADDRESS_BITS = 20)(

    input clock, reset,
    input MULT_ready,
    input [DATA_WIDTH-1:0]   ALU_result_execute,
    input [4:0]   rd_execute,

    input regWrite_execute,
    output [DATA_WIDTH-1:0]   ALU_result_writeback,
    output [4:0]   rd_writeback,
    output regWrite_writeback,
    output reg MULT_writeback_ready
    );
    
reg  [DATA_WIDTH-1:0]   ALU_result_execute_to_writeback;  
reg  [4:0]   rd_execute_to_writeback;  
reg  regWrite_execute_to_writeback;

assign ALU_result_writeback    = ALU_result_execute_to_writeback;
assign rd_writeback    = rd_execute_to_writeback;       
assign regWrite_writeback      = regWrite_execute_to_writeback;
    
initial begin
  MULT_writeback_ready = 0;
end

//The MULT pipe takes 2 cycles so that ALU does not intersect with MULT at writeback
always @(posedge clock) begin
   if(reset) begin    
      ALU_result_execute_to_writeback    <= {DATA_WIDTH{1'b0}};
      rd_execute_to_writeback    <= {5{1'b0}};
      regWrite_execute_to_writeback      <= 1'b0;
   end 
   else begin
      if (MULT_writeback_ready == 1) begin
	MULT_writeback_ready <= 0;
      end
      else if (MULT_ready) begin
	MULT_writeback_ready <= 1;
      	ALU_result_execute_to_writeback    <= ALU_result_execute; 
      	rd_execute_to_writeback    <=    rd_execute; 
      	regWrite_execute_to_writeback      <= regWrite_execute;
      end
   end
end    
endmodule
