----------------------------------------------------------------------------------
-- Company:
-- Engineer:
--
-- Create Date: 11/21/2021 07:09:07 PM
-- Design Name:
-- Module Name: cios_top - Behavioral
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
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity cios_top_1w is
	generic (
		N_BITS_PER_WORD		:integer :=8;
		N_WORDS				:integer :=4
	);
	Port (
		clk: in std_logic;
		reset: in std_logic;
		a			:in std_logic_vector(N_BITS_PER_WORD-1 downto 0);
		b			:in std_logic_vector(N_BITS_PER_WORD-1 downto 0);
		n_mac			:in std_logic_vector(N_BITS_PER_WORD-1 downto 0);
		n_sub			:in std_logic_vector(N_BITS_PER_WORD-1 downto 0);
		start: in std_logic;

		nn0			:in std_logic_vector(N_BITS_PER_WORD-1 downto 0);
		EoC: out std_logic;
		result		:out std_logic_vector(N_BITS_PER_WORD-1 downto 0)

	);
end cios_top_1w;

architecture Behavioral of cios_top_1w is
	component FSM_add is
		Generic(
	              N_WORDS         : POSITIVE range 4 to 512 := 4;
	              N_BITS_PER_WORD : POSITIVE range 8 to 64  := 32
	    );
	    Port (
	            -------------------------- Clk/Reset --------------------
	            clk   : in std_logic;
	            reset : in std_logic;
	            ---------------------------------------------------------

	            --------------------- Ctrl signals ----------------------
	            start : in std_logic;
	            ---------------------------------------------------------

	            ---------------------- Input data ports -----------------
	            c_in_ab : in std_logic_vector (N_BITS_PER_WORD-1 downto 0);
	            c_in_mn : in std_logic_vector (N_BITS_PER_WORD-1 downto 0);
	            ---------------------------------------------------------

	            ---------------------- Output data ports -----------------
	            c_out : out std_logic_vector (N_BITS_PER_WORD-1 downto 0):=(Others =>'0');
	            t_out : out std_logic_vector (N_BITS_PER_WORD-1 downto 0):=(Others =>'0')
	            ---------------------------------------------------------


	     );
	end component;

	component FSM_mac_ab is
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


	end component;

	component FSM_mac_mn is
		generic(
			N_WORDS				: integer	:=4;
			N_BITS_PER_WORD		: integer	:=8

		);
	    Port ( clk : in STD_LOGIC;
	           reset : in STD_LOGIC;
			   start : in std_logic;  --receive start, wait 2 cycles

			   n : in std_logic_vector (N_BITS_PER_WORD-1  downto 0);
	           m : in std_logic_vector (N_BITS_PER_WORD-1  downto 0);
			   t_in : in std_logic_vector (N_BITS_PER_WORD-1  downto 0);

	           t_mac_out : out std_logic_vector (N_BITS_PER_WORD-1  downto 0);
	           c_mac_out : out std_logic_vector (N_BITS_PER_WORD-1  downto 0)

			   );

	end component;
	component FSM_mult is
		Generic (
                  N_WORDS           : POSITIVE range 4 to 512 := 4;
                  N_BITS_PER_WORD   : POSITIVE range 8 to 64  := 32
        );
        Port (
              ----------------------CLK AND RESET PORTS------------------
              clk     : in std_logic;
              reset   : in std_logic;
              -----------------------------------------------------------

              start  : in std_logic; -- start signal from outside

              ------------------------------Input data ports----------------------------------------
              t_in   : in std_logic_vector (N_BITS_PER_WORD-1 downto 0); -- input word from mac_ab
              nn0    : in std_logic_vector (N_BITS_PER_WORD-1 downto 0); -- input n'(0)
              --------------------------------------------------------------------------------------

              ----------------------------------Output data ports-----------------------------------
              t_out : out std_logic_vector (N_BITS_PER_WORD-1 downto 0) := (Others =>'0');
              m_out : out std_logic_vector (N_BITS_PER_WORD-1 downto 0) := (Others =>'0')
              --------------------------------------------------------------------------------------

         );
	end component;
	component FSM_sub_v2 is
		Generic(
				  N_BITS_PER_WORD : POSITIVE range 8 to 64 := 32;
				  N_WORDS : POSITIVE range 4 to 512 := 4
		);
		Port (
				--------------------- Clk / Reset------------------
				clk   : in std_logic;
				reset : in std_logic;
				---------------------------------------------------

				----------------- Control signals------------------
				start : in std_logic;
				---------------------------------------------------

				-------------------- Input data -------------------
				t_in_mac : in std_logic_vector (N_BITS_PER_WORD-1 downto 0);
				t_in_add : in std_logic_vector (N_BITS_PER_WORD-1 downto 0);

				n_in : in std_logic_vector (N_BITS_PER_WORD-1 downto 0);
				---------------------------------------------------

				------------------- Output data -------------------
				mult_result : out std_logic_vector(N_BITS_PER_WORD-1 downto 0) := (Others =>'0');
				EoC: out std_logic
				---------------------------------------------------
		 );
	end component;





	------------------------SIGNALS---------------------------------------------


	signal	t_mac_in_ab		: std_logic_vector(N_BITS_PER_WORD-1 downto 0);
	--signal	t_adder_in_ab		: std_logic_vector(N_BITS_PER_WORD-1 downto 0);
	signal	t_mac_out_ab		: std_logic_vector(N_BITS_PER_WORD-1 downto 0);
	--signal	c_mac_out_ab		: std_logic_vector(N_BITS_PER_WORD-1 downto 0);
	signal	c_mac_out_ab		: std_logic_vector(N_BITS_PER_WORD-1 downto 0);

	signal m : std_logic_vector (N_BITS_PER_WORD-1  downto 0);

	signal	t_mac_in_mn		: std_logic_vector(N_BITS_PER_WORD-1 downto 0);
	signal t_mac_out_mn :  std_logic_vector (N_BITS_PER_WORD-1  downto 0);
	--signal c_mac_out_mn :  std_logic_vector (N_BITS_PER_WORD-1  downto 0);
	signal c_out_mn :  std_logic_vector (N_BITS_PER_WORD-1  downto 0);
	signal c_in_ab : std_logic_vector (N_BITS_PER_WORD-1 downto 0);
	signal c_in_mn : std_logic_vector (N_BITS_PER_WORD-1 downto 0);
	---------------------------------------------------------

	signal c_out :  std_logic_vector (N_BITS_PER_WORD-1 downto 0):=(Others =>'0');
	signal t_out :  std_logic_vector (N_BITS_PER_WORD-1 downto 0):=(Others =>'0');

	--signal start : std_logic;


	signal t_in : std_logic_vector (N_BITS_PER_WORD-1 downto 0);
	signal n_in : std_logic_vector (N_BITS_PER_WORD-1 downto 0);
	signal t_adder: std_logic_vector (N_BITS_PER_WORD-1 downto 0);
	signal t_out_mult: std_logic_vector (N_BITS_PER_WORD-1 downto 0);

	----------------------------------------------------------------------------
begin

	-------instantiations-------------------------------------------------------
	mac_ab_inst: FSM_mac_ab
	generic map(
		N_WORDS=>N_WORDS,
		N_BITS_PER_WORD=>N_BITS_PER_WORD
	)
	port map(
		clk=> clk,
		reset=> reset,
		start=> start,
		a=> a,
		b=> b,
		t_mac_in=> t_mac_out_mn,
		t_adder_in=> t_adder,
		t_mac_out=> t_mac_out_ab,
		c_mac_out=> c_mac_out_ab
	);



	mac_mn_inst: FSM_mac_mn
		generic map(
			N_WORDS=>N_WORDS,
			N_BITS_PER_WORD=>N_BITS_PER_WORD
		)
		port map(
		clk	=>clk,
		reset	=>reset,
		start	=>start,
		n	=>n_mac,
		m	=>m,
		t_in	=>t_out_mult,
		t_mac_out	=>t_mac_out_mn,
		c_mac_out	=>c_out_mn
		);

	 mult_inst: FSM_mult
	 generic map(
		N_WORDS=>N_WORDS,
		N_BITS_PER_WORD=>N_BITS_PER_WORD
	 )
	port map(
		clk=>clk,
		reset=>reset,
		start=>start,
		t_in=>t_mac_out_ab,
		nn0=>nn0,
		t_out=>t_out_mult,
		m_out=>m
	);

	add_inst: FSM_add
	generic map(
		N_WORDS=>N_WORDS,
 		N_BITS_PER_WORD=>N_BITS_PER_WORD
	)
	port map(

	clk=>			clk,
	reset=>		reset,
	start=>		start,
	c_in_ab=>	c_mac_out_ab,
	c_in_mn=>	c_out_mn,
	c_out=>		open,
	t_out	=>	t_adder

	);
	sub_inst: FSM_sub_v2
	generic map(
		N_WORDS=>N_WORDS,
	 N_BITS_PER_WORD=>N_BITS_PER_WORD
	 )
	port map(
		clk=>clk,
		reset=>reset,
		start=>start,
		EoC=>EoC,
		t_in_mac=>t_mac_out_mn,
		t_in_add=>t_adder,
		n_in=>n_sub,
		mult_result=>result
	);
	----------------------------------------------------------------------------
end Behavioral;
