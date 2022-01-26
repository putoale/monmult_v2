
--  ############ Insert Only the Usefor Sections ################

---------- DEFAULT LIBRARY ---------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
--	use IEEE.MATH_REAL.all;

--	use STD.textio.all;
--	use ieee.std_logic_textio.all;

ENTITY tb_mac_mn IS
END tb_mac_mn;

ARCHITECTURE Behavioral OF tb_mac_mn IS

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
    -----------------------------------------------------------------

    ------------------------ TYPES DECLARATION ----------------------

    --------- SECTION ----------
    -- NONE
    ----------------------------

    -----------------------------------------------------------------
    --------------------- FUNCTIONS DECLARATION ---------------------

    --------- SECTION ----------
    -- NONE
    ----------------------------

    -----------------------------------------------------------------

    ------ COMPONENT DECLARATION for the Device Under Test (DUT) ------

    -------- First DUT ---------
    COMPONENT FSM_mac_mn IS
        GENERIC (
            N_WORDS         : INTEGER := 4;
            N_BITS_PER_WORD : INTEGER := 8

        );
        PORT (
            clk   : IN STD_LOGIC;
            reset : IN STD_LOGIC;
            start : IN STD_LOGIC;

            n         : IN STD_LOGIC_VECTOR (N_BITS_PER_WORD - 1 DOWNTO 0);
            m         : IN STD_LOGIC_VECTOR (N_BITS_PER_WORD - 1 DOWNTO 0);
            t_in      : IN STD_LOGIC_VECTOR (N_BITS_PER_WORD - 1 DOWNTO 0);
            t_mac_out : OUT STD_LOGIC_VECTOR (N_BITS_PER_WORD - 1 DOWNTO 0);
            c_mac_out : OUT STD_LOGIC_VECTOR (N_BITS_PER_WORD - 1 DOWNTO 0)

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
    SIGNAL dut_n : STD_LOGIC_VECTOR (DUT_N_BITS_PER_WORD - 1 DOWNTO 0) := (OTHERS => '0'); -- input word from mac_ab
    SIGNAL dut_m : STD_LOGIC_VECTOR (DUT_N_BITS_PER_WORD - 1 DOWNTO 0) := (OTHERS => '0'); -- input n'(0)
    --------------------------------------------------------------------------------------

    ----------------------------------Output data ports-----------------------------------
    SIGNAL dut_t_in      : STD_LOGIC_VECTOR (DUT_N_BITS_PER_WORD - 1 DOWNTO 0) := (OTHERS => '0');
    SIGNAL dut_t_mac_out : STD_LOGIC_VECTOR (DUT_N_BITS_PER_WORD - 1 DOWNTO 0) := (OTHERS => '0');
    SIGNAL dut_c_mac_out : STD_LOGIC_VECTOR (DUT_N_BITS_PER_WORD - 1 DOWNTO 0) := (OTHERS => '0');
    --------------------------------------------------------------------------------------
    ----------------------------
    ----- Last DUT Signals -----
    SIGNAL int_value : INTEGER RANGE 0 TO 2 ** (DUT_N_BITS_PER_WORD) - 1 := 15;
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
    mac_mn_dut : FSM_mac_mn
    GENERIC MAP(
        N_WORDS         => DUT_N_WORDS,
        N_BITS_PER_WORD => DUT_N_BITS_PER_WORD
    )
    PORT MAP(
        clk       => clk,
        reset     => reset,
        start     => dut_start,
        n         => dut_n,
        m         => dut_m,
        t_in      => dut_t_in,
        t_mac_out => dut_t_mac_out,

        c_mac_out => dut_c_mac_out

    );
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

        reset <= NOT reset;
        WAIT UNTIL rising_edge(clk);

        WAIT;
    END PROCESS;
    ----------------------------
    ------ Stimulus process -------

    stim_proc : PROCESS
    BEGIN
        -- waiting the reset wave
        WAIT FOR RESET_WND;
        -- Start
        WAIT UNTIL rising_edge(clk);
        dut_start <= '1';
        WAIT FOR CLK_PERIOD * 2;
        FOR i IN 0 TO DUT_N_WORDS - 1 LOOP
            FOR j IN 0 TO DUT_N_WORDS - 1 LOOP
                dut_n <= STD_LOGIC_VECTOR(to_unsigned(int_value, dut_n'length));
                IF j = 0 THEN
                    dut_m <= STD_LOGIC_VECTOR(to_unsigned(int_value, dut_n'length));
                END IF;
                dut_t_in  <= STD_LOGIC_VECTOR(to_unsigned(int_value, dut_n'length));
                int_value <= int_value + 1;
                WAIT UNTIL rising_edge(clk);
            END LOOP;
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