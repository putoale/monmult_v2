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

entity monmult_module is
	generic (
		WRITE_WIDTH: integer :=8;
		READ_WIDTH: integer :=8;
		N_BITS_PER_WORD		:integer :=8;
		N_WORDS				:integer :=4;
		MEMORY_DEPTH: integer:=16

	);
	Port (
		clk				: in std_logic;
		reset			: in std_logic;
		wr_en_a			: in std_logic;
		wr_en_b			: in std_logic;
		wr_en_n_mac		: in std_logic;
		wr_en_n_sub		: in std_logic;
		a				: in std_logic_vector(N_BITS_PER_WORD-1 downto 0);
		b				: in std_logic_vector(N_BITS_PER_WORD-1 downto 0);
		n				: in std_logic_vector(N_BITS_PER_WORD-1 downto 0);
		nn0				: in std_logic_vector(N_BITS_PER_WORD-1 downto 0);
		EoC 			: out std_logic := '0';
		result			: out std_logic_vector(N_BITS_PER_WORD-1 downto 0):=(others=>'0')
	);
end monmult_module;

architecture Behavioral of monmult_module is


	------------------------SIGNALS---------------------------------------------

	signal a_mem:std_logic_vector(N_BITS_PER_WORD-1 downto 0);
	signal b_mem:std_logic_vector(N_BITS_PER_WORD-1 downto 0);
	signal n_mac_mem:std_logic_vector(N_BITS_PER_WORD-1 downto 0);
	signal n_sub_mem:std_logic_vector(N_BITS_PER_WORD-1 downto 0);
	signal start_a: std_logic;
	signal start_b: std_logic;
	signal start_n_mac: std_logic;
	signal start_n_sub: std_logic;
	signal start: std_logic;
	signal EoC_sig: std_logic;
	signal memory_full: std_logic;
	--signal wr_en_a: std_logic;
	--signal wr_en_b: std_logic;
	--signal wr_en_n_mac: std_logic;
	--signal wr_en_n_sub: std_logic;
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
			EoC: out std_logic

		);
	end component;



	component input_mem_abn is
		generic(
			WRITE_WIDTH: integer:=8;
			READ_WIDTH: integer :=8;   --assuming READ_WIDTH=WRITE_WIDT, for now
			CYLCES_TO_WAIT: integer:=4;   --goes from 1 for a to and entire N_WORDS for b
			LATENCY			: integer :=4; 		--goes from 1 to what needed
			MEMORY_DEPTH: integer:=16
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

			EoC_in: in std_logic

	  );
	end component;

begin
    EoC<=EoC_sig;
	-------instantiations-------------------------------------------------------
	inst_cios_1w: cios_top_1w
	generic map(
		N_BITS_PER_WORD		=>N_BITS_PER_WORD,
		N_WORDS				=>N_WORDS

	)
	port map(
		clk=> clk,
		reset=>reset,
		a=> a_mem,
		b=> b_mem,
		n_mac=> n_mac_mem,
		n_sub=> n_sub_mem,
		start=> start,
		nn0=> nn0,
		result=> result,
		EoC=>EoC_sig
	);

	mem_a_inst: input_mem_abn
	generic map(
		WRITE_WIDTH	=> WRITE_WIDTH,
		READ_WIDTH	=> READ_WIDTH,
		CYLCES_TO_WAIT	=> 1,
		LATENCY	=> 1,

		MEMORY_DEPTH	=> MEMORY_DEPTH
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
		EoC_in=>EoC_sig

	);

	mem_b_inst: input_mem_abn
	generic map(
		WRITE_WIDTH	=> WRITE_WIDTH,
		READ_WIDTH	=> READ_WIDTH,
		CYLCES_TO_WAIT	=> N_WORDS,
		LATENCY	=> 1,

		MEMORY_DEPTH	=> MEMORY_DEPTH
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
		rd_port=> b_mem
	);

	mem_n_mac_inst: input_mem_abn
	generic map(
		WRITE_WIDTH	=> WRITE_WIDTH,
		READ_WIDTH	=> READ_WIDTH,
		CYLCES_TO_WAIT	=> 1,
		LATENCY	=> 2,

		MEMORY_DEPTH	=> MEMORY_DEPTH
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
		rd_port=> n_mac_mem
	);

	mem_n_sub_inst: input_mem_abn
	generic map(
		WRITE_WIDTH	=> WRITE_WIDTH,
		READ_WIDTH	=> READ_WIDTH,
		CYLCES_TO_WAIT	=> 1,
		LATENCY	=> N_WORDS*(N_WORDS-1)+3,

		MEMORY_DEPTH	=> MEMORY_DEPTH
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
		rd_port=> n_sub_mem
	);

		start<=start_a and start_b and start_n_mac and start_n_sub;
		EoC <= EoC_sig;
	----------------------------------------------------------------------------
end Behavioral;
