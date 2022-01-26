LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
ENTITY simple_1w_mult IS
    GENERIC (
        N_BITS_PER_WORD : POSITIVE RANGE 2 TO 512 := 32
    );
    PORT (
        a : IN STD_LOGIC_VECTOR (N_BITS_PER_WORD - 1 DOWNTO 0);
        b : IN STD_LOGIC_VECTOR (N_BITS_PER_WORD - 1 DOWNTO 0);

        p_out : OUT STD_LOGIC_VECTOR (N_BITS_PER_WORD - 1 DOWNTO 0) := (OTHERS => '0')

    );
END simple_1w_mult;

ARCHITECTURE Behavioral OF simple_1w_mult IS

    SIGNAL product : STD_LOGIC_VECTOR ((2 * N_BITS_PER_WORD - 1) DOWNTO 0) := (OTHERS => '0');

BEGIN

    product <= STD_LOGIC_VECTOR(unsigned(a) * unsigned(b));
    p_out   <= product(N_BITS_PER_WORD - 1 DOWNTO 0);

END Behavioral;