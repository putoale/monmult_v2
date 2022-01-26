
--  ############ Insert Only the Usefor Sections ################

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
ENTITY tb_add IS
END tb_add;

ARCHITECTURE Behavioral OF tb_add IS

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
    CONSTANT DUT_N_WORDS         : POSITIVE RANGE 4 TO 512 := 5;
    CONSTANT DUT_N_BITS_PER_WORD : POSITIVE RANGE 8 TO 64  := 8;
    ----------------------------

    ---------- OTHERS ----------
    CONSTANT D_IN_LENGTH : POSITIVE RANGE 2 TO 512 := 2;
    ----------------------------

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
    COMPONENT FSM_add IS
        GENERIC (
            N_WORDS         : POSITIVE RANGE 4 TO 512 := 4;
            N_BITS_PER_WORD : POSITIVE RANGE 8 TO 64  := 32
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

    --------------------- Ctrl signals ----------------------
    SIGNAL dut_start : STD_LOGIC;
    ---------------------------------------------------------

    ---------------------- Input data ports -----------------
    SIGNAL dut_c_in_ab : STD_LOGIC_VECTOR (DUT_N_BITS_PER_WORD - 1 DOWNTO 0) := (OTHERS => '0');
    SIGNAL dut_c_in_mn : STD_LOGIC_VECTOR (DUT_N_BITS_PER_WORD - 1 DOWNTO 0) := (OTHERS => '0');
    ---------------------------------------------------------

    ---------------------- Output data ports -----------------
    SIGNAL dut_c_out : STD_LOGIC_VECTOR (DUT_N_BITS_PER_WORD - 1 DOWNTO 0) := (OTHERS => '0');
    SIGNAL dut_t_out : STD_LOGIC_VECTOR (DUT_N_BITS_PER_WORD - 1 DOWNTO 0) := (OTHERS => '0');
    ---------------------------------------------------------
    ----------------------------
    ----- Last DUT Signals -----
    -- NONE
    ----------------------------
    ----- OTHERS Signals -------
    SIGNAL c_in_ab_array : data_in_type := (X"02",
    X"11");

    SIGNAL c_in_mn_array : data_in_type := (X"44",
    X"FF");

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
    FSM_add_dut : FSM_add
    GENERIC MAP(
        N_WORDS         => DUT_N_WORDS,
        N_BITS_PER_WORD => DUT_N_BITS_PER_WORD

    )
    PORT MAP(
        clk   => clk,
        reset => reset,

        start => dut_start,

        c_in_ab => dut_c_in_ab,
        c_in_mn => dut_c_in_mn,

        c_out => dut_c_out,
        t_out => dut_t_out

    );
    ----------------------------
    --------- Last DUT ---------
    -- NONE
    ----------------------------
    -------------------------------------------------------------------
    --------------------- TEST BENCH DATA FLOW  -----------------------

    ---------- clock ----------
    clk <= NOT clk AFTER CLK_PERIOD/2;
    ----------------------------

    --------- SECTION ----------
    -- NONE
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

    stim_proc_ab : PROCESS
    BEGIN
        -- waiting the reset wave
        WAIT FOR RESET_WND;

        -- Start

        FOR i IN 0 TO DUT_N_WORDS - 1 LOOP
            WAIT UNTIL rising_edge(clk);
        END LOOP;

        FOR i IN 0 TO D_IN_LENGTH - 1 LOOP

            dut_c_in_ab <= c_in_ab_array(i);
            WAIT UNTIL rising_edge(clk);

        END LOOP;

        -- Stop

        WAIT;
    END PROCESS;

    stim_proc_mn : PROCESS
    BEGIN
        -- waiting the reset wave
        WAIT FOR RESET_WND;

        -- Start

        FOR i IN 0 TO DUT_N_WORDS + 1 LOOP
            WAIT UNTIL rising_edge(clk);
        END LOOP;

        FOR i IN 0 TO D_IN_LENGTH - 1 LOOP

            dut_c_in_mn <= c_in_mn_array(i);
            WAIT UNTIL rising_edge(clk);

        END LOOP;

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