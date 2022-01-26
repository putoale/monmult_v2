
LIBRARY IEEE;
LIBRARY STD;
USE std.textio.ALL;
USE ieee.std_logic_textio.ALL;
USE IEEE.STD_LOGIC_1164.ALL;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.	ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

ENTITY tb_monmult_module IS
END tb_monmult_module;

ARCHITECTURE Behavioral OF tb_monmult_module IS

    COMPONENT monmult_module IS
        GENERIC (
            WRITE_WIDTH     : INTEGER := 8;
            READ_WIDTH      : INTEGER := 8;
            N_BITS_PER_WORD : INTEGER := 8;
            N_WORDS         : INTEGER := 4;
            MEMORY_DEPTH    : INTEGER := 16

        );
        PORT (
            clk         : IN STD_LOGIC;
            reset       : IN STD_LOGIC;
            wr_en_a     : IN STD_LOGIC;
            wr_en_b     : IN STD_LOGIC;
            wr_en_n_mac : IN STD_LOGIC;
            wr_en_n_sub : IN STD_LOGIC;
            EoC         : OUT STD_LOGIC := '0';
            a           : IN STD_LOGIC_VECTOR(N_BITS_PER_WORD - 1 DOWNTO 0);
            b           : IN STD_LOGIC_VECTOR(N_BITS_PER_WORD - 1 DOWNTO 0);
            n           : IN STD_LOGIC_VECTOR(N_BITS_PER_WORD - 1 DOWNTO 0);
            nn0         : IN STD_LOGIC_VECTOR(N_BITS_PER_WORD - 1 DOWNTO 0);
            result      : OUT STD_LOGIC_VECTOR(N_BITS_PER_WORD - 1 DOWNTO 0) := (OTHERS => '0')
        );
    END COMPONENT;
    -----------_CONSTANTS---------------------------------------------------------
    --total is 256 bits, to be divided in 4*64
    CONSTANT N_BITS_PER_WORD : INTEGER := 64;
    CONSTANT N_WORDS         : INTEGER := 4;
    CONSTANT MEMORY_DEPTH    : INTEGER := 4;
    CONSTANT WRITE_WIDTH     : INTEGER := 64;
    CONSTANT READ_WIDTH      : INTEGER := 64;

    CONSTANT CLK_PERIOD         : TIME   := 10 ns;
    CONSTANT C_FILE_NAME        : STRING := "/home/matteo/Documents/monmult_v2/Sources/Python/tb_vec_gentxtout_results.txt"; --absolute path
    CONSTANT time_between_tests : TIME   := CLK_PERIOD * N_WORDS * N_WORDS;
    ------------------------------------------------------------------------------

    ----------SIGNALS-------------------------------------------------------------
    SIGNAL clk         : STD_LOGIC := '0';
    SIGNAL reset       : STD_LOGIC := '0';
    SIGNAL wr_en_a     : STD_LOGIC;
    SIGNAL wr_en_b     : STD_LOGIC;
    SIGNAL wr_en_n_mac : STD_LOGIC;
    SIGNAL wr_en_n_sub : STD_LOGIC;
    SIGNAL a           : STD_LOGIC_VECTOR(N_BITS_PER_WORD - 1 DOWNTO 0);
    SIGNAL b           : STD_LOGIC_VECTOR(N_BITS_PER_WORD - 1 DOWNTO 0);
    SIGNAL n           : STD_LOGIC_VECTOR(N_BITS_PER_WORD - 1 DOWNTO 0);
    SIGNAL nn0         : STD_LOGIC_VECTOR(N_BITS_PER_WORD - 1 DOWNTO 0);
    SIGNAL result      : STD_LOGIC_VECTOR(N_BITS_PER_WORD - 1 DOWNTO 0);
    SIGNAL EoC         : STD_LOGIC;
    ------------------------------------------------------------------------------

    ---------FILE HANDLES---------------------------------------------------------

    ------------------------------------------------------------------------------
BEGIN
    ---------------------MODULE INSTANTIATION-------------------------------------

    monmult_inst : monmult_module
    GENERIC MAP(
        WRITE_WIDTH     => WRITE_WIDTH,
        READ_WIDTH      => READ_WIDTH,
        N_BITS_PER_WORD => N_BITS_PER_WORD,
        N_WORDS         => N_WORDS,
        MEMORY_DEPTH    => MEMORY_DEPTH

    )
    PORT MAP(
        clk         => clk,
        reset       => reset,
        wr_en_a     => wr_en_a,
        wr_en_b     => wr_en_b,
        wr_en_n_mac => wr_en_n_mac,
        wr_en_n_sub => wr_en_n_sub,
        EoC         => EoC,
        a           => a,
        b           => b,
        n           => n,
        nn0         => nn0,
        result      => result

    );

    ------------------------------------------------------------------------------
    clk <= NOT clk AFTER CLK_PERIOD/2;

    reset <= '1', '0' AFTER 10 ns;
    stimulus : PROCESS

        FILE fptr : text OPEN read_mode IS C_FILE_NAME;

        VARIABLE file_line : line;
        --variable var_data1     :std_logic_vector(N_BITS_PER_WORD-1 downto 0);
        VARIABLE var_data1 : STD_LOGIC_VECTOR(N_BITS_PER_WORD - 1 DOWNTO 0);
        VARIABLE char      : CHARACTER;

    BEGIN
        WAIT UNTIL reset = '0';
        WHILE (NOT endfile(fptr)) LOOP
            WAIT UNTIL rising_edge(clk);
            readline(fptr, file_line);
            --this statement is used three times, for a, b, n
            FOR i IN 0 TO N_WORDS - 1 LOOP --looping over the words composing an input i.e a
                wr_en_a <= '1';
                --hread(file_line, var_data1);
                hread(file_line, var_data1);
                a <= var_data1;
                WAIT UNTIL rising_edge(clk);
                read(file_line, char);
                WAIT UNTIL rising_edge(clk);
                wr_en_a <= '0';
            END LOOP;
            FOR i IN 0 TO N_WORDS - 1 LOOP --looping over the words composing an input i.e a
                --hread(file_line, var_data1);
                wr_en_b <= '1';

                hread(file_line, var_data1);
                b <= var_data1;
                WAIT UNTIL rising_edge(clk);
                read(file_line, char);
                WAIT UNTIL rising_edge(clk);
                wr_en_b <= '0';

            END LOOP;
            FOR i IN 0 TO N_WORDS - 1 LOOP --looping over the words composing an input i.e a
                --hread(file_line, var_data1);
                wr_en_n_mac <= '1';
                wr_en_n_sub <= '1';
                hread(file_line, var_data1);
                n <= var_data1;
                WAIT UNTIL rising_edge(clk);
                read(file_line, char);
                WAIT UNTIL rising_edge(clk);
                wr_en_n_mac <= '0';
                wr_en_n_sub <= '1';
            END LOOP;
            --now the nn0 read
            hread(file_line, var_data1);
            nn0 <= var_data1;
            WAIT UNTIL rising_edge(clk);

            WAIT FOR CLK_PERIOD * 100;
        END LOOP;
        file_close(fptr);
        WAIT;

    END PROCESS;
END ARCHITECTURE;