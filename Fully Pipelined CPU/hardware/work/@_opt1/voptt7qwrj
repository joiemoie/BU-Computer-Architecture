library verilog;
use verilog.vl_types.all;
entity regFile is
    generic(
        REG_DATA_WIDTH  : integer := 32;
        REG_SEL_BITS    : integer := 5
    );
    port(
        clock           : in     vl_logic;
        reset           : in     vl_logic;
        read_sel1       : in     vl_logic_vector;
        read_sel2       : in     vl_logic_vector;
        wEn             : in     vl_logic;
        write_sel       : in     vl_logic_vector;
        write_data      : in     vl_logic_vector;
        read_data1      : out    vl_logic_vector;
        read_data2      : out    vl_logic_vector
    );
end regFile;
