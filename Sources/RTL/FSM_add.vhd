
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


type state_type is (IDLE,SUM_1,SUM_1B,SUM_2,SUM_3);
signal state : state_type := IDLE;

signal a_sig : std_logic_vector (N_BITS_PER_WORD-1 downto 0) := (Others =>'0'); -- used to load carry from outside
signal b_sig : std_logic_vector (N_BITS_PER_WORD-1 downto 0) := (Others =>'0'); -- used to load internal values

signal start_reg : std_logic := '0';
signal c_out_reg : std_logic_vector(N_BITS_PER_WORD-1 downto 0):= (Others =>'0');

signal t_out_sig : std_logic_vector(t_out'range) := (Others =>'0');
signal c_out_sig : std_logic_vector(c_out'range) := (Others =>'0');

signal delay_counter : unsigned (9 downto 0) := (Others =>'0');
signal i_counter : unsigned (9 downto 0) := (Others =>'0');

constant DELAY_SUM_3_1 : UNSIGNED (9 downto 0) := to_unsigned((N_WORDS - 4),10);


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


t_out <= t_out_sig;
c_out <= c_out_sig;

FSM: process(clk,reset)
begin

  if reset = '1' then
    state <= IDLE;
    start_reg <= '0';
    delay_counter <=  (Others =>'0');
    i_counter <=  (Others => '0');


  elsif rising_edge(clk) then


    case state is

      when IDLE  =>

        if start = '1' then
          start_reg <= '1';
        end if;

        if start_reg = '1' then

          if delay_counter < N_WORDS-1 then
            delay_counter <= delay_counter + 1;
          else
            delay_counter <= (Others => '0');

            a_sig <= c_in_ab; --carry in from MAC_AB
            b_sig <= (Others =>'0'); -- Previous i-cycle result (0 since it's first cycle)

            state <= SUM_1;

          end if;

        end if;




      when SUM_1 =>
        -- when here you have the result of SUM_1

        b_sig <= t_out_sig;
        c_out_reg <= c_out_sig;

        state <= SUM_1B;



      when SUM_1B =>
        a_sig <= c_in_mn;

        state <= SUM_2;


      when SUM_2 =>
        -- here you have the result of SUM_2
        a_sig <= c_out_reg;
        b_sig <= c_out_sig;

        state <= SUM_3;

      when SUM_3 =>
        -- here you have the result of SUM_3
        if delay_counter < DELAY_SUM_3_1 then
          delay_counter <= delay_counter + 1;
        else
          delay_counter <= (Others =>'0');
          b_sig <= t_out_sig;
          a_sig <= c_in_ab;
          state <= SUM_1;
        end if;

        if i_counter < N_WORDS-1 then
          i_counter <= i_counter + 1;
        else
          i_counter <= (Others => '0');
          start_reg <= '0';
          state     <= IDLE;
        end if;

    end case;

  end if;


end process;

end Behavioral;
