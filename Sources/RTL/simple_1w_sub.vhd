library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity simple_1w_sub is
  Generic(
          N_BITS_PER_WORD : POSITIVE range 2 to 512
  );
  Port (
        d1_in : in std_logic_vector (N_BITS_PER_WORD-1 downto 0);
        d2_in : in std_logic_vector (N_BITS_PER_WORD-1 downto 0);
        b_in : in std_logic_vector(0 downto 0);

        diff_out : out std_logic_vector (N_BITS_PER_WORD-1 downto 0) := (Others =>'0');
        b_out    : out std_logic_vector (0 downto 0):= (Others =>'0')

   );
end simple_1w_sub;

architecture Behavioral of simple_1w_sub is

signal sub_temp : std_logic_vector(N_BITS_PER_WORD downto 0) := (Others =>'0');
signal sub      : std_logic_vector(N_BITS_PER_WORD downto 0) := (Others =>'0');


begin

sub_temp <= std_logic_vector( resize(unsigned (d1_in),sub_temp'length) - resize(unsigned(d2_in),sub_temp'length) );
sub      <= std_logic_vector( unsigned(sub_temp) - resize(unsigned(b_in),sub'length) );
diff_out <= sub(N_BITS_PER_WORD-1 downto 0);
b_out(0)    <= sub(sub'high);

end Behavioral;
