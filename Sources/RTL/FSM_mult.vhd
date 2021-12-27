library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity FSM_mult is
  Generic (
            N_WORDS           : POSITIVE range 4 to 8192 := 4;
            N_BITS_PER_WORD   : POSITIVE range 8 to 64  := 32
  );
  Port (
        ----------------------CLK AND RESET PORTS------------------
        clk     : in std_logic;
        reset   : in std_logic;
        -----------------------------------------------------------

        start  : in std_logic; -- start signal from outside

        ------------------------------Input data ports----------------------------------------
        t_in   : in std_logic_vector (N_BITS_PER_WORD-1 downto 0); -- input word from mac_ab
        nn0    : in std_logic_vector (N_BITS_PER_WORD-1 downto 0); -- input n'(0)
        --------------------------------------------------------------------------------------

        ----------------------------------Output data ports-----------------------------------
        t_out : out std_logic_vector (N_BITS_PER_WORD-1 downto 0) := (Others =>'0');
        m_out : out std_logic_vector (N_BITS_PER_WORD-1 downto 0) := (Others =>'0')
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

  signal i_counter : natural range 0 to N_WORDS := 0; -- signal to count i cycle
  signal j_counter : natural range 0 to N_WORDS := 0; -- signal to count words of an i_cycle

  signal a_sig : std_logic_vector (N_BITS_PER_WORD-1 downto 0) := (Others =>'0'); --signals to sample input data

  signal start_reg : std_logic := '0'; -- signal to count 1 clock cycle delay to start multiplications

  signal t_in_reg  : std_logic_vector (N_BITS_PER_WORD-1 downto 0) := (Others =>'0');



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



  Mult_FSM: process (clk,reset)

  begin

    if reset = '1' then

      i_counter <= 0;
      j_counter <= 0;
      start_reg <= '0';
      t_in_reg  <= (Others =>'0');

    elsif rising_edge(clk) then

      if start = '1' then -- if start = '1' it's clock 0. Mult should sample first input at clk 1
        start_reg <= '1'; -- register to wait until clk 1 and reg to store if multiplication is still in progress
      end if;


      if start_reg = '1' then

        if j_counter = 0 then
          a_sig <= t_in; --load t on multiplier only every s words
        end if;

        t_out <= t_in; -- store value of t. It will be available to be read by mac_mn at the same moment of m_out
        --t_out    <= t_in_reg;

        if j_counter = N_WORDS-1 then
          i_counter <= i_counter + 1;
          j_counter <= 0;

          if i_counter = N_WORDS-1 then
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
