library verilog;
use verilog.vl_types.all;
entity decode_unit is
    generic(
        CORE            : integer := 0;
        ADDRESS_BITS    : integer := 20
    );
    port(
        clock           : in     vl_logic;
        reset           : in     vl_logic;
        PC              : in     vl_logic_vector;
        instruction     : in     vl_logic_vector(31 downto 0);
        extend_sel      : in     vl_logic_vector(1 downto 0);
        write           : in     vl_logic;
        write_reg       : in     vl_logic_vector(4 downto 0);
        write_data      : in     vl_logic_vector(31 downto 0);
        opcode          : out    vl_logic_vector(6 downto 0);
        funct3          : out    vl_logic_vector(2 downto 0);
        funct7          : out    vl_logic_vector(6 downto 0);
        rs1_data        : out    vl_logic_vector(31 downto 0);
        rs2_data        : out    vl_logic_vector(31 downto 0);
        rd              : out    vl_logic_vector(4 downto 0);
        extend_imm      : out    vl_logic_vector(31 downto 0);
        branch_target   : out    vl_logic_vector;
        JAL_target      : out    vl_logic_vector;
        \report\        : in     vl_logic
    );
end decode_unit;
