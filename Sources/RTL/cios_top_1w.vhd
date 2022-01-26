--! This module includes all the computational blocks. It's embedded inside monmult_module, together with the memories.
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY cios_top_1w IS
    GENERIC (
        N_BITS_PER_WORD : INTEGER := 8;
        N_WORDS         : INTEGER := 4
    );
    PORT (
        clk   : IN STD_LOGIC;
        reset : IN STD_LOGIC;
        a     : IN STD_LOGIC_VECTOR(N_BITS_PER_WORD - 1 DOWNTO 0);
        b     : IN STD_LOGIC_VECTOR(N_BITS_PER_WORD - 1 DOWNTO 0);
        n_mac : IN STD_LOGIC_VECTOR(N_BITS_PER_WORD - 1 DOWNTO 0);
        n_sub : IN STD_LOGIC_VECTOR(N_BITS_PER_WORD - 1 DOWNTO 0);
        start : IN STD_LOGIC; --! indicates that memories are full and computation is going to start, can be one or more cycles long

        nn0       : IN STD_LOGIC_VECTOR(N_BITS_PER_WORD - 1 DOWNTO 0); --! this is the least significant word of the inverse of N modulo R, which is computed by the PC and fed to the module
        EoC       : OUT STD_LOGIC := '0'; --! End Of Conversion, is high on the last word of the valid result
        valid_out : OUT STD_LOGIC := '0'; --! Is high only when the subtractor is giving out the correct result
        result    : OUT STD_LOGIC_VECTOR(N_BITS_PER_WORD - 1 DOWNTO 0)

    );
END cios_top_1w;

ARCHITECTURE Behavioral OF cios_top_1w IS
    COMPONENT FSM_add IS
        GENERIC (
            N_WORDS         : POSITIVE                := 4;
            N_BITS_PER_WORD : POSITIVE RANGE 8 TO 512 := 32
        );
        PORT (
            -------------------------- Clk/Reset --------------------
            clk   : IN STD_LOGIC;
            reset : IN STD_LOGIC;
            ---------------------------------------------------------

            --------------------- Ctrl signals ----------------------
            start : IN STD_LOGIC;
            ---------------------------------------------------------

            ---------------------- Input data ports -----------------
            c_in_ab : IN STD_LOGIC_VECTOR (N_BITS_PER_WORD - 1 DOWNTO 0);
            c_in_mn : IN STD_LOGIC_VECTOR (N_BITS_PER_WORD - 1 DOWNTO 0);
            ---------------------------------------------------------

            ---------------------- Output data ports -----------------
            c_out : OUT STD_LOGIC_VECTOR (N_BITS_PER_WORD - 1 DOWNTO 0) := (OTHERS => '0');
            t_out : OUT STD_LOGIC_VECTOR (N_BITS_PER_WORD - 1 DOWNTO 0) := (OTHERS => '0')
            ---------------------------------------------------------
        );
    END COMPONENT;

    COMPONENT FSM_mac_ab IS
        GENERIC (
            N_WORDS         : INTEGER := 4;
            N_BITS_PER_WORD : INTEGER := 8

        );
        PORT (
            clk   : IN STD_LOGIC;
            reset : IN STD_LOGIC;
            start : IN STD_LOGIC;

            a          : IN STD_LOGIC_VECTOR (N_BITS_PER_WORD - 1 DOWNTO 0);
            b          : IN STD_LOGIC_VECTOR (N_BITS_PER_WORD - 1 DOWNTO 0);
            t_mac_in   : IN STD_LOGIC_VECTOR (N_BITS_PER_WORD - 1 DOWNTO 0);
            t_adder_in : IN STD_LOGIC_VECTOR (N_BITS_PER_WORD - 1 DOWNTO 0);
            t_mac_out  : OUT STD_LOGIC_VECTOR (N_BITS_PER_WORD - 1 DOWNTO 0);
            c_mac_out  : OUT STD_LOGIC_VECTOR (N_BITS_PER_WORD - 1 DOWNTO 0)

        );
    END COMPONENT;

    COMPONENT FSM_mac_mn IS
        GENERIC (
            N_WORDS         : INTEGER := 4;
            N_BITS_PER_WORD : INTEGER := 8

        );
        PORT (
            clk   : IN STD_LOGIC;
            reset : IN STD_LOGIC;
            start : IN STD_LOGIC; --receive start, wait 2 cycles

            n    : IN STD_LOGIC_VECTOR (N_BITS_PER_WORD - 1 DOWNTO 0);
            m    : IN STD_LOGIC_VECTOR (N_BITS_PER_WORD - 1 DOWNTO 0);
            t_in : IN STD_LOGIC_VECTOR (N_BITS_PER_WORD - 1 DOWNTO 0);

            t_mac_out : OUT STD_LOGIC_VECTOR (N_BITS_PER_WORD - 1 DOWNTO 0);
            c_mac_out : OUT STD_LOGIC_VECTOR (N_BITS_PER_WORD - 1 DOWNTO 0)

        );

    END COMPONENT;
    COMPONENT FSM_mult IS
        GENERIC (
            N_WORDS         : POSITIVE RANGE 4 TO 8192 := 4;
            N_BITS_PER_WORD : POSITIVE RANGE 8 TO 512  := 32
        );
        PORT (
            ----------------------CLK AND RESET PORTS------------------
            clk   : IN STD_LOGIC;
            reset : IN STD_LOGIC;
            -----------------------------------------------------------

            start : IN STD_LOGIC; -- start signal from outside

            ------------------------------Input data ports----------------------------------------
            t_in : IN STD_LOGIC_VECTOR (N_BITS_PER_WORD - 1 DOWNTO 0); -- input word from mac_ab
            nn0  : IN STD_LOGIC_VECTOR (N_BITS_PER_WORD - 1 DOWNTO 0); -- input n'(0)
            --------------------------------------------------------------------------------------

            ----------------------------------Output data ports-----------------------------------
            t_out : OUT STD_LOGIC_VECTOR (N_BITS_PER_WORD - 1 DOWNTO 0) := (OTHERS => '0');
            m_out : OUT STD_LOGIC_VECTOR (N_BITS_PER_WORD - 1 DOWNTO 0) := (OTHERS => '0')
            --------------------------------------------------------------------------------------

        );
    END COMPONENT;

    COMPONENT FSM_sub_v2 IS
        GENERIC (
            N_BITS_PER_WORD : POSITIVE RANGE 8 TO 512  := 32;
            N_WORDS         : POSITIVE RANGE 4 TO 8192 := 4
        );
        PORT (
            --------------------- Clk / Reset------------------
            clk   : IN STD_LOGIC;
            reset : IN STD_LOGIC;
            ---------------------------------------------------

            ----------------- Control signals------------------
            start : IN STD_LOGIC;
            ---------------------------------------------------

            -------------------- Input data -------------------
            t_in_mac : IN STD_LOGIC_VECTOR (N_BITS_PER_WORD - 1 DOWNTO 0);
            t_in_add : IN STD_LOGIC_VECTOR (N_BITS_PER_WORD - 1 DOWNTO 0);

            n_in : IN STD_LOGIC_VECTOR (N_BITS_PER_WORD - 1 DOWNTO 0);
            ---------------------------------------------------

            ------------------- Output data -------------------
            mult_result : OUT STD_LOGIC_VECTOR(N_BITS_PER_WORD - 1 DOWNTO 0) := (OTHERS => '0');
            EoC         : OUT STD_LOGIC                                      := '0';
            valid_out   : OUT STD_LOGIC                                      := '0'
            ---------------------------------------------------
        );
    END COMPONENT;

    ------------------------SIGNALS---------------------------------------------
    SIGNAL t_out_ab : STD_LOGIC_VECTOR(N_BITS_PER_WORD - 1 DOWNTO 0) := (OTHERS => '0');
    SIGNAL c_out_ab : STD_LOGIC_VECTOR(N_BITS_PER_WORD - 1 DOWNTO 0) := (OTHERS => '0');

    SIGNAL m : STD_LOGIC_VECTOR (N_BITS_PER_WORD - 1 DOWNTO 0) := (OTHERS => '0');

    SIGNAL t_mac_out_mn : STD_LOGIC_VECTOR (N_BITS_PER_WORD - 1 DOWNTO 0) := (OTHERS => '0');
    SIGNAL c_out_mn     : STD_LOGIC_VECTOR (N_BITS_PER_WORD - 1 DOWNTO 0) := (OTHERS => '0');
    SIGNAL t_out_mn     : STD_LOGIC_VECTOR (N_BITS_PER_WORD - 1 DOWNTO 0) := (OTHERS => '0');

    SIGNAL c_in_ab : STD_LOGIC_VECTOR (N_BITS_PER_WORD - 1 DOWNTO 0) := (OTHERS => '0');
    SIGNAL c_in_mn : STD_LOGIC_VECTOR (N_BITS_PER_WORD - 1 DOWNTO 0) := (OTHERS => '0');
    ---------------------------------------------------------

    SIGNAL c_out : STD_LOGIC_VECTOR (N_BITS_PER_WORD - 1 DOWNTO 0) := (OTHERS => '0');
    SIGNAL t_out : STD_LOGIC_VECTOR (N_BITS_PER_WORD - 1 DOWNTO 0) := (OTHERS => '0');

    SIGNAL t_in       : STD_LOGIC_VECTOR (N_BITS_PER_WORD - 1 DOWNTO 0) := (OTHERS => '0');
    SIGNAL n_in       : STD_LOGIC_VECTOR (N_BITS_PER_WORD - 1 DOWNTO 0) := (OTHERS => '0');
    SIGNAL t_adder    : STD_LOGIC_VECTOR (N_BITS_PER_WORD - 1 DOWNTO 0) := (OTHERS => '0');
    SIGNAL t_out_mult : STD_LOGIC_VECTOR (N_BITS_PER_WORD - 1 DOWNTO 0) := (OTHERS => '0');

    ----------------------------------------------------------------------------
BEGIN

    -------instantiations-------------------------------------------------------
    mac_ab_inst : FSM_mac_ab
    GENERIC MAP(
        N_WORDS         => N_WORDS,
        N_BITS_PER_WORD => N_BITS_PER_WORD
    )
    PORT MAP(
        clk        => clk,
        reset      => reset,
        start      => start,
        a          => a,
        b          => b,
        t_mac_in   => t_out_mn,
        t_adder_in => t_adder,
        t_mac_out  => t_out_ab,
        c_mac_out  => c_out_ab
    );

    mac_mn_inst : FSM_mac_mn
    GENERIC MAP(
        N_WORDS         => N_WORDS,
        N_BITS_PER_WORD => N_BITS_PER_WORD
    )
    PORT MAP(
        clk       => clk,
        reset     => reset,
        start     => start,
        n         => n_mac,
        m         => m,
        t_in      => t_out_mult,
        t_mac_out => t_out_mn,
        c_mac_out => c_out_mn
    );

    mult_inst : FSM_mult
    GENERIC MAP(
        N_WORDS         => N_WORDS,
        N_BITS_PER_WORD => N_BITS_PER_WORD
    )
    PORT MAP(
        clk   => clk,
        reset => reset,
        start => start,
        t_in  => t_out_ab,
        nn0   => nn0,
        t_out => t_out_mult,
        m_out => m
    );

    add_inst : FSM_add
    GENERIC MAP(
        N_WORDS         => N_WORDS,
        N_BITS_PER_WORD => N_BITS_PER_WORD
    )
    PORT MAP(

        clk     => clk,
        reset   => reset,
        start   => start,
        c_in_ab => c_out_ab,
        c_in_mn => c_out_mn,
        c_out   => OPEN,
        t_out   => t_adder

    );
    sub_inst : FSM_sub_v2
    GENERIC MAP(
        N_WORDS         => N_WORDS,
        N_BITS_PER_WORD => N_BITS_PER_WORD
    )
    PORT MAP(
        clk         => clk,
        reset       => reset,
        start       => start,
        EoC         => EoC,
        valid_out   => valid_out,
        t_in_mac    => t_out_mn,
        t_in_add    => t_adder,
        n_in        => n_sub,
        mult_result => result
    );
    ----------------------------------------------------------------------------
END Behavioral;