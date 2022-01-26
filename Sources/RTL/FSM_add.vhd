
--! This FSM module controls the inputs of the 1W_ADDER combinatorial block. The adder should start s clock cycles after the "start" signal arrives.
--! After starting, it has to compute 3 sums:
--! * Sum1: 'Carry from fsm_mac_ab' + 'Previous computation of the adder'
--! * Sum2: 'Result of sum1 ' + 'Carry from fsm_mac_mn'
--! * Sum3: 'Carry of sum1' + 'Carry of sum2'
--!
--! After finishing it has to wait for (s-4) clocks (SUM_3_1) before accepting a new value from mac_ab.
--! When all the computations for the current multiplication are done, it returns in the IDLE state, waiting
--! for a new 'start' signal.
--! 

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY FSM_add IS
    GENERIC (
        N_WORDS         : POSITIVE RANGE 4 TO 8192 := 4; --! Number of words per each operand
        N_BITS_PER_WORD : POSITIVE RANGE 8 TO 512  := 32 --! Number of bits per each word
    );
    PORT (
        -------------------------- Clk/Reset --------------------
        clk   : IN STD_LOGIC; --! clock signal
        reset : IN STD_LOGIC; --! asyncronous reset signal
        ---------------------------------------------------------

        --------------------- Ctrl signals ----------------------
        start : IN STD_LOGIC; --! start signal, tells the fsm when a new mult is started
        ---------------------------------------------------------

        ---------------------- Input data ports -----------------
        c_in_ab : IN STD_LOGIC_VECTOR (N_BITS_PER_WORD - 1 DOWNTO 0); --! carry in from mac_ab
        c_in_mn : IN STD_LOGIC_VECTOR (N_BITS_PER_WORD - 1 DOWNTO 0); --! carry in from mac_mn
        ---------------------------------------------------------

        ---------------------- Output data ports -----------------
        c_out : OUT STD_LOGIC_VECTOR (N_BITS_PER_WORD - 1 DOWNTO 0) := (OTHERS => '0'); --! carry out from combinatorial adder
        t_out : OUT STD_LOGIC_VECTOR (N_BITS_PER_WORD - 1 DOWNTO 0) := (OTHERS => '0')  --! result of combinatorial adder
        ---------------------------------------------------------
    );
END FSM_add;

ARCHITECTURE Behavioral OF FSM_add IS
    COMPONENT simple_1w_adder IS
        GENERIC (
            N_BITS_PER_WORD : POSITIVE RANGE 2 TO 512 := 32
        );
        PORT (

            a : IN STD_LOGIC_VECTOR (N_BITS_PER_WORD - 1 DOWNTO 0);
            b : IN STD_LOGIC_VECTOR (N_BITS_PER_WORD - 1 DOWNTO 0);

            s : OUT STD_LOGIC_VECTOR (N_BITS_PER_WORD - 1 DOWNTO 0);
            c : OUT STD_LOGIC_VECTOR (N_BITS_PER_WORD - 1 DOWNTO 0)
        );
    END COMPONENT;
    TYPE state_type IS (IDLE, SUM_1, SUM_1B, SUM_2, SUM_3); --! FSM state type
    SIGNAL state : state_type := IDLE;                      --! FSM state signal

    SIGNAL a_sig : STD_LOGIC_VECTOR (N_BITS_PER_WORD - 1 DOWNTO 0) := (OTHERS => '0'); --! mainly used to load carry from outside
    SIGNAL b_sig : STD_LOGIC_VECTOR (N_BITS_PER_WORD - 1 DOWNTO 0) := (OTHERS => '0'); --! mainly used to load internal values

    SIGNAL start_reg : STD_LOGIC                                      := '0';             --! start signal flipflop '1' -> a conversion is in progress.
    SIGNAL c_out_reg : STD_LOGIC_VECTOR(N_BITS_PER_WORD - 1 DOWNTO 0) := (OTHERS => '0'); --! signal to store c_out for Sum3

    SIGNAL t_out_sig : STD_LOGIC_VECTOR(t_out'RANGE) := (OTHERS => '0'); --! signal linked to combinatorial adder t_out
    SIGNAL c_out_sig : STD_LOGIC_VECTOR(c_out'RANGE) := (OTHERS => '0'); --! signal linked to combinatorial adder c_out

    SIGNAL delay_counter : unsigned (9 DOWNTO 0) := (OTHERS => '0'); --! counter to track cycles to wait before starting a new sum
    SIGNAL i_counter     : unsigned (9 DOWNTO 0) := (OTHERS => '0'); --! counter to keep track of current i_loop cycle (and return to idle when finished)

    CONSTANT DELAY_SUM_3_1 : UNSIGNED (9 DOWNTO 0) := to_unsigned((N_WORDS - 4), 10); --! # cycles to wait after a Sum3 before performing a new Sum1
BEGIN
    add_1w : simple_1w_adder
    GENERIC MAP(
        N_BITS_PER_WORD => N_BITS_PER_WORD
    )
    PORT MAP(
        a => a_sig,
        b => b_sig,

        s => t_out_sig,
        c => c_out_sig
    );
    t_out <= t_out_sig; -- link t_out port to the t_out signal of the combinatorial adder
    c_out <= c_out_sig; -- link c_out port to the c_out signal of the combinatorial adder

    FSM : PROCESS (clk, reset) --! FSM process. This FSM handles the inputs of 1W_adder
    BEGIN

        IF reset = '1' THEN

            state         <= IDLE;            -- return idle
            start_reg     <= '0';             -- reset start_reg flag
            delay_counter <= (OTHERS => '0'); --reset counters
            i_counter     <= (OTHERS => '0');
        ELSIF rising_edge(clk) THEN
            CASE state IS

                WHEN IDLE =>

                    IF start = '1' THEN
                        start_reg <= '1'; --when start received, assert start_reg
                    END IF;

                    IF start_reg = '1' THEN -- if a computation is in progress

                        IF delay_counter < N_WORDS - 1 THEN --wait for N_WORDS-1 cycles
                            delay_counter <= delay_counter + 1;
                        ELSE
                            delay_counter <= (OTHERS => '0'); -- then reset delay_counter

                            a_sig <= c_in_ab;         -- read carry in from MAC_AB
                            b_sig <= (OTHERS => '0'); -- read previous i-cycle result (0 since it's first cycle)

                            state <= SUM_1; -- perform sum1

                        END IF;

                    END IF;
                WHEN SUM_1 =>
                    -- when here you have the result of SUM_1

                    b_sig     <= t_out_sig; --bring result of sum_1 to input b of adder
                    c_out_reg <= c_out_sig; -- save carry of sum 1

                    state <= SUM_1B; -- wait to read c_in_mn

                WHEN SUM_1B =>
                    a_sig <= c_in_mn; -- read c_in_mn and put it into adder's a input

                    state <= SUM_2; -- perform sum2 and go on
                WHEN SUM_2 =>
                    -- here you have the result of SUM_2
                    a_sig <= c_out_reg; -- bring carry of SUM_1 to the input a
                    b_sig <= c_out_sig; -- bring carry of SUM_2 to the input b

                    state <= SUM_3; --perform sum_3 and go on

                WHEN SUM_3 =>
                    -- here you have the result of SUM_3

                    IF delay_counter < DELAY_SUM_3_1 THEN -- wait for DELAY_SUM_1
                        delay_counter <= delay_counter + 1;
                    ELSE
                        delay_counter <= (OTHERS => '0'); -- Then reset counter
                        b_sig         <= t_out_sig;       -- bring result of SUM_3 to input b for next sum1
                        a_sig         <= c_in_ab;         -- bring c_in from mac_ab to input a
                        state         <= SUM_1;           -- perform a new sum1
                    END IF;

                    IF delay_counter = 0 THEN -- every time you perform a new sum_3

                        IF i_counter < N_WORDS - 1 THEN
                            i_counter <= i_counter + 1; --increment i_loop counter
                        ELSE
                            i_counter     <= (OTHERS => '0'); -- if i_loop counter is >= N_WORDS
                            start_reg     <= '0';             --Multiplication done, reset start_reg and counters
                            delay_counter <= (OTHERS => '0');
                            state         <= IDLE; -- return to idle
                        END IF;

                    END IF;

            END CASE;

        END IF;
    END PROCESS;

END Behavioral;