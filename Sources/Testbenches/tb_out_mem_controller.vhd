LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
USE IEEE.NUMERIC_STD.ALL;

ENTITY tb_out_mem_controller IS
END ENTITY tb_out_mem_controller;

ARCHITECTURE behavioral OF tb_out_mem_controller IS

    COMPONENT out_mem_controller IS
        GENERIC (
            write_width : INTEGER := 16;
            read_width  : INTEGER := 8;

            n_bits_total : INTEGER := 64
        );
        PORT (
            clk       : IN STD_LOGIC;
            reset     : IN STD_LOGIC;
            out_valid : OUT STD_LOGIC;
            wr_en     : IN STD_LOGIC;
            wr_port   : IN STD_LOGIC_VECTOR(write_width - 1 DOWNTO 0);
            rd_port   : OUT STD_LOGIC_VECTOR(read_width - 1 DOWNTO 0);
            eoc_out   : OUT STD_LOGIC;
            eoc_in    : IN STD_LOGIC
        );
    END COMPONENT;
    -------------------------------input_memory_case---------------------------
    CONSTANT write_width   : INTEGER := 16;
    CONSTANT read_width    : INTEGER := 8;
    CONSTANT n_bits_total  : INTEGER := 64;
    CONSTANT memory_depth  : INTEGER := n_bits_total / read_width;
    CONSTANT write_bigness : INTEGER := write_width/read_width;
    ---------------------------------------------------------------------------
    CONSTANT clk_period : TIME      := 10 ns;
    SIGNAL clk          : STD_LOGIC := '0';
    SIGNAL reset        : STD_LOGIC;
    SIGNAL out_valid    : STD_LOGIC;
    SIGNAL wr_en        : STD_LOGIC;
    SIGNAL wr_port      : STD_LOGIC_VECTOR(write_width - 1 DOWNTO 0);
    SIGNAL rd_port      : STD_LOGIC_VECTOR(read_width - 1 DOWNTO 0);
    SIGNAL eoc_out      : STD_LOGIC;
    SIGNAL eoc_in       : STD_LOGIC;

    TYPE in_vector_type IS ARRAY (memory_depth - 1 DOWNTO 0) OF STD_LOGIC_VECTOR(write_width - 1 DOWNTO 0);
    SIGNAL in_vector     : STD_LOGIC_VECTOR(n_bits_total - 1 DOWNTO 0);
    SIGNAL in_vector_one : STD_LOGIC_VECTOR(n_bits_total / 2 - 1 DOWNTO 0);
    SIGNAL in_vector_two : STD_LOGIC_VECTOR(n_bits_total / 2 - 1 DOWNTO 0);

    SIGNAL out_vector : STD_LOGIC_VECTOR(n_bits_total - 1 DOWNTO 0);
    SIGNAL j          : INTEGER := memory_depth - 1;
BEGIN

    --in_vector_one <= std_logic_vector(to_unsigned(x"11223344", n_bits_total / 2));
    --in_vector_two <= std_logic_vector(to_unsigned(x"55667788", n_bits_total / 2));
    in_vector_one <= x"01234567";
    in_vector_two <= x"89abcdef";
    in_vector     <= in_vector_one & in_vector_two;

    inst : COMPONENT out_mem_controller
        GENERIC MAP(
            write_width  => write_width,
            read_width   => read_width,
            n_bits_total => n_bits_total
        )
        PORT MAP(
            clk       => clk,
            reset     => reset,
            out_valid => out_valid,
            wr_en     => wr_en,
            wr_port   => wr_port,
            rd_port   => rd_port,
            eoc_out   => eoc_out,
            eoc_in    => eoc_in
        );

        clk <= NOT clk AFTER clk_period / 2;

        PROCESS IS
        BEGIN
            wr_en <= '0';
            reset <= '1';
            WAIT FOR clk_period * 3;
            reset <= '0';

            EoC_in <= '1';
            WAIT FOR clk_period * 2;
            EoC_in <= '0';
            WAIT FOR clk_period * 2;
            WAIT UNTIL rising_edge(clk);

            FOR i IN 0 TO (memory_depth/write_bigness) - 1 LOOP
                wr_en   <= '1';
                wr_port <= in_vector((write_width) * (i + 1) - 1 DOWNTO i * write_width);
                WAIT UNTIL rising_edge(clk);
            END LOOP;

            wr_en <= '0';
            IF out_valid = '1' THEN
                FOR i IN 0 TO memory_depth - 1 LOOP
                    out_vector((read_width) * (i + 1) - 1 DOWNTO i * read_width) <= rd_port;
                    WAIT FOR clk_period;
                END LOOP;
            END IF;
            WAIT FOR clk_period * 10;
            WAIT;
        END PROCESS;

    END ARCHITECTURE behavioral;