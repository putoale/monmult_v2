--! This module describes an FSM controlling the inputs of a combinatorial 1word subtractor. 
--! It takes t and n respectively from the mac_mn/adder and from the n_memory, and it subtract the two word by word.
--! It also stores both t and the result of the difference (t-n). At the end of the difference:
--! * If t > n  (b_out = 0) => mult_result = t-n
--! * If t <= n (b_out = 1) => mult_result = t
--!
--! In total, the block has to perform s+1 subtractions:
--! * First s subtractions: t[i] - n[i] -> out_borrows are brought to input_borrow port again
--! * Last subtraction: adder third sum result (t[s]) - prev_b_out
--! At the end of the conversion an EoC signal is asserted for 1 clock cycle. When the output port is outputting valid data, the valid_out port is '1'
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY FSM_sub_v2 IS
    GENERIC (

        N_BITS_PER_WORD : POSITIVE RANGE 8 TO 512  := 32; --! Number of bits per word
        N_WORDS         : POSITIVE RANGE 4 TO 8192 := 4   --! Number of words per operand
    );
    PORT (
        --------------------- Clk / Reset------------------
        clk   : IN STD_LOGIC; --! clock signal
        reset : IN STD_LOGIC; --! asyncronous reset signal
        ---------------------------------------------------

        ----------------- Control signals------------------
        start     : IN STD_LOGIC;         --! start signal (when '1', a new mult has started)
        EoC       : OUT STD_LOGIC := '0'; --! End of Conversion signal. High for 1 clock when mult finished
        valid_out : OUT STD_LOGIC := '0'; --! high when rersult is being written on output port
        ---------------------------------------------------

        -------------------- Input data -------------------
        t_in_mac : IN STD_LOGIC_VECTOR (N_BITS_PER_WORD - 1 DOWNTO 0); --! t data coming from mac_mn
        t_in_add : IN STD_LOGIC_VECTOR (N_BITS_PER_WORD - 1 DOWNTO 0); --! t data coming from adder
        n_in     : IN STD_LOGIC_VECTOR (N_BITS_PER_WORD - 1 DOWNTO 0); --! n coming from n memory
        ---------------------------------------------------

        ------------------- Output data -------------------
        mult_result : OUT STD_LOGIC_VECTOR(N_BITS_PER_WORD - 1 DOWNTO 0) := (OTHERS => '0') --! final result of monmult
        ---------------------------------------------------
    );
END FSM_sub_v2;

ARCHITECTURE Behavioral OF FSM_sub_v2 IS

    COMPONENT simple_1w_sub IS
        GENERIC (
            N_BITS_PER_WORD : POSITIVE RANGE 8 TO 512 := 8
        );
        PORT (
            d1_in : IN STD_LOGIC_VECTOR (N_BITS_PER_WORD - 1 DOWNTO 0);
            d2_in : IN STD_LOGIC_VECTOR (N_BITS_PER_WORD - 1 DOWNTO 0);
            b_in  : IN STD_LOGIC_VECTOR(0 DOWNTO 0);

            diff_out : OUT STD_LOGIC_VECTOR (N_BITS_PER_WORD - 1 DOWNTO 0) := (OTHERS => '0');
            b_out    : OUT STD_LOGIC_VECTOR (0 DOWNTO 0)                   := (OTHERS => '0')

        );
    END COMPONENT;

    CONSTANT CLK_TO_WAIT : POSITIVE := N_WORDS * (N_WORDS - 1) + 3; --! clock cycles to wait before starting comparison

    TYPE state_type IS (IDLE, SUB_STATE, COMPARE_STATE); --! FSM state type
    SIGNAL state : state_type := IDLE;                   --! FSM state signal

    TYPE out_temp_type IS ARRAY (0 TO N_WORDS - 1) OF STD_LOGIC_VECTOR(N_BITS_PER_WORD - 1 DOWNTO 0); --! memory type to store words before comparison
    SIGNAL diff_out_temp : out_temp_type := (OTHERS => (OTHERS => '0'));                              --! memory to store difference before comparison 
    SIGNAL t_out_temp    : out_temp_type := (OTHERS => (OTHERS => '0'));                              --! memory to store t_in_mac before comparison

    SIGNAL start_reg : STD_LOGIC := '0'; --! flag signal: '1' means a multiplication is in progress

    SIGNAL read_counter  : NATURAL RANGE 0 TO N_WORDS     := 0; --! counter for reads from mac, adder and n memory 
    SIGNAL write_counter : NATURAL RANGE 0 TO N_WORDS - 1 := 0; --! counter for output writes

    SIGNAL wait_counter : NATURAL RANGE 0 TO CLK_TO_WAIT - 1 := 0; --! counter for waiting before starting subtraction

    SIGNAL t_in_sig : STD_LOGIC_VECTOR (N_BITS_PER_WORD - 1 DOWNTO 0) := (OTHERS => '0'); --! signal linked to first input of combinatorial subtractor
    SIGNAL n_in_sig : STD_LOGIC_VECTOR (N_BITS_PER_WORD - 1 DOWNTO 0) := (OTHERS => '0'); --! signal linked to second input of combinatorial subtractor
    SIGNAL b_in_sig : STD_LOGIC_VECTOR (0 DOWNTO 0)                   := (OTHERS => '0'); --! signal linked to input borrow of combinatorial subtractor

    SIGNAL diff_out_sig : STD_LOGIC_VECTOR (N_BITS_PER_WORD - 1 DOWNTO 0) := (OTHERS => '0'); --! signal linked to out result of combinatorial subtractor
    SIGNAL b_out_sig    : STD_LOGIC_VECTOR (0 DOWNTO 0)                   := (OTHERS => '0'); --! signal linked to out borrow of combinatorial subtractor
    SIGNAL b_out_reg    : STD_LOGIC_VECTOR (0 DOWNTO 0)                   := (OTHERS => '0'); --! signal to store last b_out (needed to understand if t>n)

BEGIN
    sub_1w_inst : simple_1w_sub
    GENERIC MAP(
        N_BITS_PER_WORD => N_BITS_PER_WORD
    )
    PORT MAP(
        d1_in => t_in_sig,
        d2_in => n_in_sig,
        b_in  => b_in_sig,

        diff_out => diff_out_sig,
        b_out    => b_out_sig
    );

    --! FSM process
    FSM : PROCESS (clk, reset)

    BEGIN

        IF reset = '1' THEN --! is the reset signal is asserted

            read_counter  <= 0; --! reset the counters
            write_counter <= 0;
            wait_counter  <= 0;
            state         <= IDLE; --! go to IDLE state
            start_reg     <= '0';  --! reset start_reg flag
            EoC           <= '0';  --! reset EoC
        ELSIF (rising_edge(clk)) THEN

            CASE state IS
                WHEN IDLE =>
                    -- wait for CLK_TO_WAIT before moving to next state

                    EoC       <= '0'; -- reset EoC and valid_out from previous multiplications
                    valid_out <= '0';
                    IF start = '1' THEN -- when start = '1', a new multiplication has started
                        start_reg <= '1';   -- assert start_reg flag
                    END IF;

                    IF start_reg = '1' THEN -- if a mult in progress

                        IF wait_counter = CLK_TO_WAIT - 1 THEN -- wait for CLK_TO_WAIT before moving to next state
                            wait_counter <= 0;                     -- then reset counter
                            state        <= SUB_STATE;             -- and go to sub state

                        ELSE
                            wait_counter <= wait_counter + 1;
                        END IF;

                    END IF;
                WHEN SUB_STATE =>

                    ------------------------------------------------------------  Borrow in handler  -------------------------------------------

                    IF read_counter = 0 THEN                          -- if first word has to be read
                        b_in_sig <= (OTHERS => '0');                      -- forst borrow_in is 0
                    ELSIF read_counter < N_WORDS THEN                 -- for intermediate words (2nd to last)
                        b_in_sig                         <= b_out_sig;    -- b_in(i) = b_out(i-1)
                        diff_out_temp (read_counter - 1) <= diff_out_sig; -- save result (now available) of previous subtraction in memory (0 to penultimate)
                    ELSE
                        b_in_sig <= b_out_sig; -- borrow for last subtraction (t from ADDER SUM_3)
                    END IF;

                    ----------------------------------------------------------------------------------------------------------------------------
                    t_in_sig <= t_in_mac;                  -- t_in input of subtractor is default taken from mac_mn
                    IF read_counter < N_WORDS THEN         -- if reading one of the first s words of t
                        t_out_temp (read_counter) <= t_in_mac; --save t (from mac mn) in memory
                        n_in_sig                  <= n_in;     --load n_in
                    END IF;

                    IF read_counter = N_WORDS - 1 THEN             -- if s_th word
                        t_in_sig                  <= t_in_add;         -- next t_in is taken from adder
                        t_out_temp (read_counter) <= t_in_add;         -- and save it in memory
                        read_counter              <= read_counter + 1; -- increment read_counter

                    ELSIF read_counter = N_WORDS THEN -- when first s words computed
                        read_counter <= 0;                -- reset read_counter
                        n_in_sig     <= (OTHERS => '0');  --perform last sub putting n = 0
                        t_in_sig     <= t_in_add;         -- and t_in = t_add (SUM_3 result)

                        diff_out_temp(diff_out_temp'high) <= diff_out_sig; -- save last sub

                        state <= COMPARE_STATE; -- go to compare state
                    ELSE
                        read_counter <= read_counter + 1; -- if intermediate words increment read_counter
                    END IF;
                WHEN COMPARE_STATE =>
                    --last operation completed, you can read result and borrow to understand which result to send

                    b_out_reg <= b_out_sig; -- save b_out of last sub in reg

                    IF (write_counter = 0 AND b_out_sig = "0") OR (write_counter /= 0 AND b_out_reg = "0") THEN -- if last borrow is 0
                        mult_result <= diff_out_temp(write_counter);                                                -- result is diff
                    ELSE
                        mult_result <= t_out_temp(write_counter); -- else result is t
                    END IF;

                    valid_out <= '1'; -- assert valid_out signal

                    IF write_counter = N_WORDS - 1 THEN -- when last word is out
                        write_counter <= 0;                 --reset write counter
                        EoC           <= '1';               -- assert EoC
                        start_reg     <= '0';               -- reset start_reg flag
                        state         <= IDLE;              -- return idle
                    ELSE
                        write_counter <= write_counter + 1; -- else increment counter
                    END IF;
            END CASE;

        END IF;
    END PROCESS;

END Behavioral;