

--! this is the module that contains all the others, and wires them together

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity monmult_module is
	generic (
		WRITE_WIDTH			: integer :=256; --!MUST BE SET THE SAME AS NUMBER OF BITS PER WORD
		READ_WIDTH			: integer :=256; --!MUST BE SET THE SAME AS NUMBER OF BITS PER WORD
		N_BITS_PER_WORD		: integer :=256;
		N_WORDS				: integer :=4;	--!IS THE RESULT OF TOTAL_BITS/N_BITS_PER_WORD
		MEMORY_DEPTH		: integer:=4	--!IT IS THE SAME OF N_WORDS

	);
	Port (
		clk				: in std_logic;
		reset			: in std_logic;
		wr_en_a			: in std_logic; --! will be rised by the testbench when the data are ready to be loaded in the input memories
		wr_en_b			: in std_logic; --! will be rised by the testbench when the data are ready to be loaded in the input memories
		wr_en_n_mac		: in std_logic; --! will be rised by the testbench when the data are ready to be loaded in the input memories
		wr_en_n_sub		: in std_logic; --! will be rised by the testbench when the data are ready to be loaded in the input memories
		a				: in std_logic_vector(N_BITS_PER_WORD-1 downto 0); --! data inputs to be loaded to input memories will be fed one word at a time
		b				: in std_logic_vector(N_BITS_PER_WORD-1 downto 0); --! data inputs to be loaded to input memories will be fed one word at a time
		n				: in std_logic_vector(N_BITS_PER_WORD-1 downto 0); --! data inputs to be loaded to input memories will be fed one word at a time
		nn0				: in std_logic_vector(N_BITS_PER_WORD-1 downto 0); --! data inputs to be loaded to input memories will be fed one word at a time
		EoC 			: out std_logic := '0'; --! End Of Conversion, is high on the last word of the valid result
		valid_out		: out std_logic := '0';	--! Is high only when the subtractor is giving out the correct result
		result			: out std_logic_vector(N_BITS_PER_WORD-1 downto 0):=(others=>'0')
	);
end monmult_module;

architecture Behavioral of monmult_module is


	------------------------SIGNALS---------------------------------------------
	----------------------------------------------------------------------------

	constant LATENCY_AB:integer:=1; 									--! this constant controls after how many cycles startig from the start signal is mac_ab going to start reading
	constant LATENCY_N_SUB:integer:=LATENCY_AB +N_WORDS*(N_WORDS-1)+4;	--! this constant controls after how many cycles startig from the start signal is sub going to start reading
	constant LATENCY_N_MAC:integer:=LATENCY_AB+2 ;						--! this constant controls after how many cycles startig from the start signal is mac_mn going to start reading
	----------------------------------------------------------------------------

	----------------------------------------------------------------------------
	-- these signals are used to perform the connections between the internal modules
	signal a_mem:std_logic_vector(N_BITS_PER_WORD-1 downto 0);
	signal b_mem:std_logic_vector(N_BITS_PER_WORD-1 downto 0);
	signal n_mac_mem:std_logic_vector(N_BITS_PER_WORD-1 downto 0);
	signal n_sub_mem:std_logic_vector(N_BITS_PER_WORD-1 downto 0);

	signal start_a: std_logic;
	signal start_b: std_logic;
	signal start_n_mac: std_logic;
	signal start_n_sub: std_logic;
	signal EoC_sig: std_logic;
	signal EoC_reg: std_logic := '0';
	signal memory_full: std_logic;

	signal start_mem: std_logic; --! signals that memories can begin exposing data at their outputs
	signal start_modules: std_logic; --!signal that modules can start to wait for their respective latencies
	----------------------------------------------------------------------------
	-------------------------COMPONENT DECLARATIONS-----------------------------
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

	component input_mem_abn is
		generic(
			WRITE_WIDTH: integer:=8;
			READ_WIDTH: integer :=8;
			CYLCES_TO_WAIT: integer:=4;
			LATENCY			: integer :=4;
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
			start_in: in std_logic:='0';

			EoC_in: in std_logic

	  );
	end component;

begin
    EoC<=EoC_reg;
	---------------------INSTANTIATIONS-----------------------------------------
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
		start=> start_modules,
		nn0=> nn0,
		result=> result,
		valid_out => valid_out,
		EoC=>EoC_sig
	);

	mem_a_inst: input_mem_abn
	generic map(
		WRITE_WIDTH	=> N_BITS_PER_WORD,
		READ_WIDTH	=> N_BITS_PER_WORD,
		CYLCES_TO_WAIT	=> 1,
		LATENCY	=> LATENCY_AB,

		MEMORY_DEPTH	=> N_WORDS
	)
	port map(
		clk=> clk,
		reset=> reset,
		memory_full=> open,
		wr_en=> wr_en_a,
		wr_port=> a,
		rd_en=> '1',
		rd_port=> a_mem,
		start=> start_a,
		start_in=> start_mem,
		EoC_in=>EoC_sig

	);

	mem_b_inst: input_mem_abn
	generic map(
		WRITE_WIDTH	=> N_BITS_PER_WORD,
		READ_WIDTH	=> N_BITS_PER_WORD,
		CYLCES_TO_WAIT	=> N_WORDS,
		LATENCY	=> LATENCY_AB,

		MEMORY_DEPTH	=> N_WORDS
	)
	port map(
		clk=> clk,
		reset=> reset,
		memory_full=> open,
		wr_en=> wr_en_b,
		wr_port=> b,
		rd_en=> '1',
		EoC_in=>EoC_sig,
		start=> start_b,
		start_in=> start_mem,

		rd_port=> b_mem
	);

	mem_n_mac_inst: input_mem_abn
	generic map(
		WRITE_WIDTH	=> N_BITS_PER_WORD,
		READ_WIDTH	=> N_BITS_PER_WORD,
		CYLCES_TO_WAIT	=> 1,
		LATENCY	=> LATENCY_N_MAC,

		MEMORY_DEPTH	=> N_WORDS
	)
	port map(
		clk=> clk,
		reset=> reset,
		memory_full=> open,
		wr_en=> wr_en_n_mac,
		wr_port=> n,
		rd_en=> '1',
		EoC_in=>EoC_sig,
		start=> start_n_mac,
		start_in=> start_mem,

		rd_port=> n_mac_mem
	);

	mem_n_sub_inst: input_mem_abn
	generic map(
		WRITE_WIDTH	=> N_BITS_PER_WORD,
		READ_WIDTH	=> N_BITS_PER_WORD,
		CYLCES_TO_WAIT	=> 1,
		LATENCY	=> LATENCY_N_SUB,

		MEMORY_DEPTH	=> MEMORY_DEPTH
	)
	port map(
		clk=> clk,
		reset=> reset,
		memory_full=> open,
		wr_en=> wr_en_n_sub,
		wr_port=> n,
		rd_en=> '1',
		EoC_in=>EoC_sig,
		start=> start_n_sub,
		start_in=> start_mem,

		rd_port=> n_sub_mem
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
