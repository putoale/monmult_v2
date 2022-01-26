

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

USE IEEE.NUMERIC_STD.ALL;

--!This FSM uses two counters i and j both going from 0 to N_WORDS-1 and are used to control what to expose at the output at every cycle.N_BITS_PER_WORD
--!
--!this FSM:
--!
--!* starts at cycle 0
--!* reads n every cycle  (n is equivalent to a in mac_ab)
--!* reads m every cycle with j=0	(m is equivalent to b in mac_ab)
--!* reads t from multiplier. the multiplier has registered  the t value of mac_ab, to give a 1 cycle delay

--!* Cout is brought to the output everytime, adder has to sample it at the correct clock cycle

--------------------------------------------------------------------------------
ENTITY FSM_mac_mn IS
    GENERIC (
        N_WORDS         : INTEGER := 4;
        N_BITS_PER_WORD : INTEGER := 8

    );
    PORT (
        clk   : IN STD_LOGIC;
        reset : IN STD_LOGIC;
        start : IN STD_LOGIC; --! indicates that memories are full and computation is going to start, can be one or more cycles long

        n    : IN STD_LOGIC_VECTOR (N_BITS_PER_WORD - 1 DOWNTO 0);
        m    : IN STD_LOGIC_VECTOR (N_BITS_PER_WORD - 1 DOWNTO 0);
        t_in : IN STD_LOGIC_VECTOR (N_BITS_PER_WORD - 1 DOWNTO 0);

        t_mac_out : OUT STD_LOGIC_VECTOR (N_BITS_PER_WORD - 1 DOWNTO 0) := (OTHERS => '0');
        c_mac_out : OUT STD_LOGIC_VECTOR (N_BITS_PER_WORD - 1 DOWNTO 0) := (OTHERS => '0')

    );
END FSM_mac_mn;

ARCHITECTURE Behavioral OF FSM_mac_mn IS

    COMPONENT simple_1w_mac IS
        GENERIC (
            N_BITS : POSITIVE := 8 --number of bits in a word
        );
        PORT (
            a_j : IN STD_LOGIC_VECTOR(N_BITS - 1 DOWNTO 0);
            b_i : IN STD_LOGIC_VECTOR(N_BITS - 1 DOWNTO 0);

            t_in : IN STD_LOGIC_VECTOR(N_BITS - 1 DOWNTO 0);
            c_in : IN STD_LOGIC_VECTOR(N_BITS - 1 DOWNTO 0);

            s_out : OUT STD_LOGIC_VECTOR(N_BITS - 1 DOWNTO 0) := (OTHERS => '0');
            c_out : OUT STD_LOGIC_VECTOR(N_BITS - 1 DOWNTO 0) := (OTHERS => '0')

        );
    END COMPONENT;

    ---------------------------signals------------------------------------------
    CONSTANT LATENCY : INTEGER := 1; --!clock cycles to wait after having received start
    SIGNAL i         : INTEGER := 0; --!counter, cfr mac_ab
    SIGNAL j         : INTEGER := 0; --!counter, cfr mac_ab

    SIGNAL n_dut     : STD_LOGIC_VECTOR(n'RANGE) := (OTHERS => '0');--! wrapper signal for the combinatorial mac module
    SIGNAL m_dut     : STD_LOGIC_VECTOR(n'RANGE) := (OTHERS => '0');--! wrapper signal for the combinatorial mac module
    SIGNAL t_in_dut  : STD_LOGIC_VECTOR(n'RANGE) := (OTHERS => '0');--! wrapper signal for the combinatorial mac module
    SIGNAL c_in_dut  : STD_LOGIC_VECTOR(n'RANGE) := (OTHERS => '0');--! wrapper signal for the combinatorial mac module
    SIGNAL s_out_dut : STD_LOGIC_VECTOR(n'RANGE) := (OTHERS => '0');--! wrapper signal for the combinatorial mac module
    SIGNAL c_out_dut : STD_LOGIC_VECTOR(n'RANGE) := (OTHERS => '0');--! wrapper signal for the combinatorial mac module

    SIGNAL start_reg     : STD_LOGIC := '0'; --is kept high from when start arrives to when reset arrives
    SIGNAL finished      : STD_LOGIC := '0'; --!unused in this implementation
    SIGNAL start_counter : INTEGER   := 0; --!counts up to LATENCY, and measures time before computation begins
    SIGNAL start_comp    : STD_LOGIC := '0'; --! start computation, goes to one after LATENCY cycles have passed
    ------------------------end signals-----------------------------------------
BEGIN
    mac_inst : simple_1w_mac
    GENERIC MAP(
        N_BITS => N_BITS_PER_WORD
    )
    PORT MAP(
        a_j   => n_dut,
        b_i   => m_dut,
        t_in  => t_in_dut,
        c_in  => c_in_dut,
        s_out => s_out_dut,
        c_out => c_out_dut

    );
    c_mac_out <= c_out_dut;
    t_mac_out <= s_out_dut;

    FSM_process : PROCESS (clk, reset)
    BEGIN

        IF rising_edge(clk) THEN
            IF reset = '1' THEN
                start_reg  <= '0';
                start_comp <= '0';

            END IF;
            IF start = '1' THEN
                start_reg <= '1';
            END IF;
            IF start_reg = '1' THEN
                start_counter <= start_counter + 1;
                IF start_counter = LATENCY - 1 THEN
                    start_counter <= 0;
                    start_comp    <= '1';
                END IF;
            END IF;
            IF start_comp = '1' THEN
                j <= j + 1;
                IF j = N_WORDS - 1 THEN
                    j <= 0;
                    i <= i + 1;
                    IF i = N_WORDS - 1 THEN
                        i <= 0;
                    END IF;
                    IF i = N_WORDS - 1 AND j = N_WORDS - 1 THEN
                        start_reg  <= '0';
                        start_comp <= '0';
                    END IF;
                END IF;
                n_dut    <= n;
                t_in_dut <= t_in;
                IF j = 0 THEN
                    m_dut    <= m;
                    c_in_dut <= (OTHERS => '0');
                ELSE
                    c_in_dut <= c_out_dut;
                END IF;
            END IF;
        END IF;
    END PROCESS;

END Behavioral;