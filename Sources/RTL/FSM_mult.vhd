--! This block implements an FSM controlling the inputs of a combinatorial 1w-multiplier. It also functions as a register for t_out_ab. 
--! It starts after 1 clock cycle w.r.t. the start signal, and performs a multiplication every s cycles. The t_out port copies and syncronizes 
--! the t_out data from mac_ab.

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY FSM_mult IS
    GENERIC (
        N_WORDS         : POSITIVE RANGE 4 TO 8192 := 4; --! Number of words per each operand
        N_BITS_PER_WORD : POSITIVE RANGE 8 TO 512  := 32 --! Number of bits per each word
    );
    PORT (
        ----------------------CLK AND RESET PORTS------------------
        clk   : IN STD_LOGIC; --! clock signal
        reset : IN STD_LOGIC; --! asyncronous reset signal
        -----------------------------------------------------------

        start : IN STD_LOGIC; --! start signal from outside

        ------------------------------Input data ports----------------------------------------
        t_in : IN STD_LOGIC_VECTOR (N_BITS_PER_WORD - 1 DOWNTO 0); --! input word from mac_ab
        nn0  : IN STD_LOGIC_VECTOR (N_BITS_PER_WORD - 1 DOWNTO 0); --! input n'(0)
        --------------------------------------------------------------------------------------

        ----------------------------------Output data ports-----------------------------------
        t_out : OUT STD_LOGIC_VECTOR (N_BITS_PER_WORD - 1 DOWNTO 0) := (OTHERS => '0'); --! output t (input t delayed by 1 cycle)
        m_out : OUT STD_LOGIC_VECTOR (N_BITS_PER_WORD - 1 DOWNTO 0) := (OTHERS => '0')  --! output product
        --------------------------------------------------------------------------------------

    );
END FSM_mult;

ARCHITECTURE Behavioral OF FSM_mult IS

    COMPONENT simple_1w_mult IS
        GENERIC (
            N_BITS_PER_WORD : POSITIVE RANGE 2 TO 512 := 32
        );
        PORT (
            a : IN STD_LOGIC_VECTOR (N_BITS_PER_WORD - 1 DOWNTO 0);
            b : IN STD_LOGIC_VECTOR (N_BITS_PER_WORD - 1 DOWNTO 0);

            p_out : OUT STD_LOGIC_VECTOR (N_BITS_PER_WORD - 1 DOWNTO 0)

        );
    END COMPONENT;

    SIGNAL i_counter : NATURAL RANGE 0 TO N_WORDS := 0; --! signal to count i cycle
    SIGNAL j_counter : NATURAL RANGE 0 TO N_WORDS := 0; --! signal to count words of an i_cycle

    SIGNAL a_sig : STD_LOGIC_VECTOR (N_BITS_PER_WORD - 1 DOWNTO 0) := (OTHERS => '0'); --!  signals to sample input data

    SIGNAL start_reg : STD_LOGIC := '0'; --! signal to count 1 clock cycle delay to start multiplications

BEGIN

    mult_1w : simple_1w_mult
    GENERIC MAP(
        N_BITS_PER_WORD => N_BITS_PER_WORD
    )
    PORT MAP(
        a => a_sig,
        b => nn0,

        p_out => m_out
    );
    --! This FSM controls the inputs of the combinatorial multiplier
    Mult_FSM : PROCESS (clk, reset)

    BEGIN

        IF reset = '1' THEN -- if reset

            i_counter <= 0; --restart counters
            j_counter <= 0;
            start_reg <= '0'; --restart start_reg flag

        ELSIF rising_edge(clk) THEN

            IF start = '1' THEN -- if start = '1' it's clock 0. Mult should sample first input at clk 1

                start_reg <= '1'; -- register to wait until clk 1 and flag to track if multiplication is still in progress

            END IF;
            IF start_reg = '1' THEN

                IF j_counter = 0 THEN
                    a_sig <= t_in; --load t on multiplier only every s words
                END IF;

                t_out <= t_in; -- store value of t. It will be available to be read by mac_mn at the same moment of m_out

                IF j_counter = N_WORDS - 1 THEN -- increment i_counter every N_WORDS 
                    i_counter <= i_counter + 1;
                    j_counter <= 0;

                    IF i_counter = N_WORDS - 1 THEN --when i_counter reaches N_WORDS -1, mult is done. Reset the block
                        i_counter <= 0;
                        start_reg <= '0';
                    END IF;

                ELSE
                    j_counter <= j_counter + 1;
                END IF;
            END IF;

        END IF;
    END PROCESS;

END Behavioral;