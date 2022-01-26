

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
USE IEEE.NUMERIC_STD.ALL;
ENTITY input_mem_v2 IS
    GENERIC (
        WRITE_WIDTH    : INTEGER := 8;
        READ_WIDTH     : INTEGER := 8; --assuming READ_WIDTH=WRITE_WIDT, for now
        CYLCES_TO_WAIT : INTEGER := 4; --goes from 1 for a to and entire N_WORDS for b
        LATENCY        : INTEGER := 4; --goes from 1 to what needed
        N_BITS_TOTAL   : INTEGER := 64
        --MEMORY_DEPTH: integer:=16
        --FULL_READ_NUMBER: integer := 4
    );
    PORT (

        clk         : IN STD_LOGIC;
        reset       : IN STD_LOGIC;
        memory_full : OUT STD_LOGIC := '0';

        wr_en   : IN STD_LOGIC;
        wr_port : IN STD_LOGIC_VECTOR(WRITE_WIDTH - 1 DOWNTO 0);
        rd_en   : IN STD_LOGIC;
        rd_port : OUT STD_LOGIC_VECTOR(READ_WIDTH - 1 DOWNTO 0) := (OTHERS => '0');
        start   : OUT STD_LOGIC                                 := '0';

        ---add start latency
        start_in : IN STD_LOGIC;
        EoC_in   : IN STD_LOGIC
    );
END input_mem_v2;
ARCHITECTURE Behavioral OF input_mem_v2 IS

    COMPONENT input_mem_abn IS
        GENERIC (
            WRITE_WIDTH    : INTEGER := 8;
            READ_WIDTH     : INTEGER := 8; --assuming READ_WIDTH=WRITE_WIDT, for now
            CYLCES_TO_WAIT : INTEGER := 4; --goes from 1 for a to and entire N_WORDS for b
            LATENCY        : INTEGER := 4; --goes from 1 to what needed
            --INPUT_VS_OUTPUT: string:="INPUT";
            MEMORY_DEPTH : INTEGER := 16
            --FULL_READ_NUMBER: integer := 4
        );
        PORT (

            clk         : IN STD_LOGIC;
            reset       : IN STD_LOGIC;
            memory_full : OUT STD_LOGIC := '0';

            wr_en   : IN STD_LOGIC;
            wr_port : IN STD_LOGIC_VECTOR(WRITE_WIDTH - 1 DOWNTO 0);
            rd_en   : IN STD_LOGIC;
            rd_port : OUT STD_LOGIC_VECTOR(READ_WIDTH - 1 DOWNTO 0) := (OTHERS => '0');
            start   : OUT STD_LOGIC                                 := '0';

            ---add start latency
            start_in : IN STD_LOGIC;
            EoC_in   : IN STD_LOGIC
        );
    END COMPONENT;

    COMPONENT in_mem_controller IS
        GENERIC (
            WRITE_WIDTH : INTEGER := 16; --read_width must be a multiple of write_width. since this is an input controller
            READ_WIDTH  : INTEGER := 64;

            N_BITS_TOTAL : INTEGER := 256
        );
        PORT (
            clk       : IN STD_LOGIC;
            reset     : IN STD_LOGIC;
            out_valid : OUT STD_LOGIC; -- stays at 1 as long as there are valid data on rd_port
            wr_en     : IN STD_LOGIC;  --this comes from the outside e.g. the testbench
            wr_port   : IN STD_LOGIC_VECTOR(write_width - 1 DOWNTO 0);
            rd_port   : OUT STD_LOGIC_VECTOR(read_width - 1 DOWNTO 0);
            eoc_in    : IN STD_LOGIC
        );
    END COMPONENT;

    CONSTANT MEMORY_DEPTH_MEM   : INTEGER := N_BITS_TOTAL/READ_WIDTH;
    SIGNAL rd_port_controller   : STD_LOGIC_VECTOR(READ_WIDTH - 1 DOWNTO 0);
    SIGNAL out_valid_controller : STD_LOGIC;
BEGIN

    controller_inst : in_mem_controller
    GENERIC MAP(
        WRITE_WIDTH  => WRITE_WIDTH,
        READ_WIDTH   => READ_WIDTH,
        N_BITS_TOTAL => N_BITS_TOTAL
    )
    PORT MAP(
        clk       => clk,
        reset     => reset,
        out_valid => out_valid_controller,
        wr_en     => wr_en,
        wr_port   => wr_port,
        rd_port   => rd_port_controller,
        eoc_in    => EoC_in
    );

    memory_inst : input_mem_abn
    GENERIC MAP(
        WRITE_WIDTH    => READ_WIDTH,
        READ_WIDTH     => READ_WIDTH,
        CYLCES_TO_WAIT => CYLCES_TO_WAIT,
        LATENCY        => LATENCY,
        MEMORY_DEPTH   => MEMORY_DEPTH_MEM
    )
    PORT MAP(

        clk         => clk,
        reset       => reset,
        memory_full => memory_full,
        wr_en       => out_valid_controller,
        wr_port     => rd_port_controller,
        rd_en       => rd_en,
        rd_port     => rd_port,
        start       => start,
        start_in    => start_in,
        EoC_in      => EoC_in
    );

END Behavioral;