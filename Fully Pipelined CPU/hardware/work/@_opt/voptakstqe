library verilog;
use verilog.vl_types.all;
entity control_unit_buffer is
    generic(
        CORE            : integer := 0
    );
    port(
        clock           : in     vl_logic;
        branch_op       : in     vl_logic;
        memRead         : in     vl_logic;
        memtoReg        : in     vl_logic;
        ALUOp           : in     vl_logic_vector(2 downto 0);
        memWrite        : in     vl_logic;
        next_PC_sel     : in     vl_logic_vector(1 downto 0);
        operand_A_sel   : in     vl_logic_vector(1 downto 0);
        operand_B_sel   : in     vl_logic;
        extend_sel      : in     vl_logic_vector(1 downto 0);
        regWrite        : in     vl_logic;
        reg_branch_op   : out    vl_logic;
        reg_memRead     : out    vl_logic;
        reg_memtoReg    : out    vl_logic;
        reg_ALUOp       : out    vl_logic_vector(2 downto 0);
        reg_memWrite    : out    vl_logic;
        reg_next_PC_sel : out    vl_logic_vector(1 downto 0);
        reg_operand_A_sel: out    vl_logic_vector(1 downto 0);
        reg_operand_B_sel: out    vl_logic;
        reg_extend_sel  : out    vl_logic_vector(1 downto 0);
        reg_regWrite    : out    vl_logic
    );
end control_unit_buffer;
