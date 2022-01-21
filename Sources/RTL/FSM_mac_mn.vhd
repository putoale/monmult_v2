

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

use IEEE.NUMERIC_STD.ALL;

--!this FSM uses two counters i and j both going from 0 to N_WORDS-1 and are used to control what to expose at the output at every cycle
--!this FSM:
--!starts at cycle 0
--!reads n every cycle  (n is equivalent to a in mac_ab)
--!reads m every cycle with j=0	(m is equivalent to b in mac_ab)
--!reads t from multiplier. the multiplier has registered  the t value of mac_ab, to give a 1 cycle delay

--!cout is brought to the output everytime, adder has to sample it at the correct clock cycle

--------------------------------------------------------------------------------
entity FSM_mac_mn is
	generic(
		N_WORDS				: integer	:=4;
		N_BITS_PER_WORD		: integer	:=8

	);
    Port (
			clk : in STD_LOGIC;
           	reset : in STD_LOGIC;
		   	start : in std_logic;  --! indicates that memories are full and computation is going to start, can be one or more cycles long
			
		   	n : in std_logic_vector (N_BITS_PER_WORD-1  downto 0);
           	m : in std_logic_vector (N_BITS_PER_WORD-1  downto 0);
		   	t_in : in std_logic_vector (N_BITS_PER_WORD-1  downto 0);

           	t_mac_out : out std_logic_vector (N_BITS_PER_WORD-1  downto 0):=(others=>'0');
           	c_mac_out : out std_logic_vector (N_BITS_PER_WORD-1  downto 0):=(others=>'0')

		   );


end FSM_mac_mn;

architecture Behavioral of FSM_mac_mn is

	component simple_1w_mac is
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
	end component;

	---------------------------signals------------------------------------------
	constant LATENCY: integer:=1;  --!clock cycles to wait after having received start
	signal i: integer:=0;			--!counter, cfr mac_ab
	signal j: integer:=0;			--!counter, cfr mac_ab

	signal n_dut : std_logic_vector(n'range):= (Others =>'0');--! wrapper signal for the combinatorial mac module
	signal m_dut : std_logic_vector(n'range):= (Others =>'0');--! wrapper signal for the combinatorial mac module
	signal t_in_dut : std_logic_vector(n'range):= (Others =>'0');--! wrapper signal for the combinatorial mac module
	signal c_in_dut : std_logic_vector(n'range):= (Others =>'0');--! wrapper signal for the combinatorial mac module
	signal s_out_dut : std_logic_vector(n'range):= (Others =>'0');--! wrapper signal for the combinatorial mac module
	signal c_out_dut : std_logic_vector(n'range):= (Others =>'0');--! wrapper signal for the combinatorial mac module

	signal start_reg: std_logic:='0';		--is kept high from when start arrives to when reset arrives
	signal finished: std_logic:='0';	--!unused in this implementation
	signal start_counter : integer:=0; --!counts up to LATENCY, and measures time before computation begins
	signal start_comp: std_logic:='0'; --! start computation, goes to one after LATENCY cycles have passed
	------------------------end signals-----------------------------------------
begin
	mac_inst: simple_1w_mac
	generic map(
		N_BITS=>N_BITS_PER_WORD
	)
	port map(
	a_j		=>	n_dut,
	b_i		=>	m_dut,
	t_in	=>	t_in_dut,
	c_in	=>	c_in_dut,
	s_out	=>	s_out_dut,
	c_out	=>	c_out_dut

	);


	c_mac_out<=c_out_dut;
	t_mac_out<=s_out_dut;

	FSM_process: process(clk,reset)
	begin

		if rising_edge(clk) then
			if reset='1'   then
				start_reg<='0';
				start_comp<='0';

			end if;
			if start = '1' then
				start_reg <= '1';
			end if;
			if start_reg= '1' then
				start_counter<=start_counter+1;
				if start_counter = LATENCY -1 then
					start_counter<=0;
					start_comp<='1';
				end if;
			end if;
			if start_comp ='1' then
				j<=j+1;
				if j=N_WORDS-1 then
					j<=0;
					i<=i+1;
					if i= N_WORDS-1 then
						i<=0;
					end if;
					if i=N_WORDS-1 and j=N_WORDS-1 then
						start_reg<='0';
						start_comp <='0';
					end if;
				end if;
				n_dut<=n;
				t_in_dut<=t_in;
				if j=0 then
					m_dut<=m;
					c_in_dut<=(others=>'0');
				else
					c_in_dut<=c_out_dut;
				end if;
			end if;
		end if;
	end process;

end Behavioral;
