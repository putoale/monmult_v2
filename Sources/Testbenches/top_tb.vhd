LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
--	use IEEE.MATH_REAL.all;
USE STD.textio.ALL;
USE ieee.std_logic_textio.ALL;

ENTITY top_tb IS
END;

ARCHITECTURE bench OF top_tb IS

    COMPONENT monmult_module
        GENERIC (
            WRITE_WIDTH     : INTEGER;
            READ_WIDTH      : INTEGER;
            N_BITS_PER_WORD : INTEGER;
            N_WORDS         : INTEGER;
            MEMORY_DEPTH    : INTEGER
        );
        PORT (
            clk   : IN STD_LOGIC;
            reset : IN STD_LOGIC;

            wr_en_a : IN STD_LOGIC;
            wr_en_b : IN STD_LOGIC;

            wr_en_n_mac : IN STD_LOGIC;
            wr_en_n_sub : IN STD_LOGIC;

            a : IN STD_LOGIC_VECTOR(N_BITS_PER_WORD - 1 DOWNTO 0);

            b : IN STD_LOGIC_VECTOR(N_BITS_PER_WORD - 1 DOWNTO 0);

            n : IN STD_LOGIC_VECTOR(N_BITS_PER_WORD - 1 DOWNTO 0);

            nn0 : IN STD_LOGIC_VECTOR(N_BITS_PER_WORD - 1 DOWNTO 0);

            EoC : OUT STD_LOGIC;

            valid_out : OUT STD_LOGIC := '0';

            result : OUT STD_LOGIC_VECTOR(N_BITS_PER_WORD - 1 DOWNTO 0)
        );
    END COMPONENT;

    -- Clock period
    CONSTANT CLK_PERIOD : TIME := 1 ns; --edited to try many test vectors
    CONSTANT RESET_WND  : TIME := 10 * CLK_PERIOD;

    -- TB Initialiazations
    CONSTANT TB_CLK_INIT   : STD_LOGIC := '0';
    CONSTANT TB_RESET_INIT : STD_LOGIC := '1';

    -- Generics
    CONSTANT DUT_N_BITS_PER_WORD : INTEGER := 64;
    CONSTANT DUT_N_WORDS         : INTEGER := 8;
    CONSTANT DUT_WRITE_WIDTH     : INTEGER := DUT_N_BITS_PER_WORD;
    CONSTANT DUT_READ_WIDTH      : INTEGER := DUT_N_BITS_PER_WORD;
    CONSTANT DUT_MEMORY_DEPTH    : INTEGER := DUT_N_WORDS;

    --File GENERICS
    CONSTANT N_TEST_VECTORS   : POSITIVE := 4;
    CONSTANT INPUT_FILE_NAME  : STRING   := "input_vectors_512_8_64.txt";
    CONSTANT OUTPUT_FILE_NAME : STRING   := "out_results.txt";

    --Types
    --array of N_WORDS to store an operand (e.g. to store "a")
    TYPE test_vector_input_type IS ARRAY (DUT_N_WORDS - 1 DOWNTO 0) OF STD_LOGIC_VECTOR(DUT_N_BITS_PER_WORD - 1 DOWNTO 0);

    -- type to store all the values of a N_WORDS operand to test (e.g. all test vectors for "a","b",or "n")
    TYPE test_vector_Nw_array IS ARRAY(0 TO N_TEST_VECTORS - 1) OF test_vector_input_type;

    -- type to store all the values of nn0 to test
    TYPE test_vector_1w_array IS ARRAY(0 TO N_TEST_VECTORS - 1) OF STD_LOGIC_VECTOR(DUT_N_BITS_PER_WORD - 1 DOWNTO 0);

    -- type to store result of one monmult
    TYPE output_result_array IS ARRAY (DUT_N_WORDS - 1 DOWNTO 0) OF STD_LOGIC_VECTOR(DUT_N_BITS_PER_WORD - 1 DOWNTO 0);

    -- Ports
    SIGNAL clk             : STD_LOGIC                                          := TB_CLK_INIT;
    SIGNAL reset           : STD_LOGIC                                          := TB_RESET_INIT;
    SIGNAL dut_wr_en_a     : STD_LOGIC                                          := '0';
    SIGNAL dut_wr_en_b     : STD_LOGIC                                          := '0';
    SIGNAL dut_wr_en_n_mac : STD_LOGIC                                          := '0';
    SIGNAL dut_wr_en_n_sub : STD_LOGIC                                          := '0';
    SIGNAL dut_a           : STD_LOGIC_VECTOR(DUT_N_BITS_PER_WORD - 1 DOWNTO 0) := (OTHERS => '0');
    SIGNAL dut_b           : STD_LOGIC_VECTOR(DUT_N_BITS_PER_WORD - 1 DOWNTO 0) := (OTHERS => '0');
    SIGNAL dut_n           : STD_LOGIC_VECTOR(DUT_N_BITS_PER_WORD - 1 DOWNTO 0) := (OTHERS => '0');
    SIGNAL dut_nn0         : STD_LOGIC_VECTOR(DUT_N_BITS_PER_WORD - 1 DOWNTO 0) := (OTHERS => '0');
    SIGNAL dut_EoC         : STD_LOGIC                                          := '0';
    SIGNAL dut_valid_out   : STD_LOGIC                                          := '0';
    SIGNAL dut_result      : STD_LOGIC_VECTOR(DUT_N_BITS_PER_WORD - 1 DOWNTO 0) := (OTHERS => '0');

    --Other signals
    SIGNAL file_read_complete : BOOLEAN := false;
    SIGNAL writeline_complete : BOOLEAN := false;

    -- memory with all test vectors of "a" operand
    SIGNAL a_memory : test_vector_Nw_array := (OTHERS => (OTHERS => (OTHERS => '0')));

    -- memory with all test vectors of "b" operand
    SIGNAL b_memory : test_vector_Nw_array := (OTHERS => (OTHERS => (OTHERS => '0')));

    -- memory with all test vectors of "n" operand
    SIGNAL n_memory : test_vector_Nw_array := (OTHERS => (OTHERS => (OTHERS => '0')));

    -- memory with all test vectors of "nn0" operand
    SIGNAL nn0_memory : test_vector_1w_array := (OTHERS => (OTHERS => '0'));

    -- memory for one test vector result
    SIGNAL res_memory : output_result_array := (OTHERS => (OTHERS => '0'));

BEGIN

    monmult_module_inst : monmult_module
    GENERIC MAP(
        WRITE_WIDTH     => dut_WRITE_WIDTH,
        READ_WIDTH      => dut_READ_WIDTH,
        N_BITS_PER_WORD => dut_N_BITS_PER_WORD,
        N_WORDS         => dut_N_WORDS,
        MEMORY_DEPTH    => dut_MEMORY_DEPTH
    )
    PORT MAP(
        clk         => clk,
        reset       => reset,
        wr_en_a     => dut_wr_en_a,
        wr_en_b     => dut_wr_en_b,
        wr_en_n_mac => dut_wr_en_n_mac,
        wr_en_n_sub => dut_wr_en_n_sub,
        a           => dut_a,
        b           => dut_b,
        n           => dut_n,
        nn0         => dut_nn0,
        EoC         => dut_EoC,
        valid_out   => dut_valid_out,
        result      => dut_result
    );

    ---------- clock -------------------
    clk <= NOT clk AFTER CLK_PERIOD/2;
    ------------------------------------

    ----- Reset Process --------
    reset_wave : PROCESS
    BEGIN
        reset <= TB_RESET_INIT;
        WAIT FOR RESET_WND;

        reset <= NOT reset;
        WAIT UNTIL rising_edge(clk);

        WAIT;
    END PROCESS;
    ----------------------------

    ----------File Read Process----------

    file_proc : PROCESS

        --file        input_file            : text open read_mode is "input_vectors_256_4_64.txt";
        FILE input_file      : text OPEN read_mode IS INPUT_FILE_NAME;
        VARIABLE input_line  : line;
        VARIABLE slv_a_var   : STD_LOGIC_VECTOR(DUT_N_BITS_PER_WORD - 1 DOWNTO 0) := (OTHERS => '0');
        VARIABLE slv_b_var   : STD_LOGIC_VECTOR(DUT_N_BITS_PER_WORD - 1 DOWNTO 0) := (OTHERS => '0');
        VARIABLE slv_n_var   : STD_LOGIC_VECTOR(DUT_N_BITS_PER_WORD - 1 DOWNTO 0) := (OTHERS => '0');
        VARIABLE slv_nn0_var : STD_LOGIC_VECTOR(DUT_N_BITS_PER_WORD - 1 DOWNTO 0) := (OTHERS => '0');
        VARIABLE good_v      : BOOLEAN;
    BEGIN

        WHILE NOT endfile(input_file) LOOP

            FOR tv_counter IN 0 TO N_TEST_VECTORS - 1 LOOP

                readline(input_file, input_line);

                FOR word_counter IN DUT_N_WORDS - 1 DOWNTO 0 LOOP

                    --read one word of "a" and put it into memory
                    hread(input_line, slv_a_var, good_v);
                    a_memory(tv_counter)(word_counter) <= slv_a_var;

                END LOOP;

                FOR word_counter IN DUT_N_WORDS - 1 DOWNTO 0 LOOP

                    --read one word of "b" and put it into memory
                    hread(input_line, slv_b_var, good_v);
                    b_memory(tv_counter)(word_counter) <= slv_b_var;

                END LOOP;

                FOR word_counter IN DUT_N_WORDS - 1 DOWNTO 0 LOOP

                    --read one word of "n" and put it into memory
                    hread(input_line, slv_n_var, good_v);
                    n_memory(tv_counter)(word_counter) <= slv_n_var;

                END LOOP;

                --read "nn0" and put it into memory
                hread(input_line, slv_nn0_var, good_v);
                nn0_memory(tv_counter) <= slv_nn0_var;

            END LOOP;
        END LOOP;
        file_read_complete <= true;
        WAIT;

    END PROCESS;

    -------------------------------------

    -------- module feed process---------
    data_feed_proc : PROCESS

    BEGIN

        WAIT FOR RESET_WND;
        WAIT UNTIL rising_edge(clk);

        IF (file_read_complete = false) THEN

            WAIT UNTIL file_read_complete = true;
        END IF;

        WAIT UNTIL rising_edge(clk);
        FOR tv_counter IN 0 TO N_TEST_VECTORS - 1 LOOP

            dut_wr_en_a     <= '1';
            dut_wr_en_b     <= '1';
            dut_wr_en_n_mac <= '1';
            dut_wr_en_n_sub <= '1';
            dut_nn0         <= nn0_memory(tv_counter);

            FOR words_counter IN 0 TO DUT_N_WORDS - 1 LOOP

                dut_a <= a_memory(tv_counter)(words_counter);
                dut_b <= b_memory(tv_counter)(words_counter);
                dut_n <= n_memory(tv_counter)(words_counter);
                WAIT UNTIL rising_edge(clk);
            END LOOP;

            dut_wr_en_a     <= '0';
            dut_wr_en_b     <= '0';
            dut_wr_en_n_mac <= '0';
            dut_wr_en_n_sub <= '0';

            WAIT UNTIL rising_edge(dut_EoC);
            WAIT UNTIL rising_edge(clk);

        END LOOP;
        WAIT;

    END PROCESS;
    -----------------------------------------------------------------

    ------------------ output memory write process------------------

    out_res_mem_proc : PROCESS

    BEGIN

        WAIT UNTIL dut_valid_out = '1';

        FOR word_counter IN 0 TO DUT_N_WORDS - 1 LOOP

            WAIT UNTIL rising_edge(clk);

            res_memory (word_counter) <= dut_result;

        END LOOP;

    END PROCESS;
    ----------------------------------------------------------------

    --------------------- output file write process------------------
    file_write_proc : PROCESS

        --file      output_file : text open write_mode is "output_results.txt";         
        FILE output_file     : text OPEN write_mode IS OUTPUT_FILE_NAME;
        VARIABLE output_line : line;

    BEGIN

        WAIT UNTIL dut_EoC = '1';

        WAIT UNTIL rising_edge(clk);

        FOR word_counter IN DUT_N_WORDS - 1 DOWNTO 0 LOOP

            WAIT UNTIL rising_edge(clk);
            hwrite(output_line, res_memory(word_counter), left, (DUT_N_BITS_PER_WORD/4) + 1);

        END LOOP;

        writeline(output_file, output_line);
        writeline_complete <= true;
        WAIT UNTIL rising_edge(clk);
        writeline_complete <= false;

    END PROCESS;
    -----------------------------------------------------------------

END;