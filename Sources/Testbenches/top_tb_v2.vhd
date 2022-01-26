LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
--	use IEEE.MATH_REAL.all;
USE STD.textio.ALL;
USE ieee.std_logic_textio.ALL;

ENTITY top_tb_v2 IS
END;

ARCHITECTURE bench OF top_tb_v2 IS

    COMPONENT monmult_module_v2
        GENERIC (
            INTERNAL_WIDTH  : INTEGER;
            EXTERNAL_WIDTH  : INTEGER;
            N_BITS_PER_WORD : INTEGER;
            N_WORDS         : INTEGER;
            -- MEMORY_DEPTH : integer;
            N_BITS_TOTAL : INTEGER
        );
        PORT (
            clk   : IN STD_LOGIC;
            reset : IN STD_LOGIC;

            wr_en_a : IN STD_LOGIC;
            wr_en_b : IN STD_LOGIC;

            wr_en_n_mac : IN STD_LOGIC;
            wr_en_n_sub : IN STD_LOGIC;
            wr_en_nn0   : IN STD_LOGIC;
            a           : IN STD_LOGIC_VECTOR(EXTERNAL_WIDTH - 1 DOWNTO 0);

            b : IN STD_LOGIC_VECTOR(EXTERNAL_WIDTH - 1 DOWNTO 0);

            n : IN STD_LOGIC_VECTOR(EXTERNAL_WIDTH - 1 DOWNTO 0);

            nn0 : IN STD_LOGIC_VECTOR(EXTERNAL_WIDTH - 1 DOWNTO 0);

            EoC : OUT STD_LOGIC;

            valid_out : OUT STD_LOGIC := '0';

            result : OUT STD_LOGIC_VECTOR(EXTERNAL_WIDTH - 1 DOWNTO 0)
        );
    END COMPONENT;

    -- Clock period
    CONSTANT CLK_PERIOD : TIME := 1 ns; --edited to try many test vectors
    CONSTANT RESET_WND  : TIME := 10 * CLK_PERIOD;

    -- TB Initialiazations
    CONSTANT TB_CLK_INIT   : STD_LOGIC := '0';
    CONSTANT TB_RESET_INIT : STD_LOGIC := '1';

    -- Generics
    CONSTANT DUT_N_BITS_PER_WORD : INTEGER := 64; --refers to the interface with the tb
    CONSTANT DUT_N_WORDS         : INTEGER := 4;
    CONSTANT DUT_N_BITS_TOTAL    : INTEGER := 256;

    CONSTANT DUT_INTERNAL_WIDTH        : INTEGER := 32;
    CONSTANT DUT_EXTERNAL_WIDTH        : INTEGER := 64;
    CONSTANT DUT_MEMORY_DEPTH          : INTEGER := DUT_N_BITS_TOTAL/DUT_INTERNAL_WIDTH; --goes to input_mem_abn
    CONSTANT DUT_EXTERNAL_MEMORY_DEPTH : INTEGER := DUT_N_BITS_TOTAL/DUT_EXTERNAL_WIDTH;
    --File GENERICS
    CONSTANT N_TEST_VECTORS : POSITIVE := 1;
    --constant INPUT_FILE_NAME  : string := "input_vectors_64_8_8.txt";
    --constant OUTPUT_FILE_NAME : string := "out_results.txt";

    --Types
    --array of N_WORDS to store an operand (e.g. to store "a")
    TYPE test_vector_input_type IS ARRAY (DUT_EXTERNAL_MEMORY_DEPTH - 1 DOWNTO 0) OF STD_LOGIC_VECTOR(DUT_EXTERNAL_WIDTH - 1 DOWNTO 0);

    -- type to store all the values of a N_WORDS operand to test (e.g. all test vectors for "a","b",or "n")
    TYPE test_vector_Nw_array IS ARRAY(0 TO N_TEST_VECTORS - 1) OF test_vector_input_type;

    TYPE test_vector_1_nn0_array IS ARRAY (DUT_INTERNAL_WIDTH/DUT_EXTERNAL_WIDTH - 1 DOWNTO 0) OF STD_LOGIC_VECTOR(DUT_EXTERNAL_WIDTH - 1 DOWNTO 0);

    -- type to store all the values of nn0 to test
    TYPE test_vector_N_nn0_array IS ARRAY(0 TO N_TEST_VECTORS - 1) OF test_vector_1_nn0_array;

    -- type to store result of one monmult
    TYPE output_result_array IS ARRAY (DUT_EXTERNAL_MEMORY_DEPTH - 1 DOWNTO 0) OF STD_LOGIC_VECTOR(DUT_EXTERNAL_WIDTH - 1 DOWNTO 0);

    -- Ports
    SIGNAL clk             : STD_LOGIC                                          := TB_CLK_INIT;
    SIGNAL reset           : STD_LOGIC                                          := TB_RESET_INIT;
    SIGNAL dut_wr_en_a     : STD_LOGIC                                          := '0';
    SIGNAL dut_wr_en_b     : STD_LOGIC                                          := '0';
    SIGNAL dut_wr_en_n_mac : STD_LOGIC                                          := '0';
    SIGNAL dut_wr_en_n_sub : STD_LOGIC                                          := '0';
    SIGNAL dut_wr_en_nn0   : STD_LOGIC                                          := '0';
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
    SIGNAL n_memory   : test_vector_Nw_array    := (OTHERS => (OTHERS => (OTHERS => '0')));
    SIGNAL nn0_memory : test_vector_N_nn0_array := (OTHERS => (OTHERS => (OTHERS => '0')));

    -- memory for one test vector result
    SIGNAL res_memory : output_result_array := (OTHERS => (OTHERS => '0'));

BEGIN

    monmult_module_inst : monmult_module_v2
    GENERIC MAP(
        EXTERNAL_WIDTH  => DUT_EXTERNAL_WIDTH,
        INTERNAL_WIDTH  => DUT_INTERNAL_WIDTH,
        N_BITS_PER_WORD => DUT_N_BITS_PER_WORD,
        N_WORDS         => DUT_N_WORDS,
        --MEMORY_DEPTH => dut_MEMORY_DEPTH,
        N_BITS_TOTAL => dut_N_BITS_TOTAL
    )
    PORT MAP(
        clk         => clk,
        reset       => reset,
        wr_en_a     => dut_wr_en_a,
        wr_en_b     => dut_wr_en_b,
        wr_en_n_mac => dut_wr_en_n_mac,
        wr_en_n_sub => dut_wr_en_n_sub,
        wr_en_nn0   => dut_wr_en_nn0,
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
    a_memory(0)(0) <= X"E41BE5BD";
    a_memory(0)(1) <= X"E54EA01C";
    a_memory(0)(2) <= X"5FD8132D";
    a_memory(0)(3) <= X"AE3C50BD";
    a_memory(0)(4) <= X"9F96C5AF";
    a_memory(0)(5) <= X"1324A68D";
    a_memory(0)(6) <= X"08D97804";
    a_memory(0)(7) <= X"8F69BF76";

    b_memory(0)(0) <= X"F9852CD2";
    b_memory(0)(1) <= X"1DE6A57F";
    b_memory(0)(2) <= X"70BA175B";
    b_memory(0)(3) <= X"EA2FFFC2";
    b_memory(0)(4) <= X"A40A26A7";
    b_memory(0)(5) <= X"D424CF6F";
    b_memory(0)(6) <= X"3CC8843F";
    b_memory(0)(7) <= X"9135D1ED";

    n_memory(0)(0) <= X"B6FB5F6D";
    n_memory(0)(1) <= X"A48F54FC";
    n_memory(0)(2) <= X"63AF7B4B";
    n_memory(0)(3) <= X"3E9C3631";
    n_memory(0)(4) <= X"CD781A52";
    n_memory(0)(5) <= X"6FB464A6";
    n_memory(0)(6) <= X"6BB3E127";
    n_memory(0)(7) <= X"E74E2C25";

    nn0_memory(0)(0) <= X"5A6EB41C";
    nn0_memory(0)(1) <= X"91A1F053";

    file_read_complete <= true;
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
            dut_wr_en_nn0   <= '1';

            FOR words_counter IN 0 TO (DUT_N_WORDS * DUT_INTERNAL_WIDTH/DUT_EXTERNAL_WIDTH) - 1 LOOP

                dut_a <= a_memory(tv_counter)(words_counter);
                dut_b <= b_memory(tv_counter)(words_counter);
                dut_n <= n_memory(tv_counter)(words_counter);

                IF words_counter < DUT_INTERNAL_WIDTH/DUT_EXTERNAL_WIDTH THEN
                    dut_nn0 <= nn0_memory(tv_counter)(words_counter);
                ELSE
                    dut_wr_en_nn0 <= '0';
                END IF;

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

        FOR word_counter IN 0 TO (DUT_N_WORDS * DUT_INTERNAL_WIDTH/DUT_EXTERNAL_WIDTH) - 1 LOOP

            WAIT UNTIL rising_edge(clk);

            res_memory (word_counter) <= dut_result;

        END LOOP;

    END PROCESS;
    ----------------------------------------------------------------

END;