
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

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity FSM_add is
  Generic(
            N_WORDS         : POSITIVE range 4 to 8192 := 4; --! Number of words per each operand
            N_BITS_PER_WORD : POSITIVE range 8 to 512  := 32 --! Number of bits per each word
  );
  Port (
          -------------------------- Clk/Reset --------------------
          clk   : in std_logic; --! clock signal
          reset : in std_logic; --! asyncronous reset signal
          ---------------------------------------------------------

          --------------------- Ctrl signals ----------------------
          start : in std_logic; --! start signal, tells the fsm when a new mult is started
          ---------------------------------------------------------

          ---------------------- Input data ports -----------------
          c_in_ab : in std_logic_vector (N_BITS_PER_WORD-1 downto 0); --! carry in from mac_ab
          c_in_mn : in std_logic_vector (N_BITS_PER_WORD-1 downto 0); --! carry in from mac_mn
          ---------------------------------------------------------

          ---------------------- Output data ports -----------------
          c_out : out std_logic_vector (N_BITS_PER_WORD-1 downto 0):=(Others =>'0'); --! carry out from combinatorial adder
          t_out : out std_logic_vector (N_BITS_PER_WORD-1 downto 0):=(Others =>'0')  --! result of combinatorial adder
          ---------------------------------------------------------


   );
end FSM_add;

architecture Behavioral of FSM_add is


  component simple_1w_adder is
      Generic (
                N_BITS_PER_WORD : POSITIVE range 2 to 512 := 32
      );
      Port (

            a : in std_logic_vector (N_BITS_PER_WORD-1 downto 0);
            b : in std_logic_vector (N_BITS_PER_WORD-1 downto 0);

            s : out std_logic_vector (N_BITS_PER_WORD -1 downto 0);
            c : out std_logic_vector (N_BITS_PER_WORD -1 downto 0)
       );
  end component;


type state_type is (IDLE,SUM_1,SUM_1B,SUM_2,SUM_3); --! FSM state type
signal state : state_type := IDLE; --! FSM state signal

signal a_sig : std_logic_vector (N_BITS_PER_WORD-1 downto 0) := (Others =>'0'); --! mainly used to load carry from outside
signal b_sig : std_logic_vector (N_BITS_PER_WORD-1 downto 0) := (Others =>'0'); --! mainly used to load internal values

signal start_reg : std_logic := '0'; --! start signal flipflop '1' -> a conversion is in progress.
signal c_out_reg : std_logic_vector(N_BITS_PER_WORD-1 downto 0):= (Others =>'0'); --! signal to store c_out for Sum3

signal t_out_sig : std_logic_vector(t_out'range) := (Others =>'0'); --! signal linked to combinatorial adder t_out
signal c_out_sig : std_logic_vector(c_out'range) := (Others =>'0'); --! signal linked to combinatorial adder c_out

signal delay_counter : unsigned (9 downto 0) := (Others =>'0'); --! counter to track cycles to wait before starting a new sum
signal i_counter : unsigned (9 downto 0) := (Others =>'0'); --! counter to keep track of current i_loop cycle (and return to idle when finished)

constant DELAY_SUM_3_1 : UNSIGNED (9 downto 0) := to_unsigned((N_WORDS - 4),10); --! # cycles to wait after a Sum3 before performing a new Sum1


begin


add_1w: simple_1w_adder
Generic map(
            N_BITS_PER_WORD => N_BITS_PER_WORD
)
Port map(
          a => a_sig,
          b => b_sig,

          s => t_out_sig,
          c => c_out_sig
);


t_out <= t_out_sig; -- link t_out port to the t_out signal of the combinatorial adder
c_out <= c_out_sig; -- link c_out port to the c_out signal of the combinatorial adder

FSM: process(clk,reset) --! FSM process. This FSM handles the inputs of 1W_adder
begin

  if reset = '1' then

    state <= IDLE; -- return idle
    start_reg <= '0'; -- reset start_reg flag
    delay_counter <=  (Others =>'0'); --reset counters
    i_counter <=  (Others => '0');


  elsif rising_edge(clk) then


    case state is

      when IDLE  =>

        if start = '1' then
          start_reg <= '1'; --when start received, assert start_reg
        end if;

        if start_reg = '1' then -- if a computation is in progress

          if delay_counter < N_WORDS-1 then --wait for N_WORDS-1 cycles
            delay_counter <= delay_counter + 1;
          else
            delay_counter <= (Others => '0'); -- then reset delay_counter

            a_sig <= c_in_ab; -- read carry in from MAC_AB
            b_sig <= (Others =>'0'); -- read previous i-cycle result (0 since it's first cycle)

            state <= SUM_1; -- perform sum1

          end if;

        end if;




      when SUM_1 =>
        -- when here you have the result of SUM_1

        b_sig <= t_out_sig; --bring result of sum_1 to input b of adder
        c_out_reg <= c_out_sig; -- save carry of sum 1

        state <= SUM_1B; -- wait to read c_in_mn



      when SUM_1B =>
        a_sig <= c_in_mn; -- read c_in_mn and put it into adder's a input

        state <= SUM_2; -- perform sum2 and go on


      when SUM_2 =>
        -- here you have the result of SUM_2
        a_sig <= c_out_reg; -- bring carry of SUM_1 to the input a
        b_sig <= c_out_sig; -- bring carry of SUM_2 to the input b

        state <= SUM_3; --perform sum_3 and go on

      when SUM_3 =>
        -- here you have the result of SUM_3

        if delay_counter < DELAY_SUM_3_1 then -- wait for DELAY_SUM_1
          delay_counter <= delay_counter + 1;
        else
          delay_counter <= (Others =>'0'); -- Then reset counter
          b_sig <= t_out_sig; -- bring result of SUM_3 to input b for next sum1
          a_sig <= c_in_ab; -- bring c_in from mac_ab to input a
          state <= SUM_1; -- perform a new sum1
        end if;

        if delay_counter = 0 then -- every time you perform a new sum_3

          if i_counter < N_WORDS-1 then
            i_counter <= i_counter + 1; --increment i_loop counter
          else
            i_counter <= (Others => '0'); -- if i_loop counter is >= N_WORDS
            start_reg <= '0'; --Multiplication done, reset start_reg and counters
            delay_counter <= (Others => '0');
            state     <= IDLE; -- return to idle
          end if;

        end if;

    end case;

  end if;


end process;

end Behavioral;
