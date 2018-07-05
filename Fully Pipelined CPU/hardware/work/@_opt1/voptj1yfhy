library verilog;
use verilog.vl_types.all;
entity execution_unit is
    generic(
        CORE            : integer := 0;
        DATA_WIDTH      : integer := 32;
        ADDRESS_BITS    : integer := 20
    );
    port(
        clock           : in     vl_logic;
        reset           : in     vl_logic;
        ALU_Operation   : in     vl_logic_vector(2 downto 0);
        funct3          : in     vl_logic_vector(2 downto 0);
        funct7          : in     vl_logic_vector(6 downto 0);
        PC              : in     vl_logic_vector;
        ALU_ASrc        : in     vl_logic_vector(1 downto 0);
        ALU_BSrc        : in     vl_logic;
        branch_op       : in     vl_logic;
        regRead_1       : in     vl_logic_vector;
        regRead_2       : in     vl_logic_vector;
        extend          : in     vl_logic_vector;
        ALU_result      : out    vl_logic_vector;
        zero            : out    vl_logic;
        branch          : out    vl_logic;
        JALR_target     : out    vl_logic_vector;
        \report\        : in     vl_logic
    );
end execution_unit;
