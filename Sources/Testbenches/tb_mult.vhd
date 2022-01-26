
--  ############ Insert Only the Usefor Sections ################

---------- DEFAULT LIBRARY ---------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
--	use IEEE.MATH_REAL.all;

--	use STD.textio.all;
--	use ieee.std_logic_textio.all;

ENTITY tb_mult IS
END tb_mult;

ARCHITECTURE Behavioral OF tb_mult IS

    ------------------ CONSTANT DECLARATION -------------------------

    --------- Timing -----------
    CONSTANT CLK_PERIOD : TIME := 10 ns;
    CONSTANT RESET_WND  : TIME := 10 * CLK_PERIOD;
    ----------------------------

    --- TB Initialiazzations ---
    CONSTANT TB_CLK_INIT   : STD_LOGIC := '0';
    CONSTANT TB_RESET_INIT : STD_LOGIC := '1';
    ----------------------------
    ------- DUT Generics -------
    CONSTANT DUT_N_WORDS         : POSITIVE RANGE 4 TO 512 := 4;
    CONSTANT DUT_N_BITS_PER_WORD : POSITIVE RANGE 8 TO 64  := 8;
    ----------------------------

    -----------Other constants-------
    CONSTANT D_IN_LENGTH : POSITIVE := DUT_N_WORDS * DUT_N_WORDS;
    ---------------------------------
    -----------------------------------------------------------------

    ------------------------ TYPES DECLARATION ----------------------

    --------- SECTION ----------
    TYPE data_in_type IS ARRAY(0 TO (D_IN_LENGTH - 1)) OF STD_LOGIC_VECTOR(DUT_N_BITS_PER_WORD - 1 DOWNTO 0);
    ----------------------------

    -----------------------------------------------------------------
    --------------------- FUNCTIONS DECLARATION ---------------------

    --------- SECTION ----------
    -- NONE
    ----------------------------

    -----------------------------------------------------------------

    ------ COMPONENT DECLARATION for the Device Under Test (DUT) ------

    -------- First DUT ---------
    COMPONENT FSM_mult IS
        GENERIC (
            N_WORDS         : POSITIVE RANGE 4 TO 512 := 4;
            N_BITS_PER_WORD : POSITIVE RANGE 8 TO 64  := 32
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
    ----------------------------
    --------- Last DUT ---------
    -- NONE
    ----------------------------

    ------------------------------------------------------------------
    --------------------- SIGNALS DECLARATION -----------------------
    ------- Clock/Reset  -------
    SIGNAL reset : STD_LOGIC := TB_RESET_INIT;
    SIGNAL clk   : STD_LOGIC := TB_CLK_INIT;
    ----------------------------

    ----- First DUT Signals ----

    SIGNAL dut_start : STD_LOGIC := '0'; -- start signal from outside

    ------------------------------Input data ports----------------------------------------
    SIGNAL dut_t_in : STD_LOGIC_VECTOR (DUT_N_BITS_PER_WORD - 1 DOWNTO 0) := (OTHERS => '0'); -- input word from mac_ab
    SIGNAL dut_nn0  : STD_LOGIC_VECTOR (DUT_N_BITS_PER_WORD - 1 DOWNTO 0) := (OTHERS => '0'); -- input n'(0)

    SIGNAL data_in_array : data_in_type := (X"02",
    X"11",
    X"22",
    X"33",
    X"44",
    X"55",
    X"66",
    X"77",
    X"88",
    X"99",
    X"AA",
    X"BB",
    X"CC",
    X"DD",
    X"EE",
    X"FF");
    --------------------------------------------------------------------------------------

    ----------------------------------Output data ports-----------------------------------
    SIGNAL dut_t_out : STD_LOGIC_VECTOR (DUT_N_BITS_PER_WORD - 1 DOWNTO 0) := (OTHERS => '0');
    SIGNAL dut_m_out : STD_LOGIC_VECTOR (DUT_N_BITS_PER_WORD - 1 DOWNTO 0) := (OTHERS => '0');
    --------------------------------------------------------------------------------------
    ----------------------------
    ----- Last DUT Signals -----
    -- NONE
    ----------------------------
    ----- OTHERS Signals -------
    -- NONE
    ----------------------------

    ----------------------------------------------------------------
    -------------------------- ATTRIBUTES --------------------------

    --------- SECTION ----------
    -- NONE
    ----------------------------

    -----------------------------------------------------------------
BEGIN
    --------------------- COMPONENTS DUT WRAPPING --------------------

    -------- First DUT ---------
    mult_dut : FSM_mult
    GENERIC MAP(
        N_WORDS         => DUT_N_WORDS,
        N_BITS_PER_WORD => DUT_N_BITS_PER_WORD
    )
    PORT MAP(
        clk   => clk,
        reset => reset,

        start => dut_start,

        t_in => dut_t_in,
        nn0  => dut_nn0,

        t_out => dut_t_out,
        m_out => dut_m_out

    );
    ----------------------------

    -------------------------------------------------------------------
    --------------------- TEST BENCH DATA FLOW  -----------------------

    ---------- clock ----------
    clk <= NOT clk AFTER CLK_PERIOD/2;
    ----------------------------

    --------- SECTION ----------
    dut_nn0 <= X"AB";
    ----------------------------

    -------------------------------------------------------------------
    ---------------------- TEST BENCH PROCESS -------------------------
    ----- Reset Process --------
    reset_wave : PROCESS
    BEGIN
        reset <= TB_RESET_INIT;
        WAIT FOR RESET_WND;

        reset     <= NOT reset;
        dut_start <= '1';
        WAIT UNTIL rising_edge(clk);
        dut_start <= '0';

        WAIT;
    END PROCESS;
    ----------------------------
    ------ Stimulus process -------

    stim_proc : PROCESS
    BEGIN
        -- waiting the reset wave
        WAIT FOR RESET_WND;
        WAIT UNTIL rising_edge(clk);

        FOR ii IN 0 TO D_IN_LENGTH - 1 LOOP

            dut_t_in <= data_in_array(ii);
            WAIT UNTIL rising_edge(clk);

        END LOOP;
        -- Start

        -- Stop
        WAIT;
    END PROCESS;
    ----------------------------
    ------ Sync Process --------
    -- NONE
    ----------------------------
    ----- Async Process --------
    -- NONE
    ----------------------------
    --------- SECTION ----------
    -- NONE
    ----------------------------

    -------------------------------------------------------------------
END;