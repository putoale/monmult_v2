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

entity monmult_module_v2 is
	generic (
		--WRITE_WIDTH			: integer :=8;
		--READ_WIDTH			: integer :=8;
		EXTERNAL_WIDTH		: integer := 16;
		INTERNAL_WIDTH		: integer :=32;
		N_BITS_PER_WORD		: integer :=32;  --must be equal to INTERNAL_WIDTH
		N_WORDS				: integer :=8;
		MEMORY_DEPTH		: integer:=8;
		N_BITS_TOTAL		: integer :=256

	);
	Port (
		clk				: in std_logic;
		reset			: in std_logic;
		wr_en_a			: in std_logic;
		wr_en_b			: in std_logic;
		wr_en_n_mac		: in std_logic;
		wr_en_n_sub		: in std_logic;
		wr_en_nn0		: in std_logic;
		a				: in std_logic_vector(EXTERNAL_WIDTH-1 downto 0);
		b				: in std_logic_vector(EXTERNAL_WIDTH-1 downto 0);
		n				: in std_logic_vector(EXTERNAL_WIDTH-1 downto 0);
		nn0				: in std_logic_vector(EXTERNAL_WIDTH-1 downto 0);
		EoC 			: out std_logic := '0';
		valid_out		: out std_logic := '0';
		result			: out std_logic_vector(EXTERNAL_WIDTH-1 downto 0):=(others=>'0')
	);
end monmult_module_v2;

architecture Behavioral of monmult_module_v2 is


	------------------------SIGNALS---------------------------------------------N_WORDS

	constant LATENCY_AB:integer:=1;
	constant LATENCY_N_SUB:integer:=LATENCY_AB +N_WORDS*(N_WORDS-1)+4;
	constant LATENCY_N_MAC:integer:=LATENCY_AB+2 ;
	signal a_mem:std_logic_vector(INTERNAL_WIDTH-1 downto 0);
	signal b_mem:std_logic_vector(INTERNAL_WIDTH-1 downto 0);
	signal n_mac_mem:std_logic_vector(INTERNAL_WIDTH-1 downto 0);
	signal n_sub_mem:std_logic_vector(INTERNAL_WIDTH-1 downto 0);
	signal nn0_mem: std_logic_vector(INTERNAL_WIDTH-1 downto 0);
	signal start_a: std_logic;
	signal start_b: std_logic;
	signal start_n_mac: std_logic;
	signal start_n_sub: std_logic;
	signal start_nn0: std_logic;

	--signal start: std_logic;
	signal EoC_sig: std_logic;
	signal EoC_reg: std_logic := '0';
	signal memory_full: std_logic;

	signal start_mem: std_logic;
	signal start_modules: std_logic;

	signal result_sub: std_logic_vector(INTERNAL_WIDTH-1 downto 0);
	signal valid_out_sub: std_logic;
	----------------------------------------------------------------------------
	component cios_top_1w is
		generic (
			N_BITS_PER_WORD		:integer :=8;
			N_WORDS				:integer :=4
		);
		Port (
			clk: in std_logic;
			reset: in std_logic;
			a			:in std_logic_vector(N_BITS_PER_WORD-1 downto 0);
			b			:in std_logic_vector(N_BITS_PER_WORD-1 downto 0);
			n_mac		:in std_logic_vector(N_BITS_PER_WORD-1 downto 0);
			n_sub		:in std_logic_vector(N_BITS_PER_WORD-1 downto 0);
			start: in std_logic;
			nn0			:in std_logic_vector(N_BITS_PER_WORD-1 downto 0);
			result		:out std_logic_vector(N_BITS_PER_WORD-1 downto 0);
			EoC: out std_logic:= '0';
			valid_out : out std_logic := '0'

		);
	end component;


	component start_regulator is

		port(
				clk	 :	in std_logic;
				reset :	in std_logic;
				in_1: in std_logic;
				in_2: in std_logic;
				in_3: in std_logic;
				in_4: in std_logic;
				EoC: in std_logic;
				output_start	 :		out std_logic:='0';
				output_start_reg :	out std_logic:='0'
		);
	end component;

	component input_mem_v2 is
		generic(
			WRITE_WIDTH: integer:=8;
			READ_WIDTH: integer :=8;   --assuming READ_WIDTH=WRITE_WIDT, for now
			CYLCES_TO_WAIT: integer:=4;   --goes from 1 for a to and entire N_WORDS for b
			LATENCY			: integer :=4;		--goes from 1 to what needed
			N_BITS_TOTAL	: integer :=64
		);
		Port (

			clk : in std_logic;
			reset: in std_logic;
			memory_full: out std_logic;

			wr_en: in std_logic;
			wr_port:in  std_logic_vector(WRITE_WIDTH-1 downto 0);
			rd_en:in  std_logic;
			rd_port: out std_logic_vector(READ_WIDTH-1 downto 0);
			start: out std_logic;
			start_in: in std_logic:='0';

			EoC_in: in std_logic

	  );
	end component;


	component out_mem_controller is
	  generic (
	    write_width : integer := 64;
	    read_width  : integer := 16;  --write_width must be a multiple of read_width. since this is an output controller

	    N_BITS_TOTAL : integer := 256
	  );
	  port (
	    clk       : in    std_logic;
	    reset     : in    std_logic;
	    out_valid : out   std_logic; -- stays at 1 as long as there are valid data on rd_port (connects to the valid of monmult_module)
	    wr_en     : in    std_logic; -- this is the valid of the sub
	    wr_port   : in    std_logic_vector(write_width - 1 downto 0);
	    rd_port   : out   std_logic_vector(read_width - 1 downto 0);
	    EoC_out   : out std_logic;  --rises with the last word on the rd_port
	    eoc_in    : in    std_logic
	  );
	end component out_mem_controller;
begin
    EoC<=EoC_reg;
	-------instantiations-------------------------------------------------------
	inst_cios_1w: cios_top_1w
	generic map(
		N_BITS_PER_WORD		=>INTERNAL_WIDTH,
		N_WORDS				=>N_WORDS

	)
	port map(
		clk=> clk,
		reset=>reset,
		a=> a_mem,
		b=> b_mem,
		n_mac=> n_mac_mem,
		n_sub=> n_sub_mem,
		start=> start_modules,
		nn0=> nn0_mem,
		result=> result_sub,
		valid_out => valid_out_sub,
		EoC=>EoC_sig
	);

	mem_a_inst: input_mem_v2
	generic map(
		WRITE_WIDTH	=> EXTERNAL_WIDTH,
		READ_WIDTH	=> INTERNAL_WIDTH,
		CYLCES_TO_WAIT	=> 1,
		LATENCY	=> LATENCY_AB,
		N_BITS_TOTAL=>N_BITS_TOTAL
		--MEMORY_DEPTH	=> N_WORDS
	)
	port map(
		clk=> clk,
		reset=> reset,
		memory_full=> memory_full,
		wr_en=> wr_en_a,
		wr_port=> a,
		rd_en=> '1',
		rd_port=> a_mem,
		start=> start_a,
		start_in=> start_mem,
		EoC_in=>EoC_sig

	);

	mem_b_inst: input_mem_v2
	generic map(
		WRITE_WIDTH	=> EXTERNAL_WIDTH,
		READ_WIDTH	=> INTERNAL_WIDTH,
		CYLCES_TO_WAIT	=> N_WORDS,
		LATENCY	=> LATENCY_AB,
		N_BITS_TOTAL=>N_BITS_TOTAL

		--MEMORY_DEPTH	=> N_WORDS
	)
	port map(
		clk=> clk,
		reset=> reset,
		memory_full=> memory_full,
		wr_en=> wr_en_b,
		wr_port=> b,
		rd_en=> '1',
		EoC_in=>EoC_sig,
		start=> start_b,
		start_in=> start_mem,

		rd_port=> b_mem
	);

	mem_n_mac_inst: input_mem_v2
	generic map(
		WRITE_WIDTH	=> EXTERNAL_WIDTH,
		READ_WIDTH	=> INTERNAL_WIDTH,
		CYLCES_TO_WAIT	=> 1,
		LATENCY	=> LATENCY_N_MAC,
		N_BITS_TOTAL=>N_BITS_TOTAL

		--MEMORY_DEPTH	=> N_WORDS
	)
	port map(
		clk=> clk,
		reset=> reset,
		memory_full=> memory_full,
		wr_en=> wr_en_n_mac,
		wr_port=> n,
		rd_en=> '1',
		EoC_in=>EoC_sig,
		start=> start_n_mac,
		start_in=> start_mem,

		rd_port=> n_mac_mem
	);

	mem_n_sub_inst: input_mem_v2
	generic map(
		WRITE_WIDTH	=> EXTERNAL_WIDTH,
		READ_WIDTH	=> INTERNAL_WIDTH,
		CYLCES_TO_WAIT	=> 1,
		LATENCY	=> LATENCY_N_SUB,
		N_BITS_TOTAL=>N_BITS_TOTAL

		--MEMORY_DEPTH	=> MEMORY_DEPTH
	)
	port map(
		clk=> clk,
		reset=> reset,
		memory_full=> memory_full,
		wr_en=> wr_en_n_sub,
		wr_port=> n,
		rd_en=> '1',
		EoC_in=>EoC_sig,
		start=> start_n_sub,
		start_in=> start_mem,

		rd_port=> n_sub_mem
	);
	mem_nn0_inst: input_mem_v2
	generic map(
		WRITE_WIDTH	=> EXTERNAL_WIDTH,
		READ_WIDTH	=> INTERNAL_WIDTH,
		CYLCES_TO_WAIT	=> 1,
		LATENCY	=> 1,
		N_BITS_TOTAL=>INTERNAL_WIDTH

		--MEMORY_DEPTH	=> MEMORY_DEPTH
	)
	port map(
		clk=> clk,
		reset=> reset,
		memory_full=> memory_full,
		wr_en=> wr_en_nn0,
		wr_port=> nn0,
		rd_en=> '1',
		EoC_in=>EoC_sig,
		start=> start_n_sub,
		start_in=> start_mem,

		rd_port=> nn0_mem
	);
	output_controller_inst: out_mem_controller

	generic map (
	  write_width=>INTERNAL_WIDTH,
	  read_width=>EXTERNAL_WIDTH,
	  N_BITS_TOTAL=>N_BITS_TOTAL
	)
	port map(
	  clk			=> clk,
	  reset			=> reset,
	  out_valid		=> valid_out,
	  wr_en			=> valid_out_sub,
	  wr_port		=> result_sub,
	  rd_port		=> result,
	  EoC_out 		=> EoC,
	  eoc_in		=> EoC_sig
	  );



	regulator_inst: start_regulator
		port map(

		clk		=> clk,
		reset		=> reset,
		in_1		=> start_a,
		in_2		=> start_b,
		in_3		=> start_n_mac,
		in_4		=> start_n_sub,
		EoC		=> EoC_sig,
		output_start		=> start_mem,
		output_start_reg		=> start_modules
		);

		process(clk)
		begin
			if rising_edge(clk) then
				EoC_reg <= EoC_sig;
			end if;
		end process;
	----------------------------------------------------------------------------
end Behavioral;
