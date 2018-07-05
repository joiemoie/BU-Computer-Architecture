library verilog;
use verilog.vl_types.all;
entity decode_buffer is
    generic(
        CORE            : integer := 0;
        DATA_WIDTH      : integer := 32;
        INDEX_BITS      : integer := 6;
        OFFSET_BITS     : integer := 3;
        ADDRESS_BITS    : integer := 20
    );
    port(
        clock           : in     vl_logic;
        rs1_data        : in     vl_logic_vector(31 downto 0);
        rs2_data        : in     vl_logic_vector(31 downto 0);
        rd              : in     vl_logic_vector(4 downto 0);
        opcode          : in     vl_logic_vector(6 downto 0);
        funct7          : in     vl_logic_vector(6 downto 0);
        funct3          : in     vl_logic_vector(2 downto 0);
        extend_imm      : in     vl_logic_vector(31 downto 0);
        branch_target   : in     vl_logic_vector;
        JAL_target      : in     vl_logic_vector;
        inst_PC         : in     vl_logic_vector;
        reg_rs1_data    : out    vl_logic_vector(31 downto 0);
        reg_rs2_data    : out    vl_logic_vector(31 downto 0);
        reg_rd          : out    vl_logic_vector(4 downto 0);
        reg_opcode      : out    vl_logic_vector(6 downto 0);
        reg_funct7      : out    vl_logic_vector(6 downto 0);
        reg_funct3      : out    vl_logic_vector(2 downto 0);
        reg_extend_imm  : out    vl_logic_vector(31 downto 0);
        reg_branch_target: out    vl_logic_vector;
        reg_JAL_target  : out    vl_logic_vector;
        reg_inst_PC     : out    vl_logic_vector
    );
end decode_buffer;
