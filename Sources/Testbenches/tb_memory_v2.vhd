LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY tb_memory_v2 IS
END;
ARCHITECTURE behavioral OF tb_memory_v2 IS

    COMPONENT input_mem_v2 IS
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
    END COMPONENT;
    CONSTANT N_BITS_TOTAL            : INTEGER   := 256;
    CONSTANT WRITE_WIDTH             : INTEGER   := 16;
    CONSTANT READ_WIDTH              : INTEGER   := 64;
    CONSTANT CYLCES_TO_WAIT          : INTEGER   := 4;
    CONSTANT MEM_MEMORY_DEPTH        : INTEGER   := N_BITS_TOTAL/READ_WIDTH; --needed for memory_abn
    CONSTANT CONTROLLER_MEMORY_DEPTH : INTEGER   := N_BITS_TOTAL/WRITE_WIDTH;
    CONSTANT LATENCY                 : INTEGER   := 4;
    CONSTANT CLK_PERIOD              : TIME      := 10 ns;
    SIGNAL clk                       : STD_LOGIC := '0';
    SIGNAL reset                     : STD_LOGIC := '0';
    SIGNAL start                     : STD_LOGIC := '0';

    ---add start latency
    SIGNAL start_in : STD_LOGIC;
    SIGNAL EoC_in   : STD_LOGIC;
    SIGNAL wr_en    : STD_LOGIC;
    SIGNAL rd_en    : STD_LOGIC;
    SIGNAL wr_port  : STD_LOGIC_VECTOR(WRITE_WIDTH - 1 DOWNTO 0);
    SIGNAL rd_port  : STD_LOGIC_VECTOR(READ_WIDTH - 1 DOWNTO 0);

BEGIN
    clk <= NOT clk AFTER CLK_PERIOD/2;
    mem_inst : input_mem_v2
    GENERIC MAP(
        WRITE_WIDTH    => WRITE_WIDTH,
        READ_WIDTH     => READ_WIDTH,
        CYLCES_TO_WAIT => CYLCES_TO_WAIT,
        LATENCY        => LATENCY,
        --MEMORY_DEPTH		=>MEM_MEMORY_DEPTH,
        N_BITS_TOTAL => N_BITS_TOTAL
    )

    PORT MAP(
        clk      => clk,
        reset    => reset,
        wr_en    => wr_en,
        wr_port  => wr_port,
        rd_en    => rd_en,
        rd_port  => rd_port,
        start    => start,
        start_in => start_in,
        EoC_in   => EoC_in

    );

    rd_en <= '1';
    load_memory : PROCESS
    BEGIN
        reset  <= '1';
        EoC_in <= '1';
        WAIT UNTIL rising_edge(clk);
        reset  <= '0';
        EoC_in <= '0';
        WAIT UNTIL rising_edge(clk);
        WAIT UNTIL rising_edge(clk);
        wr_en <= '1';

        FOR i IN 0 TO CONTROLLER_MEMORY_DEPTH - 1 LOOP

            wr_port <= STD_LOGIC_VECTOR(to_unsigned(i, wr_port'length));
            WAIT UNTIL rising_edge(clk);
        END LOOP;
        wr_en <= '0';
        --for i in 0 to MEM_MEMORY_DEPTH +1  loop
        --	wait until rising_edge(clk);
        --end loop;
        WAIT UNTIL start = '1';
        WAIT FOR CLK_PERIOD * 2;
        start_in <= '1';
        WAIT UNTIL rising_edge(clk);
        start_in <= '0';
        WAIT;
    END PROCESS;

END behavioral;