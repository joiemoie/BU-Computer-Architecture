library verilog;
use verilog.vl_types.all;
entity control_unit is
    generic(
        CORE            : integer := 0
    );
    port(
        clock           : in     vl_logic;
        reset           : in     vl_logic;
        opcode          : in     vl_logic_vector(6 downto 0);
        branch_op       : out    vl_logic;
        memRead         : out    vl_logic;
        memtoReg        : out    vl_logic;
        ALUOp           : out    vl_logic_vector(2 downto 0);
        next_PC_sel     : out    vl_logic_vector(1 downto 0);
        operand_A_sel   : out    vl_logic_vector(1 downto 0);
        operand_B_sel   : out    vl_logic;
        extend_sel      : out    vl_logic_vector(1 downto 0);
        memWrite        : out    vl_logic;
        regWrite        : out    vl_logic;
        \report\        : in     vl_logic
    );
end control_unit;
