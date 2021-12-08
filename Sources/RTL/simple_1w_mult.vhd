library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity simple_1w_mult is
  Generic(
          N_BITS_PER_WORD : POSITIVE range 2 to 512 := 32
  );
  Port (
        a     : in std_logic_vector (N_BITS_PER_WORD-1 downto 0);
        b     : in std_logic_vector (N_BITS_PER_WORD-1 downto 0);

        p_out : out std_logic_vector (N_BITS_PER_WORD-1 downto 0):=(others=>'0')

   );
end simple_1w_mult;

architecture Behavioral of simple_1w_mult is

signal product : std_logic_vector ( (2*N_BITS_PER_WORD-1) downto 0) := (Others =>'0');

begin

product <= std_logic_vector( unsigned(a) * unsigned(b) );
p_out   <= product(N_BITS_PER_WORD-1 downto 0);

end Behavioral;
