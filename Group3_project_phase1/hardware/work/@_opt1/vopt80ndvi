library verilog;
use verilog.vl_types.all;
entity execute_buffer is
    generic(
        CORE            : integer := 0;
        DATA_WIDTH      : integer := 32;
        INDEX_BITS      : integer := 6;
        OFFSET_BITS     : integer := 3;
        ADDRESS_BITS    : integer := 20
    );
    port(
        clock           : in     vl_logic;
        ALU_result      : in     vl_logic_vector;
        zero            : in     vl_logic;
        branch          : in     vl_logic;
        JALR_target     : in     vl_logic_vector;
        memRead         : in     vl_logic;
        memWrite        : in     vl_logic;
        rs2_data        : in     vl_logic_vector(31 downto 0);
        regWrite        : in     vl_logic;
        rd              : in     vl_logic_vector(4 downto 0);
        branch_target   : in     vl_logic_vector;
        next_PC_sel     : in     vl_logic_vector(1 downto 0);
        JAL_target      : in     vl_logic_vector;
        reg_ALU_result  : out    vl_logic_vector;
        reg_zero        : out    vl_logic;
        reg_branch      : out    vl_logic;
        reg_JALR_target : out    vl_logic_vector;
        reg_memRead     : out    vl_logic;
        reg_memWrite    : out    vl_logic;
        reg_rs2_data    : out    vl_logic_vector(31 downto 0);
        reg_regWrite    : out    vl_logic;
        reg_rd          : out    vl_logic_vector(4 downto 0);
        reg_branch_target: out    vl_logic_vector;
        reg_next_PC_sel : out    vl_logic_vector(1 downto 0);
        reg_JAL_target  : out    vl_logic_vector
    );
end execute_buffer;
