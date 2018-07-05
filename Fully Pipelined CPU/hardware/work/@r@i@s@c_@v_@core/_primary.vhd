library verilog;
use verilog.vl_types.all;
entity RISC_V_Core is
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
        prog_address    : in     vl_logic_vector;
        from_peripheral : in     vl_logic_vector(1 downto 0);
        from_peripheral_data: in     vl_logic_vector(31 downto 0);
        from_peripheral_valid: in     vl_logic;
        to_peripheral   : out    vl_logic_vector(1 downto 0);
        to_peripheral_data: out    vl_logic_vector(31 downto 0);
        to_peripheral_valid: out    vl_logic;
        \report\        : in     vl_logic
    );
end RISC_V_Core;
