LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

-- Combinatorial 1-word adder

ENTITY simple_1w_adder IS
    GENERIC (
        N_BITS_PER_WORD : POSITIVE RANGE 2 TO 512 := 32
    );
    PORT (

        a : IN STD_LOGIC_VECTOR (N_BITS_PER_WORD - 1 DOWNTO 0);
        b : IN STD_LOGIC_VECTOR (N_BITS_PER_WORD - 1 DOWNTO 0);

        s : OUT STD_LOGIC_VECTOR (N_BITS_PER_WORD - 1 DOWNTO 0) := (OTHERS => '0');
        c : OUT STD_LOGIC_VECTOR (N_BITS_PER_WORD - 1 DOWNTO 0) := (OTHERS => '0')
    );
END simple_1w_adder;

ARCHITECTURE Behavioral OF simple_1w_adder IS

    SIGNAL sum : STD_LOGIC_VECTOR ((2 * N_BITS_PER_WORD) - 1 DOWNTO 0) := (OTHERS => '0');

BEGIN

    sum <= STD_LOGIC_VECTOR (resize(unsigned(a), sum'length) + resize(unsigned(b), sum'length));

    c <= sum (sum'high DOWNTO N_BITS_PER_WORD);
    s <= sum (N_BITS_PER_WORD - 1 DOWNTO 0);

END Behavioral;