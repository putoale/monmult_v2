
--  ############ Insert Only the Usefor Sections ################

---------- DEFAULT LIBRARY ---------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
--	use IEEE.MATH_REAL.all;

--	use STD.textio.all;
--	use ieee.std_logic_textio.all;

ENTITY tb_mac_ab IS
END tb_mac_ab;

ARCHITECTURE Behavioral OF tb_mac_ab IS

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
    CONSTANT DUT_N_WORDS         : POSITIVE RANGE 4 TO 512 := 16;
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
    CONSTANT ADDER_VALUE : INTEGER   := 2 ** DUT_N_BITS_PER_WORD - 1;
    SIGNAL dut_start     : STD_LOGIC := '0'; -- start signal from outside

    ------------------------------Input data ports----------------------------------------
    SIGNAL dut_a : STD_LOGIC_VECTOR (DUT_N_BITS_PER_WORD - 1 DOWNTO 0) := (OTHERS => '0'); -- input word from mac_ab
    SIGNAL dut_b : STD_LOGIC_VECTOR (DUT_N_BITS_PER_WORD - 1 DOWNTO 0) := (OTHERS => '0'); -- input n'(0)
    --------------------------------------------------------------------------------------

    ----------------------------------Output data ports-----------------------------------
    SIGNAL dut_t_mac_in   : STD_LOGIC_VECTOR (DUT_N_BITS_PER_WORD - 1 DOWNTO 0) := (OTHERS => '0');
    SIGNAL dut_t_adder_in : STD_LOGIC_VECTOR (DUT_N_BITS_PER_WORD - 1 DOWNTO 0) := (OTHERS => '0');
    SIGNAL dut_t_mac_out  : STD_LOGIC_VECTOR (DUT_N_BITS_PER_WORD - 1 DOWNTO 0) := (OTHERS => '0');
    SIGNAL dut_c_mac_out  : STD_LOGIC_VECTOR (DUT_N_BITS_PER_WORD - 1 DOWNTO 0) := (OTHERS => '0');
    --------------------------------------------------------------------------------------
    ----------------------------
    ----- Last DUT Signals -----
    SIGNAL counter     : INTEGER RANGE 0 TO DUT_N_WORDS * DUT_N_WORDS - 1  := 0;
    SIGNAL int_value   : INTEGER RANGE 0 TO 2 ** (DUT_N_BITS_PER_WORD) - 1 := 15;
    SIGNAL counter_mac : INTEGER                                           := 0;
    SIGNAL counter_add : INTEGER                                           := 0;
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
    mac_ab_dut : FSM_mac_ab
    GENERIC MAP(
        N_WORDS         => DUT_N_WORDS,
        N_BITS_PER_WORD => DUT_N_BITS_PER_WORD
    )
    PORT MAP(
        clk        => clk,
        reset      => reset,
        start      => dut_start,
        a          => dut_a,
        b          => dut_b,
        t_mac_in   => dut_t_mac_in,
        t_adder_in => dut_t_adder_in,
        t_mac_out  => dut_t_mac_out,
        c_mac_out  => dut_c_mac_out

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
    generate_4 : IF DUT_N_WORDS = 4 GENERATE
        stim_proc : PROCESS
        BEGIN
            -- waiting the reset wave
            WAIT FOR RESET_WND;
            -- Start
            WAIT UNTIL rising_edge(clk);
            dut_start <= '1';
            FOR i IN 0 TO DUT_N_WORDS - 1 LOOP
                FOR j IN 0 TO DUT_N_WORDS - 1 LOOP
                    counter <= counter + 1;
                    IF counter = DUT_N_WORDS * DUT_N_WORDS - 1 THEN
                        counter <= 0;
                    END IF;
                    dut_a <= STD_LOGIC_VECTOR(to_unsigned(counter, dut_a'length));
                    IF j = 0 THEN
                        dut_b <= STD_LOGIC_VECTOR(to_unsigned(counter, dut_a'length));
                    END IF;
                    IF i /= 0 THEN
                    ELSIF j /= DUT_N_WORDS - 1 THEN
                        dut_t_mac_in <= STD_LOGIC_VECTOR(to_unsigned(counter, dut_a'length));
                    ELSIF j = DUT_N_WORDS - 1 THEN
                        dut_t_adder_in <= STD_LOGIC_VECTOR(to_unsigned(ADDER_VALUE, dut_a'length));
                    END IF;
                    int_value <= int_value + 1;
                    WAIT UNTIL rising_edge(clk);

                END LOOP;
            END LOOP;
            -- Stop
            WAIT;
        END PROCESS;
    END GENERATE;

    ----------------------------
    ------ Stimulus process -------
    generate_bigger : IF DUT_N_WORDS > 4 GENERATE
        stim_proc : PROCESS
        BEGIN
            -- waiting the reset wave
            WAIT FOR RESET_WND;
            -- Start
            WAIT UNTIL rising_edge(clk);
            dut_start <= '1';
            FOR i IN 0 TO DUT_N_WORDS - 1 LOOP
                FOR j IN 0 TO DUT_N_WORDS - 1 LOOP
                    counter <= counter + 1;
                    IF counter = DUT_N_WORDS * DUT_N_WORDS - 1 THEN
                        counter <= 0;

                        --	din_dut<=	(others=>'0') when counter <4 else
                        --						t_mac_in when counter < N_WORDS*N_WORDS-1 else
                        --						t_adder_in when counter = N_WORDS*N_WORDS-1;
                    END IF;
                    dut_a <= STD_LOGIC_VECTOR(to_unsigned(counter, dut_a'length));
                    IF j = 0 THEN
                        dut_b <= STD_LOGIC_VECTOR(to_unsigned(counter, dut_a'length));
                    END IF;
                    dut_t_mac_in   <= STD_LOGIC_VECTOR(to_unsigned(counter, dut_a'length));
                    dut_t_adder_in <= STD_LOGIC_VECTOR(to_unsigned(ADDER_VALUE, dut_a'length));
                    WAIT UNTIL rising_edge(clk);

                END LOOP;
            END LOOP;
            -- Stop
            WAIT;
        END PROCESS;
    END GENERATE;
END;