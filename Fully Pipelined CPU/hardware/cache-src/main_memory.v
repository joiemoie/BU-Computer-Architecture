`timescale 1ns / 1ps

// Main Memory Module

module main_memory #(parameter DATA_WIDTH = 32, ADDR_WIDTH = 10)(
	clock,
	Enable,
	read,
	write,
	Address,
	writeData,
	readData,
	ready,
	update_out,
	update_Data
);

input clock;
input Enable;
input read;
input write;
input [ADDR_WIDTH-1:0]   Address;
input [DATA_WIDTH-1:0]   writeData;

output reg [DATA_WIDTH-1:0]  readData;
output reg ready;
output reg update_out;
output reg [DATA_WIDTH-1:0] update_Data;

localparam MEM_DEPTH = 1 << ADDR_WIDTH;

reg [DATA_WIDTH-1:0] ram [0:(1 << ADDR_WIDTH)-1];
  
always@(posedge clock) begin 
	if (Enable) begin
		if (read) begin
			readData <= ram[Address];
			update_out <= 1'b1;
			update_Data <= ram[Address];
		end
	
	        if(write) begin
	            ram[Address] <= writeData;
		    ready <= 1'b1;
    		end
	end
end
    

endmodule
