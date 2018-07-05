library verilog;
use verilog.vl_types.all;
entity BRAM is
    generic(
        DATA_WIDTH      : integer := 32;
        ADDR_WIDTH      : integer := 8
    );
    port(
        clock           : in     vl_logic;
        readEnable      : in     vl_logic;
        readAddress     : in     vl_logic_vector;
        readData        : out    vl_logic_vector;
        writeEnable     : in     vl_logic;
        writeAddress    : in     vl_logic_vector;
        writeData       : in     vl_logic_vector
    );
end BRAM;
