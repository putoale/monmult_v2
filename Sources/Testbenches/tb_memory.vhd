
---------- DEFAULT LIBRARY ---------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
--	use IEEE.MATH_REAL.all;

--	use STD.textio.all;
--	use ieee.std_logic_textio.all;

------------------------------------
---------- OTHERS LIBRARY ----------
-- NONE
------------------------------------
ENTITY tb_memory IS
END tb_memory;
ARCHITECTURE Behavioral OF tb_memory IS
    COMPONENT input_mem_abn IS
        GENERIC (
            WRITE_WIDTH    : INTEGER := 8;
            READ_WIDTH     : INTEGER := 8;   --assuming READ_WIDTH=WRITE_WIDT, for now
            CYLCES_TO_WAIT : INTEGER := 1;   --goes from 1 for a to and entire N_WORDS for b
            LATENCY        : INTEGER := 100; --goes from 1 to what needed

            MEMORY_DEPTH : INTEGER := 4
        );
        PORT (

            clk   : IN STD_LOGIC;
            reset : IN STD_LOGIC;

            wr_en   : IN STD_LOGIC;
            wr_port : IN STD_LOGIC_VECTOR(WRITE_WIDTH - 1 DOWNTO 0);
            rd_en   : IN STD_LOGIC;
            rd_port : OUT STD_LOGIC_VECTOR(READ_WIDTH - 1 DOWNTO 0)
        );
    END COMPONENT;
    CONSTANT WRITE_WIDTH    : INTEGER   := 8;
    CONSTANT READ_WIDTH     : INTEGER   := 8;
    CONSTANT CYLCES_TO_WAIT : INTEGER   := 4;
    CONSTANT MEMORY_DEPTH   : INTEGER   := 16;
    CONSTANT LATENCY        : INTEGER   := 100;
    CONSTANT CLK_PERIOD     : TIME      := 10 ns;
    SIGNAL clk              : STD_LOGIC := '0';
    SIGNAL reset            : STD_LOGIC := '0';
    SIGNAL wr_en            : STD_LOGIC;
    SIGNAL rd_en            : STD_LOGIC;
    SIGNAL wr_port          : STD_LOGIC_VECTOR(WRITE_WIDTH - 1 DOWNTO 0);
    SIGNAL rd_port          : STD_LOGIC_VECTOR(READ_WIDTH - 1 DOWNTO 0);

BEGIN

    mem_inst : input_mem_abn
    GENERIC MAP(
        WRITE_WIDTH    => WRITE_WIDTH,
        READ_WIDTH     => READ_WIDTH,
        CYLCES_TO_WAIT => CYLCES_TO_WAIT,
        LATENCY        => LATENCY,
        MEMORY_DEPTH   => MEMORY_DEPTH
    )

    PORT MAP(
        clk     => clk,
        reset   => reset,
        wr_en   => wr_en,
        wr_port => wr_port,
        rd_en   => rd_en,
        rd_port => rd_port
    );
    clk <= NOT clk AFTER CLK_PERIOD/2;

    load_memory : PROCESS
    BEGIN
        WAIT UNTIL rising_edge(clk);
        wr_en <= '1';

        FOR i IN 0 TO MEMORY_DEPTH - 1 LOOP

            wr_port <= STD_LOGIC_VECTOR(to_unsigned(i, wr_port'length));
            WAIT UNTIL rising_edge(clk);
        END LOOP;
        wr_en <= '1';
        WAIT;
    END PROCESS;

    read_memory : PROCESS
    BEGIN
        rd_en <= '1';
        WAIT UNTIL rising_edge(clk);
        FOR i IN 0 TO 5 LOOP
            FOR j IN 0 TO MEMORY_DEPTH - 1 LOOP

            END LOOP;
        END LOOP;
    END PROCESS;
END Behavioral;