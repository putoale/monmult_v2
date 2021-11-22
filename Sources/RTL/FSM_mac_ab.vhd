----------------------------------------------------------------------------------
-- Company:
-- Engineer:
--
-- Create Date: 11/21/2021 07:09:07 PM
-- Design Name:
-- Module Name: FSM_mac_ab - Behavioral
-- Project Name:
-- Target Devices:
-- Tool Versions:
-- Description:
--
-- Dependencies:
--
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or std_logic_vector values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;
--------------------------------------------------------------------------------
--this FSM:  (i=N_WORDS, j=N_WORDS)
--starts at cycle 0
--reads a every cycle
--reads b every cycle
--reads t = 0 for i=0
--reads t = t_mac_in for i>=1, j<N_WORDS
--reads t = t_adder_in for i>=1, j=N_WORDS


--cout is brought to the output everytime, adder has to sample the correct one


--------------------------------------------------------------------------------
entity FSM_mac_ab is
	generic(
		N_WORDS				: integer	:=4;
		N_BITS_PER_WORD		: integer	:=8

	);
    Port ( clk : in STD_LOGIC;
           reset : in STD_LOGIC;
		   start : in std_logic;

		   a : in std_logic_vector (N_BITS_PER_WORD-1  downto 0);
           b : in std_logic_vector (N_BITS_PER_WORD-1  downto 0);
           t_mac_in : in std_logic_vector (N_BITS_PER_WORD-1  downto 0);
           t_adder_in : in std_logic_vector (N_BITS_PER_WORD-1  downto 0);
           t_mac_out : out std_logic_vector (N_BITS_PER_WORD-1  downto 0);
           c_mac_out : out std_logic_vector (N_BITS_PER_WORD-1  downto 0)

		   );


end FSM_mac_ab;

architecture Behavioral of FSM_mac_ab is


	component sr is
	    Generic(
	        SR_WIDTH   :   NATURAL   := 8;
	        SR_DEPTH   :   POSITIVE  := 4;
	        SR_INIT    :   INTEGER   := 0
	    );
	    Port (

	        ---------- Reset/Clock ----------
	        reset   :   IN  STD_LOGIC;
	        clk     :   IN  STD_LOGIC;
	        ---------------------------------

	        ------------- Data --------------
	        din   :   IN    std_logic_vector(SR_WIDTH-1 downto 0);
	        dout  :   OUT   std_logic_vector(SR_WIDTH-1 downto 0)
	        ---------------------------------

	    );
	end component;
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

	--signals-------------------------------------------------------------------

	signal i: integer:=0;
	signal j: integer:=0;

	signal sr_in: std_logic_vector(t_adder_in'range);
	signal a_dut : std_logic_vector(a'range);
	signal b_dut : std_logic_vector(a'range);
	signal t_in_dut : std_logic_vector(a'range);
	signal c_in_dut : std_logic_vector(a'range);
	signal s_out_dut : std_logic_vector(a'range);
	signal c_out_dut : std_logic_vector(a'range);
	signal	din_dut		: std_logic_vector(t_mac_in'range);
	signal	dout_dut	: std_logic_vector(t_mac_in'range);

	signal finished : std_logic:='0';
	--end signals---------------------------------------------------------------
begin
	mac_inst: simple_1w_mac
	generic map(
		N_BITS=>N_BITS_PER_WORD
	)
	port map(
	a_j		=>	a_dut,
	b_i		=>	b_dut,
	t_in	=>	t_in_dut,
	c_in	=>	c_in_dut,
	s_out	=>	s_out_dut,
	c_out	=>	c_out_dut

	);


	generate_sr: if N_WORDS > 4 generate
		sr_inst: sr
		generic map(
				SR_WIDTH	=>	N_BITS_PER_WORD,
				SR_DEPTH	=>	N_WORDS-4,
				SR_INIT		=> 0
		)
		port map(
			---------- Reset/Clock ----------
		  reset   => reset,
		  clk     => clk,
		  ---------------------------------


		  ------------- Data --------------
		  din   =>	din_dut,
		  dout  =>	dout_dut
		  ---------------------------------
		);
	end generate;

	generate_wire:if N_WORDS=4 generate
		dout_dut<=	(others=>'0') when i=0 else
					t_mac_in when i/=0 and j/=N_WORDS-1 else
					t_adder_in when i/=0 and j=N_WORDS-1;
	end generate;


	c_mac_out<=c_out_dut;
	t_mac_out<=s_out_dut;
	counters_process:process(clk)
	begin


	end process;

	FSM_process: process(clk)
	begin
		if reset='1' then
			a_dut	<=(others=>'0');
			b_dut	<=(others=>'0');
			t_in_dut	<=(others=>'0');
			c_in_dut	<=(others=>'0');
		elsif rising_edge(clk) then
			if start= '1' and finished='0' then
				j<=j+1;
				if j=N_WORDS-1 then
					j<=0;
					i<=i+1;
					if i= N_WORDS-1 then
						i<=0;
					end if;
					if i=N_WORDS-1 and j=N_WORDS-1 then
						finished<='1';
					end if;
				end if;
				a_dut<=a;
				--c_mac_out<=c_out_dut;
				--t_mac_out<=s_out_dut;
				if j=0 then
					b_dut<=b;
					c_in_dut<=(others=>'0');
				else
					c_in_dut<=c_out_dut;

				end if;
				if i=0 then
					t_in_dut<=(others=>'0');
					c_in_dut<=(others=>'0');
				else
					t_in_dut<=dout_dut;
				end if;
			end if;
		end if;
	end process;

end Behavioral;
