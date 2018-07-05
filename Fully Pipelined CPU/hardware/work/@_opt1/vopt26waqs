library verilog;
use verilog.vl_types.all;
entity fetch_unit is
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
        start           : in     vl_logic;
        PC_select       : in     vl_logic_vector(1 downto 0);
        program_address : in     vl_logic_vector;
        JAL_target      : in     vl_logic_vector;
        JALR_target     : in     vl_logic_vector;
        branch          : in     vl_logic;
        branch_target   : in     vl_logic_vector;
        instruction     : out    vl_logic_vector;
        inst_PC         : out    vl_logic_vector;
        valid           : out    vl_logic;
        ready           : out    vl_logic;
        \report\        : in     vl_logic
    );
end fetch_unit;
