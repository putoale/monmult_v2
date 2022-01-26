
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
--!\brief this experimental version, adds the possibility of loading
--!from the testbench operands with a width different from the width
--!at which the computation is done
ENTITY monmult_module_v2 IS
    GENERIC (

        EXTERNAL_WIDTH  : INTEGER := 16; --! width at which the words are loaded from the testbench
        INTERNAL_WIDTH  : INTEGER := 32; --! width at which the words are read by the internal modules
        N_BITS_PER_WORD : INTEGER := 32; --!must be equal to INTERNAL_WIDTH
        N_WORDS         : INTEGER := 8;  --!
        MEMORY_DEPTH    : INTEGER := 8;  --!
        N_BITS_TOTAL    : INTEGER := 256 --!

    );
    PORT (
        clk         : IN STD_LOGIC;
        reset       : IN STD_LOGIC;
        wr_en_a     : IN STD_LOGIC;
        wr_en_b     : IN STD_LOGIC;
        wr_en_n_mac : IN STD_LOGIC;
        wr_en_n_sub : IN STD_LOGIC;
        wr_en_nn0   : IN STD_LOGIC;
        a           : IN STD_LOGIC_VECTOR(EXTERNAL_WIDTH - 1 DOWNTO 0);
        b           : IN STD_LOGIC_VECTOR(EXTERNAL_WIDTH - 1 DOWNTO 0);
        n           : IN STD_LOGIC_VECTOR(EXTERNAL_WIDTH - 1 DOWNTO 0);
        nn0         : IN STD_LOGIC_VECTOR(EXTERNAL_WIDTH - 1 DOWNTO 0);
        EoC         : OUT STD_LOGIC                                     := '0';
        valid_out   : OUT STD_LOGIC                                     := '0';
        result      : OUT STD_LOGIC_VECTOR(EXTERNAL_WIDTH - 1 DOWNTO 0) := (OTHERS => '0')
    );
END monmult_module_v2;

ARCHITECTURE Behavioral OF monmult_module_v2 IS
    ------------------------SIGNALS---------------------------------------------N_WORDS

    CONSTANT LATENCY_AB    : INTEGER := 1;
    CONSTANT LATENCY_N_SUB : INTEGER := LATENCY_AB + N_WORDS * (N_WORDS - 1) + 4;
    CONSTANT LATENCY_N_MAC : INTEGER := LATENCY_AB + 2;
    SIGNAL a_mem           : STD_LOGIC_VECTOR(INTERNAL_WIDTH - 1 DOWNTO 0);
    SIGNAL b_mem           : STD_LOGIC_VECTOR(INTERNAL_WIDTH - 1 DOWNTO 0);
    SIGNAL n_mac_mem       : STD_LOGIC_VECTOR(INTERNAL_WIDTH - 1 DOWNTO 0);
    SIGNAL n_sub_mem       : STD_LOGIC_VECTOR(INTERNAL_WIDTH - 1 DOWNTO 0);
    SIGNAL nn0_mem         : STD_LOGIC_VECTOR(INTERNAL_WIDTH - 1 DOWNTO 0);
    SIGNAL start_a         : STD_LOGIC;
    SIGNAL start_b         : STD_LOGIC;
    SIGNAL start_n_mac     : STD_LOGIC;
    SIGNAL start_n_sub     : STD_LOGIC;
    SIGNAL start_nn0       : STD_LOGIC;

    --signal start: std_logic;
    SIGNAL EoC_sig     : STD_LOGIC;
    SIGNAL EoC_reg     : STD_LOGIC := '0';
    SIGNAL memory_full : STD_LOGIC;

    SIGNAL start_mem     : STD_LOGIC;
    SIGNAL start_modules : STD_LOGIC;

    SIGNAL result_sub    : STD_LOGIC_VECTOR(INTERNAL_WIDTH - 1 DOWNTO 0);
    SIGNAL valid_out_sub : STD_LOGIC;
    ----------------------------------------------------------------------------
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

    COMPONENT input_mem_v2 IS
        GENERIC (
            WRITE_WIDTH    : INTEGER := 8;
            READ_WIDTH     : INTEGER := 8; --assuming READ_WIDTH=WRITE_WIDT, for now
            CYLCES_TO_WAIT : INTEGER := 4; --goes from 1 for a to and entire N_WORDS for b
            LATENCY        : INTEGER := 4; --goes from 1 to what needed
            N_BITS_TOTAL   : INTEGER := 64
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
    COMPONENT out_mem_controller IS
        GENERIC (
            write_width : INTEGER := 64;
            read_width  : INTEGER := 16; --write_width must be a multiple of read_width. since this is an output controller

            N_BITS_TOTAL : INTEGER := 256
        );
        PORT (
            clk       : IN STD_LOGIC;
            reset     : IN STD_LOGIC;
            out_valid : OUT STD_LOGIC; -- stays at 1 as long as there are valid data on rd_port (connects to the valid of monmult_module)
            wr_en     : IN STD_LOGIC;  -- this is the valid of the sub
            wr_port   : IN STD_LOGIC_VECTOR(write_width - 1 DOWNTO 0);
            rd_port   : OUT STD_LOGIC_VECTOR(read_width - 1 DOWNTO 0);
            EoC_out   : OUT STD_LOGIC; --rises with the last word on the rd_port
            eoc_in    : IN STD_LOGIC
        );
    END COMPONENT out_mem_controller;
BEGIN
    EoC <= EoC_reg;
    -------instantiations-------------------------------------------------------
    inst_cios_1w : cios_top_1w
    GENERIC MAP(
        N_BITS_PER_WORD => INTERNAL_WIDTH,
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
        nn0       => nn0_mem,
        result    => result_sub,
        valid_out => valid_out_sub,
        EoC       => EoC_sig
    );

    mem_a_inst : input_mem_v2
    GENERIC MAP(
        WRITE_WIDTH    => EXTERNAL_WIDTH,
        READ_WIDTH     => INTERNAL_WIDTH,
        CYLCES_TO_WAIT => 1,
        LATENCY        => LATENCY_AB,
        N_BITS_TOTAL   => N_BITS_TOTAL
    )
    PORT MAP(
        clk         => clk,
        reset       => reset,
        memory_full => memory_full,
        wr_en       => wr_en_a,
        wr_port     => a,
        rd_en       => '1',
        rd_port     => a_mem,
        start       => start_a,
        start_in    => start_mem,
        EoC_in      => EoC_sig

    );

    mem_b_inst : input_mem_v2
    GENERIC MAP(
        WRITE_WIDTH    => EXTERNAL_WIDTH,
        READ_WIDTH     => INTERNAL_WIDTH,
        CYLCES_TO_WAIT => N_WORDS,
        LATENCY        => LATENCY_AB,
        N_BITS_TOTAL   => N_BITS_TOTAL

    )
    PORT MAP(
        clk         => clk,
        reset       => reset,
        memory_full => memory_full,
        wr_en       => wr_en_b,
        wr_port     => b,
        rd_en       => '1',
        EoC_in      => EoC_sig,
        start       => start_b,
        start_in    => start_mem,

        rd_port => b_mem
    );

    mem_n_mac_inst : input_mem_v2
    GENERIC MAP(
        WRITE_WIDTH    => EXTERNAL_WIDTH,
        READ_WIDTH     => INTERNAL_WIDTH,
        CYLCES_TO_WAIT => 1,
        LATENCY        => LATENCY_N_MAC,
        N_BITS_TOTAL   => N_BITS_TOTAL

    )
    PORT MAP(
        clk         => clk,
        reset       => reset,
        memory_full => memory_full,
        wr_en       => wr_en_n_mac,
        wr_port     => n,
        rd_en       => '1',
        EoC_in      => EoC_sig,
        start       => start_n_mac,
        start_in    => start_mem,

        rd_port => n_mac_mem
    );

    mem_n_sub_inst : input_mem_v2
    GENERIC MAP(
        WRITE_WIDTH    => EXTERNAL_WIDTH,
        READ_WIDTH     => INTERNAL_WIDTH,
        CYLCES_TO_WAIT => 1,
        LATENCY        => LATENCY_N_SUB,
        N_BITS_TOTAL   => N_BITS_TOTAL

    )
    PORT MAP(
        clk         => clk,
        reset       => reset,
        memory_full => memory_full,
        wr_en       => wr_en_n_sub,
        wr_port     => n,
        rd_en       => '1',
        EoC_in      => EoC_sig,
        start       => start_n_sub,
        start_in    => start_mem,

        rd_port => n_sub_mem
    );
    mem_nn0_inst : input_mem_v2
    GENERIC MAP(
        WRITE_WIDTH    => EXTERNAL_WIDTH,
        READ_WIDTH     => INTERNAL_WIDTH,
        CYLCES_TO_WAIT => 1,
        LATENCY        => 1,
        N_BITS_TOTAL   => INTERNAL_WIDTH

    )
    PORT MAP(
        clk         => clk,
        reset       => reset,
        memory_full => memory_full,
        wr_en       => wr_en_nn0,
        wr_port     => nn0,
        rd_en       => '1',
        EoC_in      => EoC_sig,
        start       => start_n_sub,
        start_in    => start_mem,

        rd_port => nn0_mem
    );
    output_controller_inst : out_mem_controller

    GENERIC MAP(
        write_width  => INTERNAL_WIDTH,
        read_width   => EXTERNAL_WIDTH,
        N_BITS_TOTAL => N_BITS_TOTAL
    )
    PORT MAP(
        clk       => clk,
        reset     => reset,
        out_valid => valid_out,
        wr_en     => valid_out_sub,
        wr_port   => result_sub,
        rd_port   => result,
        EoC_out   => EoC,
        eoc_in    => EoC_sig
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