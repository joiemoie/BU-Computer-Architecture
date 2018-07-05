/** @module : fetch_pipe_unit
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

module fetch_pipe_unit #(parameter  DATA_WIDTH = 32,
                          ADDRESS_BITS = 20)(
    input clock, reset, stall, 
    input  [1:0] PC_select,                   
    input  [DATA_WIDTH-1:0]   instruction_fetch,
    input  [ADDRESS_BITS-1:0] inst_PC_fetch,
    output [DATA_WIDTH-1:0]   instruction_decode,
    output [ADDRESS_BITS-1:0] inst_PC_decode
    );


reg [DATA_WIDTH-1:0]   instruction_fetch_to_decode;   
reg [ADDRESS_BITS-1:0] inst_PC_fetch_to_decode;

wire [DATA_WIDTH-1:0] instruction_select_mux =  (PC_select == 2'b10)? {DATA_WIDTH{1'b0}} : instruction_fetch;


assign instruction_decode =  instruction_fetch_to_decode;
assign inst_PC_decode     =  inst_PC_fetch_to_decode;

always @(posedge clock) begin
    if(reset) begin
        instruction_fetch_to_decode <= 32'h00000013;
        inst_PC_fetch_to_decode     <= {ADDRESS_BITS{1'b0}};
    end
    else begin
        instruction_fetch_to_decode <=  instruction_select_mux;
        inst_PC_fetch_to_decode     <=  inst_PC_fetch;   
    end
end   
    
    
endmodule
