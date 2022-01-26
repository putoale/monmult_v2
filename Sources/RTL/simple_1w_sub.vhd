LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY simple_1w_sub IS
    GENERIC (
        N_BITS_PER_WORD : POSITIVE RANGE 8 TO 512 := 8
    );
    PORT (
        d1_in : IN STD_LOGIC_VECTOR (N_BITS_PER_WORD - 1 DOWNTO 0);
        d2_in : IN STD_LOGIC_VECTOR (N_BITS_PER_WORD - 1 DOWNTO 0);
        b_in  : IN STD_LOGIC_VECTOR(0 DOWNTO 0);

        diff_out : OUT STD_LOGIC_VECTOR (N_BITS_PER_WORD - 1 DOWNTO 0) := (OTHERS => '0');
        b_out    : OUT STD_LOGIC_VECTOR (0 DOWNTO 0)                   := (OTHERS => '0')

    );
END simple_1w_sub;

ARCHITECTURE Behavioral OF simple_1w_sub IS

    SIGNAL sub_temp : STD_LOGIC_VECTOR(N_BITS_PER_WORD DOWNTO 0) := (OTHERS => '0');
    SIGNAL sub      : STD_LOGIC_VECTOR(N_BITS_PER_WORD DOWNTO 0) := (OTHERS => '0');
BEGIN

    sub_temp <= STD_LOGIC_VECTOR(resize(unsigned (d1_in), sub_temp'length) - resize(unsigned(d2_in), sub_temp'length));
    sub      <= STD_LOGIC_VECTOR(unsigned(sub_temp) - resize(unsigned(b_in), sub'length));
    diff_out <= sub(N_BITS_PER_WORD - 1 DOWNTO 0);
    b_out(0) <= sub(sub'high);

END Behavioral;