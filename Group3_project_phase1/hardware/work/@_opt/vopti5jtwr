library verilog;
use verilog.vl_types.all;
entity BSRAM is
    generic(
        CORE            : integer := 0;
        DATA_WIDTH      : integer := 32;
        ADDR_WIDTH      : integer := 8
    );
    port(
        clock           : in     vl_logic;
        reset           : in     vl_logic;
        readEnable      : in     vl_logic;
        readAddress     : in     vl_logic_vector;
        readData        : out    vl_logic_vector;
        writeEnable     : in     vl_logic;
        writeAddress    : in     vl_logic_vector;
        writeData       : in     vl_logic_vector;
        \report\        : in     vl_logic
    );
end BSRAM;
