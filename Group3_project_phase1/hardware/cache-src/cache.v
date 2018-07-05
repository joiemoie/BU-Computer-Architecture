`timescale 1ns / 1ps

// Cache Module


module cache  #(parameter DATA_WIDTH = 32, INDEX_BITS = 6, 
                     OFFSET_BITS = 3, ADDRESS_BITS = 32)(
	clock,
	Enable,
	Read,
	Write,
	Address,
	writeData,
	update_in,
	update_Data_in,
	update_out,
	update_Data_out,
	readData,
	Hit,
	E_next
);

input clock;
input Enable;
input Read;
input Write;
input [ADDRESS_BITS-1:0] Address;		// Physical Address of the requested data
input [DATA_WIDTH-1:0] writeData;

input update_in;				// Asserted if we are writing data brought from higher-level caches
input [DATA_WIDTH-1:0] update_Data_in;

output update_out;
output [DATA_WIDTH-1:0] update_Data_out;


output reg [DATA_WIDTH-1:0] readData;
output reg Hit;					// Asserted if the data is in the cache
output reg E_next;				// Enables the higher level cache in the memory hierarchy

localparam ROWS = 1 << INDEX_BITS;
localparam BLOCKS = 1 << OFFSET_BITS;
localparam TAG_BITS = ADDRESS_BITS - INDEX_BITS - OFFSET_BITS;


reg [(BLOCKS*DATA_WIDTH-1):0] Data [0:ROWS-1];
reg Valid [0:ROWS-1];
reg Tag [0:ROWS-1];

wire [INDEX_BITS-1:0] index;
wire [TAG_BITS-1:0] tag;
wire [OFFSET_BITS-1:0] offset;


assign offset = Address[OFFSET_BITS-1:0];
assign index = Address[OFFSET_BITS+INDEX_BITS-1:OFFSET_BITS];
assign tag = Address[ADDRESS_BITS-1:OFFSET_BITS+INDEX_BITS];

integer i, j;
initial begin						// Initialize all cache values to 0
	for (i = 0; i <= ROWS; i = i+1) begin
		Valid[i] = 0;
		Tag[i] = 0;
		for (j = 0; j <= BLOCKS; j = j+1)
			Data[i][j] = 0;
	end
end


always @ (posedge clock) begin
if (update_in) begin
	Data[Address] <= update_Data_in;
end


if (Enable) begin
	begin

		if (Read) begin
			
			if (Valid[index]) begin
				if (Tag[index] == tag) begin		// Read hit
					readData <= Data[index][offset];
					Hit <= 1'b1;
					E_next <= 0;
				end
				else begin
					Hit <= 0;		// Read miss
					E_next <= 1'b1;
				end

			end
			else begin
				Hit <= 0;		// Read miss
				E_next <= 1'b1;
			end
		end
		
	
		if (Write) begin
			Valid[index] <= 1'b0; 		// Make the valid bit dirty
			E_next <= 1'b1;			// Enable next cache
		end
end
end

endmodule