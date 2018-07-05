library verilog;
use verilog.vl_types.all;
entity memory_buffer is
    generic(
        CORE            : integer := 0;
        DATA_WIDTH      : integer := 32;
        INDEX_BITS      : integer := 6;
        OFFSET_BITS     : integer := 3;
        ADDRESS_BITS    : integer := 20
    );
    port(
        clock           : in     vl_logic;
        data_addr       : in     vl_logic_vector;
        load_data       : in     vl_logic_vector;
        valid           : in     vl_logic;
        ready           : in     vl_logic;
        regWrite        : in     vl_logic;
        memRead         : in     vl_logic;
        rd              : in     vl_logic_vector(4 downto 0);
        ALU_result      : in     vl_logic_vector;
        reg_data_addr   : out    vl_logic_vector;
        reg_load_data   : out    vl_logic_vector;
        reg_valid       : out    vl_logic;
        reg_ready       : out    vl_logic;
        reg_regWrite    : out    vl_logic;
        reg_memRead     : out    vl_logic;
        reg_rd          : out    vl_logic_vector(4 downto 0);
        reg_ALU_result  : out    vl_logic_vector
    );
end memory_buffer;
