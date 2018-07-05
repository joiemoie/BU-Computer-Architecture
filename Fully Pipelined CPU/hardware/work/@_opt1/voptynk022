library verilog;
use verilog.vl_types.all;
entity mem_interface is
    generic(
        CORE            : integer := 0;
        DATA_WIDTH      : integer := 32;
        INDEX_BITS      : integer := 6;
        OFFSET_BITS     : integer := 3;
        ADDRESS_BITS    : integer := 20
    );
    port(
        clock           : in     vl_logic;
        reset           : in     vl_logic;
        read            : in     vl_logic;
        write           : in     vl_logic;
        address         : in     vl_logic_vector;
        in_data         : in     vl_logic_vector;
        out_addr        : out    vl_logic_vector;
        out_data        : out    vl_logic_vector;
        valid           : out    vl_logic;
        ready           : out    vl_logic;
        \report\        : in     vl_logic
    );
end mem_interface;
