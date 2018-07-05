library verilog;
use verilog.vl_types.all;
entity fetch_buffer is
    generic(
        CORE            : integer := 0;
        DATA_WIDTH      : integer := 32;
        INDEX_BITS      : integer := 6;
        OFFSET_BITS     : integer := 3;
        ADDRESS_BITS    : integer := 20
    );
    port(
        clock           : in     vl_logic;
        instruction     : in     vl_logic_vector;
        inst_PC         : in     vl_logic_vector;
        valid           : in     vl_logic;
        ready           : in     vl_logic;
        reg_instruction : out    vl_logic_vector;
        reg_inst_PC     : out    vl_logic_vector;
        reg_valid       : out    vl_logic;
        reg_ready       : out    vl_logic
    );
end fetch_buffer;
