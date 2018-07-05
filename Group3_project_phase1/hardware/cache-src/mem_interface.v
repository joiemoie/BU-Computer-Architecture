`timescale 1ns / 1ps

// Memory Interface Module


module mem_interface  #(parameter CORE = 0, DATA_WIDTH = 32, INDEX_BITS = 6, 
                     OFFSET_BITS = 3, ADDRESS_BITS = 20) (
		     clock, reset,  
                     read, write, address, in_data, 
                     out_addr, out_data, valid, ready,
                     report, m_stall
);

input clock, reset;
input read, write;						
input [ADDRESS_BITS-1:0] address;
input [DATA_WIDTH-1:0]   in_data;				
output[ADDRESS_BITS-1:0] out_addr;
output[DATA_WIDTH-1:0]   out_data;
output valid, ready;
output m_stall;


input  report; 

wire Hit_I1, Hit_L1, Hit_L2, Ready_mem;
wire [DATA_WIDTH-1:0] DataR_I1;			// Data read from the caches to be sent to CPU
wire [DATA_WIDTH-1:0] DataR_L1;			
wire [DATA_WIDTH-1:0] DataR_L2;
wire [DATA_WIDTH-1:0] DataR_Mem;

wire [DATA_WIDTH-1:0] DataWriteI1;		// Data to be written into the caches
wire [DATA_WIDTH-1:0] DataWriteL1;
wire [DATA_WIDTH-1:0] DataWriteL2;
wire [DATA_WIDTH-1:0] DataWriteMem;
wire E_I1, E_L1, E_L2, E_Mem;			// Module enable signals
wire R_I1, R_L1, R_L2, R_Mem;			// Read signals
wire W_I1, W_L1, W_L2, W_Mem;			// Write signals

wire update_L2;  				// Update output signal from L2
wire update_Mem;				// Update output signal from Mem
wire [DATA_WIDTH-1:0] update_Data_L2;		// Update output data from L2
wire [DATA_WIDTH-1:0] update_Data_Mem;		// Update output data from Mem

wire update_1;					// Update input signal for L1 and I1 (They are the same)
wire update_2;					// Update input signal for L2
wire [DATA_WIDTH-1:0] update_Data_1;
wire [DATA_WIDTH-1:0] update_Data_2;

wire Eout_I1, Eout_L1;
wire [DATA_WIDTH-1:0] Dout_I1, Dout_L1;

assign out_addr = read? address : 0; 
assign valid    = (read | write)? 1 : 0; 
assign ready    = (read | write)? 0 : 1;

assign m_stall = !((Hit_I1 && read) | (Hit_L1 | read) | (Ready_mem | write));

assign update_1 = update_L2 | update_Mem;
assign update_Data_1 = update_Mem ? update_Data_Mem : update_L2 ? update_Data_2 : 0;



cache #(DATA_WIDTH, INDEX_BITS, OFFSET_BITS, ADDRESS_BITS) I1 (
	.clock		(clock),
	.Enable		(E_I1),
	.Read		(R_I1),
	.Write		(W_I1),
	.Address	(address),
	.writeData	(DataWriteI1),
	.update_in	(update_1),
	.update_Data_in	(update_Data_1),
	.update_out	(Eout_I1),
	.update_Data_out(Dout_I1),
	.readData	(DataR_I1),
	.Hit		(Hit_I1),
	.E_next		(E_L2)
);

cache #(DATA_WIDTH, INDEX_BITS, OFFSET_BITS, ADDRESS_BITS) L1 (
	.clock		(clock),
	.Enable		(E_L1),
	.Read		(R_L1),
	.Write		(W_L1),
	.Address	(address),
	.writeData	(DataWriteL1),
	.update_in	(update_1),
	.update_Data_in	(update_Data_1),
	.update_out	(Eout_L1),
	.update_Data_out(Dout_L1),
	.readData	(DataR_L1),
	.Hit		(Hit_L1),
	.E_next		(E_L2)
);

cache #(DATA_WIDTH, INDEX_BITS, OFFSET_BITS, ADDRESS_BITS) L2 (
	.clock		(clock),
	.Enable		(E_L2),
	.Read		(R_L2),
	.Write		(W_L2),
	.Address	(address),
	.writeData	(DataWriteL2),
	.update_in	(update_Mem),
	.update_Data_in	(update_Data_Mem),
	.update_out	(update_2),
	.update_Data_out(update_Data_L2),
	.readData	(DataR_L2),
	.Hit		(Hit_L2),
	.E_next		(E_Mem)
);

main_memory #(DATA_WIDTH, ADDRESS_BITS) MEM (
	.clock 		(clock),
	.Enable		(E_Mem),
	.read		(R_Mem),
	.write		(W_Mem),
	.Address	(address),
	.writeData	(DataWriteMem),
	.readData	(DataR_Mem),
	.ready		(Ready_mem),			
	.update_out	(update_Mem),
	.update_Data	(update_Data_Mem)
);



endmodule
