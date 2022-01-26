

--! this is the module that contains all the others, and wires them together

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
ENTITY monmult_module IS
    GENERIC (
        WRITE_WIDTH     : INTEGER := 16; --!MUST BE SET THE SAME AS NUMBER OF BITS PER WORD
        READ_WIDTH      : INTEGER := 16; --!MUST BE SET THE SAME AS NUMBER OF BITS PER WORD
        N_BITS_PER_WORD : INTEGER := 16;
        N_WORDS         : INTEGER := 16; --!IS THE RESULT OF TOTAL_BITS/N_BITS_PER_WORD
        MEMORY_DEPTH    : INTEGER := 16  --!IT IS THE SAME OF N_WORDS

    );
    PORT (
        clk         : IN STD_LOGIC;
        reset       : IN STD_LOGIC;
        wr_en_a     : IN STD_LOGIC;                                              --! will be rised by the testbench when the data are ready to be loaded in the input memories
        wr_en_b     : IN STD_LOGIC;                                              --! will be rised by the testbench when the data are ready to be loaded in the input memories
        wr_en_n_mac : IN STD_LOGIC;                                              --! will be rised by the testbench when the data are ready to be loaded in the input memories
        wr_en_n_sub : IN STD_LOGIC;                                              --! will be rised by the testbench when the data are ready to be loaded in the input memories
        a           : IN STD_LOGIC_VECTOR(N_BITS_PER_WORD - 1 DOWNTO 0);         --! data inputs to be loaded to input memories will be fed one word at a time
        b           : IN STD_LOGIC_VECTOR(N_BITS_PER_WORD - 1 DOWNTO 0);         --! data inputs to be loaded to input memories will be fed one word at a time
        n           : IN STD_LOGIC_VECTOR(N_BITS_PER_WORD - 1 DOWNTO 0);         --! data inputs to be loaded to input memories will be fed one word at a time
        nn0         : IN STD_LOGIC_VECTOR(N_BITS_PER_WORD - 1 DOWNTO 0);         --! data inputs to be loaded to input memories will be fed one word at a time
        EoC         : OUT STD_LOGIC                                      := '0'; --! End Of Conversion, is high on the last word of the valid result
        valid_out   : OUT STD_LOGIC                                      := '0'; --! Is high only when the subtractor is giving out the correct result
        result      : OUT STD_LOGIC_VECTOR(N_BITS_PER_WORD - 1 DOWNTO 0) := (OTHERS => '0')
    );
END monmult_module;

ARCHITECTURE Behavioral OF monmult_module IS
    ------------------------SIGNALS---------------------------------------------
    ----------------------------------------------------------------------------

    CONSTANT LATENCY_AB    : INTEGER := 1;                                        --! this constant controls after how many cycles startig from the start signal is mac_ab going to start reading
    CONSTANT LATENCY_N_SUB : INTEGER := LATENCY_AB + N_WORDS * (N_WORDS - 1) + 4; --! this constant controls after how many cycles startig from the start signal is sub going to start reading
    CONSTANT LATENCY_N_MAC : INTEGER := LATENCY_AB + 2;                           --! this constant controls after how many cycles startig from the start signal is mac_mn going to start reading
    ----------------------------------------------------------------------------

    ----------------------------------------------------------------------------
    -- these signals are used to perform the connections between the internal modules
    SIGNAL a_mem     : STD_LOGIC_VECTOR(N_BITS_PER_WORD - 1 DOWNTO 0);
    SIGNAL b_mem     : STD_LOGIC_VECTOR(N_BITS_PER_WORD - 1 DOWNTO 0);
    SIGNAL n_mac_mem : STD_LOGIC_VECTOR(N_BITS_PER_WORD - 1 DOWNTO 0);
    SIGNAL n_sub_mem : STD_LOGIC_VECTOR(N_BITS_PER_WORD - 1 DOWNTO 0);

    SIGNAL start_a     : STD_LOGIC;
    SIGNAL start_b     : STD_LOGIC;
    SIGNAL start_n_mac : STD_LOGIC;
    SIGNAL start_n_sub : STD_LOGIC;
    SIGNAL EoC_sig     : STD_LOGIC;
    SIGNAL EoC_reg     : STD_LOGIC := '0';
    SIGNAL memory_full : STD_LOGIC;

    SIGNAL start_mem     : STD_LOGIC; --! signals that memories can begin exposing data at their outputs
    SIGNAL start_modules : STD_LOGIC; --!signal that modules can start to wait for their respective latencies
    ----------------------------------------------------------------------------
    -------------------------COMPONENT DECLARATIONS-----------------------------
    COMPONENT cios_top_1w IS
        GENERIC (
            N_BITS_PER_WORD : INTEGER := 8;
            N_WORDS         : INTEGER := 4
        );
        PORT (
            clk       : IN STD_LOGIC;
            reset     : IN STD_LOGIC;
            a         : IN STD_LOGIC_VECTOR(N_BITS_PER_WORD - 1 DOWNTO 0);
            b         : IN STD_LOGIC_VECTOR(N_BITS_PER_WORD - 1 DOWNTO 0);
            n_mac     : IN STD_LOGIC_VECTOR(N_BITS_PER_WORD - 1 DOWNTO 0);
            n_sub     : IN STD_LOGIC_VECTOR(N_BITS_PER_WORD - 1 DOWNTO 0);
            start     : IN STD_LOGIC;
            nn0       : IN STD_LOGIC_VECTOR(N_BITS_PER_WORD - 1 DOWNTO 0);
            result    : OUT STD_LOGIC_VECTOR(N_BITS_PER_WORD - 1 DOWNTO 0);
            EoC       : OUT STD_LOGIC := '0';
            valid_out : OUT STD_LOGIC := '0'

        );
    END COMPONENT;
    COMPONENT start_regulator IS

        PORT (
            clk              : IN STD_LOGIC;
            reset            : IN STD_LOGIC;
            in_1             : IN STD_LOGIC;
            in_2             : IN STD_LOGIC;
            in_3             : IN STD_LOGIC;
            in_4             : IN STD_LOGIC;
            EoC              : IN STD_LOGIC;
            output_start     : OUT STD_LOGIC := '0';
            output_start_reg : OUT STD_LOGIC := '0'
        );
    END COMPONENT;

    COMPONENT input_mem_abn IS
        GENERIC (
            WRITE_WIDTH    : INTEGER := 8;
            READ_WIDTH     : INTEGER := 8;
            CYLCES_TO_WAIT : INTEGER := 4;
            LATENCY        : INTEGER := 4;
            MEMORY_DEPTH   : INTEGER := 16
        );
        PORT (

            clk         : IN STD_LOGIC;
            reset       : IN STD_LOGIC;
            memory_full : OUT STD_LOGIC;

            wr_en    : IN STD_LOGIC;
            wr_port  : IN STD_LOGIC_VECTOR(WRITE_WIDTH - 1 DOWNTO 0);
            rd_en    : IN STD_LOGIC;
            rd_port  : OUT STD_LOGIC_VECTOR(READ_WIDTH - 1 DOWNTO 0);
            start    : OUT STD_LOGIC;
            start_in : IN STD_LOGIC := '0';

            EoC_in : IN STD_LOGIC

        );
    END COMPONENT;

BEGIN
    EoC <= EoC_reg;
    ---------------------INSTANTIATIONS-----------------------------------------
    inst_cios_1w : cios_top_1w
    GENERIC MAP(
        N_BITS_PER_WORD => N_BITS_PER_WORD,
        N_WORDS         => N_WORDS

    )
    PORT MAP(
        clk       => clk,
        reset     => reset,
        a         => a_mem,
        b         => b_mem,
        n_mac     => n_mac_mem,
        n_sub     => n_sub_mem,
        start     => start_modules,
        nn0       => nn0,
        result    => result,
        valid_out => valid_out,
        EoC       => EoC_sig
    );

    mem_a_inst : input_mem_abn
    GENERIC MAP(
        WRITE_WIDTH    => N_BITS_PER_WORD,
        READ_WIDTH     => N_BITS_PER_WORD,
        CYLCES_TO_WAIT => 1,
        LATENCY        => LATENCY_AB,

        MEMORY_DEPTH => N_WORDS
    )
    PORT MAP(
        clk         => clk,
        reset       => reset,
        memory_full => OPEN,
        wr_en       => wr_en_a,
        wr_port     => a,
        rd_en       => '1',
        rd_port     => a_mem,
        start       => start_a,
        start_in    => start_mem,
        EoC_in      => EoC_sig

    );

    mem_b_inst : input_mem_abn
    GENERIC MAP(
        WRITE_WIDTH    => N_BITS_PER_WORD,
        READ_WIDTH     => N_BITS_PER_WORD,
        CYLCES_TO_WAIT => N_WORDS,
        LATENCY        => LATENCY_AB,

        MEMORY_DEPTH => N_WORDS
    )
    PORT MAP(
        clk         => clk,
        reset       => reset,
        memory_full => OPEN,
        wr_en       => wr_en_b,
        wr_port     => b,
        rd_en       => '1',
        EoC_in      => EoC_sig,
        start       => start_b,
        start_in    => start_mem,

        rd_port => b_mem
    );

    mem_n_mac_inst : input_mem_abn
    GENERIC MAP(
        WRITE_WIDTH    => N_BITS_PER_WORD,
        READ_WIDTH     => N_BITS_PER_WORD,
        CYLCES_TO_WAIT => 1,
        LATENCY        => LATENCY_N_MAC,

        MEMORY_DEPTH => N_WORDS
    )
    PORT MAP(
        clk         => clk,
        reset       => reset,
        memory_full => OPEN,
        wr_en       => wr_en_n_mac,
        wr_port     => n,
        rd_en       => '1',
        EoC_in      => EoC_sig,
        start       => start_n_mac,
        start_in    => start_mem,

        rd_port => n_mac_mem
    );

    mem_n_sub_inst : input_mem_abn
    GENERIC MAP(
        WRITE_WIDTH    => N_BITS_PER_WORD,
        READ_WIDTH     => N_BITS_PER_WORD,
        CYLCES_TO_WAIT => 1,
        LATENCY        => LATENCY_N_SUB,

        MEMORY_DEPTH => N_WORDS
    )
    PORT MAP(
        clk         => clk,
        reset       => reset,
        memory_full => OPEN,
        wr_en       => wr_en_n_sub,
        wr_port     => n,
        rd_en       => '1',
        EoC_in      => EoC_sig,
        start       => start_n_sub,
        start_in    => start_mem,

        rd_port => n_sub_mem
    );
    regulator_inst : start_regulator
    PORT MAP(

        clk              => clk,
        reset            => reset,
        in_1             => start_a,
        in_2             => start_b,
        in_3             => start_n_mac,
        in_4             => start_n_sub,
        EoC              => EoC_sig,
        output_start     => start_mem,
        output_start_reg => start_modules
    );

    PROCESS (clk)
    BEGIN
        IF rising_edge(clk) THEN
            EoC_reg <= EoC_sig;
        END IF;
    END PROCESS;
    ----------------------------------------------------------------------------
END Behavioral;