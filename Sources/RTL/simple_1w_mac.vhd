LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
--------------------------------------------------------------------------------
--jloop muliplies two 1-word operands a and b, and then adds them
--to the accumulator j
--------------------------------------------------------------------------------
ENTITY simple_1w_mac IS
    GENERIC (
        N_BITS : POSITIVE := 8 --number of bits in a word
    );
    PORT (
        a_j : IN STD_LOGIC_VECTOR(N_BITS - 1 DOWNTO 0);
        b_i : IN STD_LOGIC_VECTOR(N_BITS - 1 DOWNTO 0);

        t_in : IN STD_LOGIC_VECTOR(N_BITS - 1 DOWNTO 0);
        c_in : IN STD_LOGIC_VECTOR(N_BITS - 1 DOWNTO 0);

        s_out : OUT STD_LOGIC_VECTOR(N_BITS - 1 DOWNTO 0) := (OTHERS => '0');
        c_out : OUT STD_LOGIC_VECTOR(N_BITS - 1 DOWNTO 0) := (OTHERS => '0')

    );
END ENTITY;

ARCHITECTURE Behavioral OF simple_1w_mac IS
    SIGNAL big_sum : unsigned(2 * N_BITS - 1 DOWNTO 0);
    SIGNAL aj_bi   : unsigned(2 * N_BITS - 1 DOWNTO 0) := (OTHERS => '0');
    SIGNAL t_c     : unsigned(2 * N_BITS - 1 DOWNTO 0) := (OTHERS => '0');
BEGIN
    aj_bi   <= unsigned(a_j) * unsigned(b_i);
    t_c     <= resize(unsigned(t_in), 2 * N_BITS) + resize(unsigned(c_in), 2 * N_BITS);
    big_sum <= aj_bi + t_c;
    c_out   <= STD_LOGIC_VECTOR(big_sum(2 * N_BITS - 1 DOWNTO N_BITS));
    s_out   <= STD_LOGIC_VECTOR(big_sum(N_BITS - 1 DOWNTO 0));
    --  c_out<=std_logic_vector(unsigned(a_j) * unsigned(b_i) + resize(unsigned(t_in),2*N_BITS) + resize(unsigned(c_in),2*N_BITS)(2*N_BITS-1 downto N_BITS));
    -- s_out<=std_logic_vector(unsigned(a_j) * unsigned(b_i) + resize(unsigned(t_in),2*N_BITS) + resize(unsigned(c_in),2*N_BITS)(N_BITS-1 downto 0));

END ARCHITECTURE Behavioral;