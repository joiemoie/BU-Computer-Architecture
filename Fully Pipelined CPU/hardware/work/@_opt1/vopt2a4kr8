library verilog;
use verilog.vl_types.all;
entity ALU is
    generic(
        DATA_WIDTH      : integer := 32
    );
    port(
        ALU_Control     : in     vl_logic_vector(5 downto 0);
        operand_A       : in     vl_logic_vector;
        operand_B       : in     vl_logic_vector;
        ALU_result      : out    vl_logic_vector;
        zero            : out    vl_logic;
        branch          : out    vl_logic
    );
end ALU;
