library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
--------------------------------------------------------------------------------
--jloop muliplies two 1-word operands a and b, and then adds them
--to the accumulator j
--------------------------------------------------------------------------------
entity simple_1w_mac is
    generic(
        N_BITS : positive := 8 --number of bits in a word
    );
    port(
        a_j : in std_logic_vector(N_BITS-1 downto 0);
        b_i : in std_logic_vector(N_BITS-1 downto 0);

        t_in : in std_logic_vector(N_BITS-1 downto 0);
        c_in: in std_logic_vector(N_BITS-1 downto 0);

        s_out : out std_logic_vector(N_BITS-1 downto 0) := (others => '0');
        c_out: out std_logic_vector(N_BITS-1 downto 0) := (others=>'0')

    );
end entity;

architecture Behavioral of simple_1w_mac is
	signal big_sum: unsigned(2*N_BITS-1 downto 0);
	signal aj_bi : unsigned(2*N_BITS-1 downto 0):=(OTHERS=>'0');
	signal t_c : unsigned(2*N_BITS-1 downto 0):=(OTHERS=>'0');
begin
			aj_bi <= unsigned(a_j) * unsigned(b_i);
			t_c   <= resize(unsigned(t_in),2*N_BITS) + resize(unsigned(c_in),2*N_BITS);
			big_sum <= aj_bi + t_c;
			c_out<=std_logic_vector(big_sum(2*N_BITS-1 downto N_BITS));
			s_out<=std_logic_vector(big_sum(N_BITS-1 downto 0));
	       --  c_out<=std_logic_vector(unsigned(a_j) * unsigned(b_i) + resize(unsigned(t_in),2*N_BITS) + resize(unsigned(c_in),2*N_BITS)(2*N_BITS-1 downto N_BITS));
	       -- s_out<=std_logic_vector(unsigned(a_j) * unsigned(b_i) + resize(unsigned(t_in),2*N_BITS) + resize(unsigned(c_in),2*N_BITS)(N_BITS-1 downto 0));

end architecture Behavioral;
