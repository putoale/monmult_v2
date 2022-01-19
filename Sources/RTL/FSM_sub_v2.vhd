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


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity FSM_sub_v2 is
  Generic(
          
            N_BITS_PER_WORD : POSITIVE range 8 to 512 := 32; --! Number of bits per word
            N_WORDS : POSITIVE range 4 to 8192 := 4 --! Number of words per operand
  );
  Port (
          --------------------- Clk / Reset------------------
          clk   : in std_logic; --! clock signal
          reset : in std_logic; --! asyncronous reset signal
          ---------------------------------------------------

          ----------------- Control signals------------------
          start     : in std_logic; --! start signal (when '1', a new mult has started)
          EoC       : out std_logic:='0'; --! End of Conversion signal. High for 1 clock when mult finished
          valid_out : out std_logic := '0'; --! high when rersult is being written on output port
          ---------------------------------------------------

          -------------------- Input data -------------------
          t_in_mac : in std_logic_vector (N_BITS_PER_WORD-1 downto 0); --! t data coming from mac_mn
          t_in_add : in std_logic_vector (N_BITS_PER_WORD-1 downto 0); --! t data coming from adder
          n_in     : in std_logic_vector (N_BITS_PER_WORD-1 downto 0); --! n coming from n memory
          ---------------------------------------------------

          ------------------- Output data -------------------
          mult_result : out std_logic_vector(N_BITS_PER_WORD-1 downto 0) := (Others =>'0') --! final result of monmult
          ---------------------------------------------------
   );
end FSM_sub_v2;

architecture Behavioral of FSM_sub_v2 is

  component simple_1w_sub is
    Generic(
            N_BITS_PER_WORD : POSITIVE range 8 to 512 := 8
    );
    Port (
          d1_in : in std_logic_vector (N_BITS_PER_WORD-1 downto 0);
          d2_in : in std_logic_vector (N_BITS_PER_WORD-1 downto 0);
          b_in : in std_logic_vector(0 downto 0);

          diff_out : out std_logic_vector (N_BITS_PER_WORD-1 downto 0) := (Others =>'0');
          b_out    : out std_logic_vector (0 downto 0)                 := (Others =>'0')

     );
  end component;

  constant CLK_TO_WAIT : positive := N_WORDS * (N_WORDS-1) + 3; --! clock cycles to wait before starting comparison

  type state_type is (IDLE, SUB_STATE, COMPARE_STATE); --! FSM state type
  signal state: state_type := IDLE; --! FSM state signal

  type out_temp_type is array (0 to N_WORDS-1) of std_logic_vector(N_BITS_PER_WORD-1 downto 0); --! memory type to store words before comparison
  signal diff_out_temp : out_temp_type := (Others => (Others => '0')); --! memory to store difference before comparison 
  signal t_out_temp : out_temp_type := (Others => (Others => '0'));    --! memory to store t_in_mac before comparison

  signal start_reg : std_logic := '0'; --! flag signal: '1' means a multiplication is in progress

  signal read_counter  : natural range 0 to N_WORDS := 0; --! counter for reads from mac, adder and n memory 
  signal write_counter : natural range 0 to N_WORDS-1 := 0; --! counter for output writes

  signal wait_counter  : natural range 0 to CLK_TO_WAIT-1 := 0; --! counter for waiting before starting subtraction

  signal t_in_sig     : std_logic_vector (N_BITS_PER_WORD-1 downto 0):= (Others =>'0'); --! signal linked to first input of combinatorial subtractor
  signal n_in_sig     : std_logic_vector (N_BITS_PER_WORD-1 downto 0):= (Others =>'0'); --! signal linked to second input of combinatorial subtractor
  signal b_in_sig     : std_logic_vector (0 downto 0) := (Others =>'0');  --! signal linked to input borrow of combinatorial subtractor

  signal diff_out_sig : std_logic_vector (N_BITS_PER_WORD-1 downto 0):=(Others =>'0'); --! signal linked to out result of combinatorial subtractor
  signal b_out_sig    : std_logic_vector (0 downto 0) := (Others =>'0'); --! signal linked to out borrow of combinatorial subtractor
  signal b_out_reg    : std_logic_vector (0 downto 0) := (Others =>'0'); --! signal to store last b_out (needed to understand if t>n)

begin


sub_1w_inst: simple_1w_sub
Generic map(
              N_BITS_PER_WORD => N_BITS_PER_WORD
)
Port map(
          d1_in => t_in_sig,
          d2_in => n_in_sig,
          b_in  => b_in_sig,

          diff_out => diff_out_sig,
          b_out => b_out_sig
);

 --! FSM process
FSM: process(clk,reset)

begin

  if reset = '1' then --! is the reset signal is asserted

    read_counter  <= 0; --! reset the counters
    write_counter <= 0;
    wait_counter  <= 0;
    state <= IDLE; --! go to IDLE state
    start_reg <= '0'; --! reset start_reg flag
    EoC <= '0'; --! reset EoC


  elsif(rising_edge(clk)) then

    case state is


      when IDLE =>
        -- wait for CLK_TO_WAIT before moving to next state

        EoC <= '0';  -- reset EoC and valid_out from previous multiplications
        valid_out <= '0';


         if start = '1' then -- when start = '1', a new multiplication has started
          start_reg <= '1'; -- assert start_reg flag
         end if;

        if start_reg = '1' then -- if a mult in progress

          if wait_counter = CLK_TO_WAIT - 1 then -- wait for CLK_TO_WAIT before moving to next state
            wait_counter <= 0;  -- then reset counter
            state <= SUB_STATE; -- and go to sub state

          else
            wait_counter <= wait_counter + 1;
          end if;

        end if;


      when SUB_STATE =>

        ------------------------------------------------------------  Borrow in handler  -------------------------------------------

        if read_counter = 0 then     -- if first word has to be read
          b_in_sig <= (Others =>'0'); -- forst borrow_in is 0
        elsif read_counter < N_WORDS then -- for intermediate words (2nd to last)
          b_in_sig <= b_out_sig; -- b_in(i) = b_out(i-1)
          diff_out_temp (read_counter-1)<= diff_out_sig; -- save result (now available) of previous subtraction in memory (0 to penultimate)
        else
          b_in_sig <= b_out_sig; -- borrow for last subtraction (t from ADDER SUM_3)
        end if;

        ----------------------------------------------------------------------------------------------------------------------------


          t_in_sig   <= t_in_mac; -- t_in input of subtractor is default taken from mac_mn
          if read_counter < N_WORDS then -- if reading one of the first s words of t
            t_out_temp (read_counter) <= t_in_mac; --save t (from mac mn) in memory
            n_in_sig <= n_in; --load n_in
          end if;

          if read_counter = N_WORDS-1 then -- if s_th word
            t_in_sig <= t_in_add; -- next t_in is taken from adder
            t_out_temp (read_counter) <= t_in_add; -- and save it in memory
            read_counter <= read_counter + 1; -- increment read_counter

          elsif read_counter = N_WORDS then -- when first s words computed
            read_counter <= 0; -- reset read_counter
            n_in_sig <= (Others => '0'); --perform last sub putting n = 0
            t_in_sig <= t_in_add; -- and t_in = t_add (SUM_3 result)

            diff_out_temp(diff_out_temp'high) <= diff_out_sig; -- save last sub

            state <= COMPARE_STATE; -- go to compare state
          else
            read_counter <= read_counter + 1; -- if intermediate words increment read_counter
          end if;






      when COMPARE_STATE=>
        --last operation completed, you can read result and borrow to understand which result to send

        b_out_reg <= b_out_sig; -- save b_out of last sub in reg

        if (write_counter = 0 and b_out_sig = "0") or (write_counter /= 0 and b_out_reg = "0") then  -- if last borrow is 0
          mult_result <= diff_out_temp(write_counter); -- result is diff
        else
          mult_result <= t_out_temp(write_counter); -- else result is t
        end if;

          valid_out <= '1'; -- assert valid_out signal

        if write_counter = N_WORDS - 1 then -- when last word is out
          write_counter <= 0; --reset write counter
          EoC <= '1'; -- assert EoC
          start_reg <= '0'; -- reset start_reg flag
          state <= IDLE; -- return idle
        else
          write_counter <= write_counter + 1; -- else increment counter
        end if;


      end case;

  end if;


end process;

end Behavioral;
