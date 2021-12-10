library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity FSM_sub_v2 is
  Generic(
            --! Number of bits per word
            N_BITS_PER_WORD : POSITIVE range 8 to 64 := 32;
            N_WORDS : POSITIVE range 4 to 512 := 4
  );
  Port (
          --------------------- Clk / Reset------------------
          clk   : in std_logic;
          reset : in std_logic;
          ---------------------------------------------------

          ----------------- Control signals------------------
          start     : in std_logic;
          EoC       : out std_logic:='0';
          valid_out : out std_logic := '0';
          ---------------------------------------------------

          -------------------- Input data -------------------
          t_in_mac : in std_logic_vector (N_BITS_PER_WORD-1 downto 0);
          t_in_add : in std_logic_vector (N_BITS_PER_WORD-1 downto 0);
          n_in     : in std_logic_vector (N_BITS_PER_WORD-1 downto 0);
          ---------------------------------------------------

          ------------------- Output data -------------------
          mult_result : out std_logic_vector(N_BITS_PER_WORD-1 downto 0) := (Others =>'0')
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

  constant CLK_TO_WAIT : positive := N_WORDS * (N_WORDS-1) + 3;

  type state_type is (IDLE, SUB_STATE, COMPARE_STATE);
  signal state: state_type := IDLE;

  type out_temp_type is array (0 to N_WORDS-1) of std_logic_vector(N_BITS_PER_WORD-1 downto 0);
  signal diff_out_temp : out_temp_type := (Others => (Others => '0')); -- memory to store difference before comparing
  signal t_out_temp : out_temp_type := (Others => (Others => '0'));    -- memory to store t_in_mac before comparing

  signal start_reg : std_logic := '0';

  signal read_counter  : natural range 0 to N_WORDS-1 := 0;
  signal write_counter : natural range 0 to N_WORDS-1 := 0;

  signal wait_counter  : natural range 0 to CLK_TO_WAIT-1 := 0;

  signal t_in_sig     : std_logic_vector (N_BITS_PER_WORD-1 downto 0):= (Others =>'0');
  signal n_in_sig     : std_logic_vector (N_BITS_PER_WORD-1 downto 0):= (Others =>'0');
  signal b_in_sig     : std_logic_vector (0 downto 0) := (Others =>'0');

  signal diff_out_sig : std_logic_vector (N_BITS_PER_WORD-1 downto 0):=(Others =>'0');
  signal b_out_sig    : std_logic_vector (0 downto 0) := (Others =>'0');
  signal b_out_reg    : std_logic_vector (0 downto 0) := (Others =>'0');

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


FSM: process(clk,reset)

begin

  if reset = '1' then

    read_counter  <= 0;
    write_counter <= 0;
    wait_counter  <= 0;
    state <= IDLE;
    start_reg <= '0';
    EoC <= '0';


  elsif(rising_edge(clk)) then

    case state is


      when IDLE =>
        --wait for CLK_TO_WAIT before moving to next state
        EoC <= '0';
        valid_out <= '0';


         if start = '1' then
          start_reg <= '1';
         end if;

        if start_reg = '1' then

          if wait_counter = CLK_TO_WAIT - 1 then
            wait_counter <= 0;
            state <= SUB_STATE;

          else
            wait_counter <= wait_counter + 1;
          end if;

        end if;


      when SUB_STATE =>

        if read_counter = 0 then
          b_in_sig <= (Others =>'0');
        else
          b_in_sig <= b_out_sig;
          diff_out_temp (read_counter-1)<= diff_out_sig;
        end if;

          t_in_sig   <= t_in_mac;
          t_out_temp (read_counter) <= t_in_mac;
          n_in_sig <= n_in;

          if read_counter = N_WORDS-1 then
            read_counter <= 0;
            t_in_sig <= t_in_add;
            t_out_temp (read_counter) <= t_in_add;
            state <= COMPARE_STATE;
          else
            read_counter <= read_counter + 1;
          end if;






      when COMPARE_STATE=>
        --last operation completed, you can read result and borrow to understand which result to send
        diff_out_temp(diff_out_temp'high) <= diff_out_sig; -- save last sub
        b_out_reg <= b_out_sig;

        if (write_counter = 0 and b_out_sig = "0") or (write_counter /= 0 and b_out_reg = "0") then
          --state <= WRITE_D_STATE;
          mult_result <= diff_out_temp(write_counter);
        else
          mult_result <= t_out_temp(write_counter);
        end if;

          valid_out <= '1';

        if write_counter = N_WORDS - 1 then
          write_counter <= 0;
          EoC <= '1';
          start_reg <= '0';
          state <= IDLE;
        else
          write_counter <= write_counter + 1;
        end if;


      end case;

  end if;


end process;

end Behavioral;
