

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

--------------------------------------------------------------------------------
--!this FSM uses two counters i and j both going from 0 to N_WORDS-1 and are used to control what to expose at the output at every cycle
--!
--!This FSM:
--!
--!starts at cycle 0,
--!* reads a every cycle,
--!* reads b every N_WORDS cycles,
--!* reads t = 0 for i=0,
--!* reads t = t_mac_in for i>=1, j<N_WORDS,
--!* reads t = t_adder_in for i>=1, j=N_WORDS,
--!* if N_WORDS>4, a shift register is added in order to take into account the delay between the clock mac_mn exposes its t output and mac_ab reads it
--!* Cout is brought to the output everytime, adder has to sample the correct one
--------------------------------------------------------------------------------
ENTITY FSM_mac_ab IS
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
        t_mac_out  : OUT STD_LOGIC_VECTOR (N_BITS_PER_WORD - 1 DOWNTO 0) := (OTHERS => '0');
        c_mac_out  : OUT STD_LOGIC_VECTOR (N_BITS_PER_WORD - 1 DOWNTO 0) := (OTHERS => '0')

    );
END FSM_mac_ab;

ARCHITECTURE Behavioral OF FSM_mac_ab IS
    COMPONENT sr IS
        GENERIC (
            SR_WIDTH : NATURAL  := 8; --!width, in bits, of the read port of the sr
            SR_DEPTH : POSITIVE := 4; --! number of words that the sr stores
            SR_INIT  : INTEGER  := 0 --!initialization values of the flip-flops inside the sr
        );
        PORT (

            ---------- Reset/Clock ----------
            reset : IN STD_LOGIC;
            clk   : IN STD_LOGIC;
            ---------------------------------

            ------------- Data --------------
            din  : IN STD_LOGIC_VECTOR(SR_WIDTH - 1 DOWNTO 0);
            dout : OUT STD_LOGIC_VECTOR(SR_WIDTH - 1 DOWNTO 0)
            ---------------------------------

        );
    END COMPONENT;
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

    ----------------------start signals-----------------------------------------

    SIGNAL i : INTEGER := 0;--! coarse counter
    SIGNAL j : INTEGER := 0;--! fine counter

    SIGNAL sr_in : STD_LOGIC_VECTOR(t_adder_in'RANGE);
    ----------------------------------------------------------------------------
    SIGNAL a_dut     : STD_LOGIC_VECTOR(a'RANGE) := (OTHERS => '0');--! wrapper signal for the combinatorial mac module
    SIGNAL b_dut     : STD_LOGIC_VECTOR(a'RANGE) := (OTHERS => '0');--! wrapper signal for the combinatorial mac module
    SIGNAL t_in_dut  : STD_LOGIC_VECTOR(a'RANGE) := (OTHERS => '0');--! wrapper signal for the combinatorial mac module
    SIGNAL c_in_dut  : STD_LOGIC_VECTOR(a'RANGE) := (OTHERS => '0');--! wrapper signal for the combinatorial mac module
    SIGNAL s_out_dut : STD_LOGIC_VECTOR(a'RANGE) := (OTHERS => '0');--! wrapper signal for the combinatorial mac module
    SIGNAL c_out_dut : STD_LOGIC_VECTOR(a'RANGE) := (OTHERS => '0');--! wrapper signal for the combinatorial mac module
    ----------------------------------------------------------------------------
    ----------------------------------------------------------------------------
    SIGNAL din_dut  : STD_LOGIC_VECTOR(t_mac_in'RANGE);--! wrapper signal for the sr
    SIGNAL dout_dut : STD_LOGIC_VECTOR(t_mac_in'RANGE);--! wrapper signal for the sr
    ----------------------------------------------------------------------------
    SIGNAL counter       : INTEGER := 0;
    SIGNAL start_reg     : STD_LOGIC;
    SIGNAL send_t_mac_in : STD_LOGIC := '0'; --! controls when the sr needs to store the mac_mn output
    SIGNAL send_t_adder  : STD_LOGIC := '0'; --! controls when the sr needs to store the adder output
    SIGNAL counter_mac   : INTEGER   := 0;
    ----------------------------end signals-------------------------------------
BEGIN
    mac_inst : simple_1w_mac
    GENERIC MAP(
        N_BITS => N_BITS_PER_WORD
    )
    PORT MAP(
        a_j   => a_dut,
        b_i   => b_dut,
        t_in  => t_in_dut,
        c_in  => c_in_dut,
        s_out => s_out_dut,
        c_out => c_out_dut

    );
    din_dut <= (OTHERS => '0') WHEN send_t_mac_in = '0' AND send_t_adder = '0' ELSE
        t_mac_in WHEN send_t_mac_in = '1' ELSE
        t_adder_in WHEN send_t_adder = '1';
    ----------------------------------------------------------------------------
    --SR generated only if N_WORDS>4
    generate_sr : IF N_WORDS > 4 GENERATE
        sr_inst : sr
        GENERIC MAP(
            SR_WIDTH => N_BITS_PER_WORD,
            SR_DEPTH => N_WORDS - 4,
            SR_INIT  => 0
        )
        PORT MAP(
            ---------- Reset/Clock ----------
            reset => reset,
            clk   => clk,
            ---------------------------------
            ------------- Data --------------
            din  => din_dut,
            dout => dout_dut
            ---------------------------------
        );
        ----------------------------------------------------------------------------

    END GENERATE;
    ------------------------DATAFLOW ASSIGNMENT---------------------------------

    generate_wire : IF N_WORDS = 4 GENERATE -- wire only generated if there is no sr

        dout_dut <= din_dut;
    END GENERATE;

    c_mac_out <= c_out_dut;
    t_mac_out <= s_out_dut;
    --------------------------------------------------------------------------------
    FSM_process : PROCESS (clk, reset)
    BEGIN
        IF rising_edge(clk) THEN
            IF reset = '1' THEN

                start_reg <= '0';

            END IF;

            IF start = '1' THEN
                start_reg <= '1';
            END IF;

            send_t_mac_in <= '0'; --unless overwritten later
            send_t_adder  <= '0';
            IF start_reg = '1' OR start = '1' THEN
                counter <= counter + 1;
                IF counter >= 3 THEN
                    counter_mac   <= counter_mac + 1;
                    send_t_mac_in <= '1';
                    IF counter_mac = N_WORDS - 1 THEN
                        send_t_mac_in <= '0';
                        send_t_adder  <= '1';
                        counter_mac   <= 0;
                    END IF;
                END IF;
                IF counter = N_WORDS * N_WORDS - 1 THEN
                    counter     <= 0;
                    counter_mac <= 0;
                END IF;
                j <= j + 1;
                IF j = N_WORDS - 1 THEN
                    j <= 0;
                    i <= i + 1;
                    IF i = N_WORDS - 1 THEN
                        i <= 0;
                    END IF;

                    IF i = N_WORDS - 1 AND j = N_WORDS - 1 THEN
                        start_reg <= '0';
                    END IF;
                END IF;
                a_dut <= a;
                IF j = 0 THEN
                    b_dut <= b;

                    c_in_dut <= (OTHERS => '0');
                ELSE
                    c_in_dut <= c_out_dut;
                END IF;
                IF i = 0 THEN
                    t_in_dut <= (OTHERS => '0');

                ELSE
                    t_in_dut <= dout_dut;

                END IF;
            END IF;
        END IF;
    END PROCESS;

END Behavioral;