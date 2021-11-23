
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity FSM_add is
  Generic(
            N_WORDS         : POSITIVE range 4 to 512 := 4;
            N_BITS_PER_WORD : POSITIVE range 8 to 64  := 32
  );
  Port (
          -------------------------- Clk/Reset --------------------
          clk   : in std_logic;
          reset : in std_logic;
          ---------------------------------------------------------

          --------------------- Ctrl signals ----------------------
          start : in std_logic;
          ---------------------------------------------------------

          ---------------------- Input data ports -----------------
          c_in_ab : in std_logic_vector (N_BITS_PER_WORD-1 downto 0);
          c_in_mn : in std_logic_vector (N_BITS_PER_WORD-1 downto 0);
          ---------------------------------------------------------

          ---------------------- Output data ports -----------------
          c_out : out std_logic_vector (N_BITS_PER_WORD-1 downto 0):=(Others =>'0');
          t_out : out std_logic_vector (N_BITS_PER_WORD-1 downto 0):=(Others =>'0')
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


type state_type is (IDLE,SUM_1,SUM_2,SUM_3);
signal state : state_type := IDLE;

signal a_sig : std_logic_vector (N_BITS_PER_WORD-1 downto 0) := (Others =>'0');
signal b_sig : std_logic_vector (N_BITS_PER_WORD-1 downto 0) := (Others =>'0');



begin


add_1w: simple_1w_adder
Generic map(
            N_BITS_PER_WORD => N_BITS_PER_WORD
)
Port map(
          a => a_sig,
          b => b_sig,

          s => t_out,
          c => c_out
);


FSM: process(clk,reset)
begin

  if reset = '1' then
    state <= IDLE;

  elsif rising_edge(clk) then

  end if;


end process;

end Behavioral;
