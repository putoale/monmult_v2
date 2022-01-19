--! This block implements an FSM controlling the inputs of a combinatorial 1w-multiplier. It also functions as a register for t_out_ab. 
--! It starts after 1 clock cycle w.r.t. the start signal, and performs a multiplication every s cycles. The t_out port copies and syncronizes 
--! the t_out data from mac_ab.

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity FSM_mult is
  Generic (
            N_WORDS           : POSITIVE range 4 to 8192 := 4; --! Number of words per each operand
            N_BITS_PER_WORD   : POSITIVE range 8 to 512  := 32 --! Number of bits per each word
  );
  Port (
        ----------------------CLK AND RESET PORTS------------------
        clk     : in std_logic; --! clock signal
        reset   : in std_logic; --! asyncronous reset signal
        -----------------------------------------------------------

        start  : in std_logic; --! start signal from outside

        ------------------------------Input data ports----------------------------------------
        t_in   : in std_logic_vector (N_BITS_PER_WORD-1 downto 0); --! input word from mac_ab
        nn0    : in std_logic_vector (N_BITS_PER_WORD-1 downto 0); --! input n'(0)
        --------------------------------------------------------------------------------------

        ----------------------------------Output data ports-----------------------------------
        t_out : out std_logic_vector (N_BITS_PER_WORD-1 downto 0) := (Others =>'0'); --! output t (input t delayed by 1 cycle)
        m_out : out std_logic_vector (N_BITS_PER_WORD-1 downto 0) := (Others =>'0')  --! output product
        --------------------------------------------------------------------------------------

   );
end FSM_mult;

architecture Behavioral of FSM_mult is

  component simple_1w_mult is
    Generic(
            N_BITS_PER_WORD : POSITIVE range 2 to 512 := 32
    );
    Port (
          a     : in std_logic_vector (N_BITS_PER_WORD-1 downto 0);
          b     : in std_logic_vector (N_BITS_PER_WORD-1 downto 0);

          p_out : out std_logic_vector (N_BITS_PER_WORD-1 downto 0)

     );
  end component;

  signal i_counter : natural range 0 to N_WORDS := 0; --! signal to count i cycle
  signal j_counter : natural range 0 to N_WORDS := 0; --! signal to count words of an i_cycle

  signal a_sig : std_logic_vector (N_BITS_PER_WORD-1 downto 0) := (Others =>'0'); --!  signals to sample input data

  signal start_reg : std_logic := '0'; --! signal to count 1 clock cycle delay to start multiplications



begin

  mult_1w: simple_1w_mult
  Generic map(
              N_BITS_PER_WORD => N_BITS_PER_WORD
  )
  Port map(
            a => a_sig,
            b => nn0,

            p_out => m_out
  );


--! This FSM controls the inputs of the combinatorial multiplier
  Mult_FSM: process (clk,reset)

  begin

    if reset = '1' then -- if reset

      i_counter <= 0; --restart counters
      j_counter <= 0;
      start_reg <= '0'; --restart start_reg flag

    elsif rising_edge(clk) then

      if start = '1' then -- if start = '1' it's clock 0. Mult should sample first input at clk 1

        start_reg <= '1'; -- register to wait until clk 1 and flag to track if multiplication is still in progress
        
      end if;


      if start_reg = '1' then

        if j_counter = 0 then
          a_sig <= t_in; --load t on multiplier only every s words
        end if;

        t_out <= t_in; -- store value of t. It will be available to be read by mac_mn at the same moment of m_out

        if j_counter = N_WORDS-1 then -- increment i_counter every N_WORDS 
          i_counter <= i_counter + 1;
          j_counter <= 0;

          if i_counter = N_WORDS-1 then --when i_counter reaches N_WORDS -1, mult is done. Reset the block
            i_counter <= 0; 
            start_reg <= '0';
          end if;

        else
          j_counter <= j_counter + 1;
        end if;


      end if;

    end if;


  end process;

end Behavioral;
