library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;



-- Combinatorial 1-word adder

entity simple_1w_adder is
    Generic (
              N_BITS_PER_WORD : POSITIVE range 2 to 512 := 32
    );
    Port (

          a : in std_logic_vector (N_BITS_PER_WORD-1 downto 0);
          b : in std_logic_vector (N_BITS_PER_WORD-1 downto 0);

          s : out std_logic_vector (N_BITS_PER_WORD -1 downto 0);
          c : out std_logic_vector (N_BITS_PER_WORD -1 downto 0)
     );
end simple_1w_adder;

architecture Behavioral of simple_1w_adder is

signal sum : std_logic_vector ( (2*N_BITS_PER_WORD) - 1 downto 0):=(Others =>'0');

begin

sum <= std_logic_vector (resize(unsigned(a),sum'length) + resize(unsigned(b),sum'length));

c <= sum (sum'high downto N_BITS_PER_WORD);
s <= sum (N_BITS_PER_WORD-1 downto 0);

end Behavioral;
