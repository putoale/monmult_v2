
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
ENTITY tb_sub_v2 IS
END tb_sub_v2;

ARCHITECTURE Behavioral OF tb_sub_v2 IS

    ------------------ CONSTANT DECLARATION -------------------------

    --------- Timing -----------
    CONSTANT CLK_PERIOD : TIME := 10 ns;
    CONSTANT RESET_WND  : TIME := 10 * CLK_PERIOD;
    ----------------------------

    --- TB Initialiazations ---
    CONSTANT TB_CLK_INIT   : STD_LOGIC := '0';
    CONSTANT TB_RESET_INIT : STD_LOGIC := '1';
    ----------------------------
    ------- DUT Generics -------
    CONSTANT DUT_N_BITS_PER_WORD : POSITIVE RANGE 8 TO 64  := 8;
    CONSTANT DUT_N_WORDS         : POSITIVE RANGE 4 TO 512 := 4;
    ----------------------------

    ---------- OTHERS ----------
    CONSTANT CLK_TO_DATA_IN : POSITIVE := DUT_N_WORDS * (DUT_N_WORDS - 1) + 2;
    ----------------------------

    -----------------------------------------------------------------

    ------------------------ TYPES DECLARATION ----------------------

    --------- SECTION ----------
    TYPE data_in_type IS ARRAY(0 TO DUT_N_WORDS - 1) OF STD_LOGIC_VECTOR(DUT_N_BITS_PER_WORD - 1 DOWNTO 0);
    ----------------------------

    -----------------------------------------------------------------
    --------------------- FUNCTIONS DECLARATION ---------------------

    --------- SECTION ----------
    -- NONE
    ----------------------------

    -----------------------------------------------------------------

    ------ COMPONENT DECLARATION for the Device Under Test (DUT) ------

    -------- First DUT ---------
    COMPONENT FSM_sub_v2 IS
        GENERIC (
            N_BITS_PER_WORD : POSITIVE RANGE 8 TO 64  := 32;
            N_WORDS         : POSITIVE RANGE 4 TO 512 := 4
        );
        PORT (
            --------------------- Clk / Reset------------------
            clk   : IN STD_LOGIC;
            reset : IN STD_LOGIC;
            ---------------------------------------------------

            ----------------- Control signals------------------
            start     : IN STD_LOGIC;
            EoC       : OUT STD_LOGIC;
            valid_out : OUT STD_LOGIC := '0';
            ---------------------------------------------------

            -------------------- Input data -------------------
            t_in_mac : STD_LOGIC_VECTOR (N_BITS_PER_WORD - 1 DOWNTO 0);
            t_in_add : STD_LOGIC_VECTOR (N_BITS_PER_WORD - 1 DOWNTO 0);
            n_in     : STD_LOGIC_VECTOR (N_BITS_PER_WORD - 1 DOWNTO 0);
            ---------------------------------------------------

            ------------------- Output data -------------------
            mult_result : OUT STD_LOGIC_VECTOR(N_BITS_PER_WORD - 1 DOWNTO 0) := (OTHERS => '0')
            ---------------------------------------------------
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

    ----------------- Control signals------------------
    SIGNAL dut_start     : STD_LOGIC := '0';
    SIGNAL dut_EoC       : STD_LOGIC := '0';
    SIGNAL dut_valid_out : STD_LOGIC := '0';
    ---------------------------------------------------

    -------------------- Input data -------------------
    SIGNAL dut_t_in_mac : STD_LOGIC_VECTOR (DUT_N_BITS_PER_WORD - 1 DOWNTO 0) := (OTHERS => '0');
    SIGNAL dut_t_in_add : STD_LOGIC_VECTOR (DUT_N_BITS_PER_WORD - 1 DOWNTO 0) := (OTHERS => '0');
    SIGNAL dut_n_in     : STD_LOGIC_VECTOR (DUT_N_BITS_PER_WORD - 1 DOWNTO 0) := (OTHERS => '0');
    ---------------------------------------------------

    ------------------- Output data -------------------
    SIGNAL dut_mult_result : STD_LOGIC_VECTOR(DUT_N_BITS_PER_WORD - 1 DOWNTO 0) := (OTHERS => '0');
    ---------------------------------------------------

    ------------------------------Input data ports----------------------------------------

    SIGNAL big_in_array : data_in_type := (
        X"88",
        X"99",
        X"AA",
        X"BB"
    );

    SIGNAL small_in_array : data_in_type := (X"02",
    X"11",
    X"22",
    X"33"
    );
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
    FSM_sub_inst : FSM_sub_v2
    GENERIC MAP(
        N_BITS_PER_WORD => DUT_N_BITS_PER_WORD,
        N_WORDS         => DUT_N_WORDS

    )
    PORT MAP(
        clk       => clk,
        reset     => reset,
        start     => dut_start,
        EoC       => dut_EoC,
        valid_out => dut_valid_out,

        t_in_mac => dut_t_in_mac,
        t_in_add => dut_t_in_add,
        n_in     => dut_n_in,

        mult_result => dut_mult_result
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

    stim_proc : PROCESS
    BEGIN
        -- waiting the reset wave
        WAIT FOR RESET_WND;
        WAIT UNTIL rising_edge(clk);

        FOR i IN 0 TO CLK_TO_DATA_IN - 1 LOOP
            WAIT UNTIL rising_edge(clk);
        END LOOP;

        FOR i IN 0 TO DUT_N_WORDS - 2 LOOP

            dut_t_in_mac <= small_in_array(i);
            dut_n_in     <= big_in_array(i);
            WAIT UNTIL rising_edge(clk);

        END LOOP;
        dut_n_in     <= X"ED";
        dut_t_in_add <= big_in_array(small_in_array'high);

        -- Start
        -- Stop
        WAIT;
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