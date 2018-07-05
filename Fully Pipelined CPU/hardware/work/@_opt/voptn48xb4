library verilog;
use verilog.vl_types.all;
entity writeback_unit is
    generic(
        CORE            : integer := 0;
        DATA_WIDTH      : integer := 32
    );
    port(
        clock           : in     vl_logic;
        reset           : in     vl_logic;
        opWrite         : in     vl_logic;
        opSel           : in     vl_logic;
        opReg           : in     vl_logic_vector(4 downto 0);
        ALU_Result      : in     vl_logic_vector;
        memory_data     : in     vl_logic_vector;
        write           : out    vl_logic;
        write_reg       : out    vl_logic_vector(4 downto 0);
        write_data      : out    vl_logic_vector;
        \report\        : in     vl_logic
    );
end writeback_unit;
