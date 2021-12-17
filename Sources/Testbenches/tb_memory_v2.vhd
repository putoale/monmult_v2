library IEEE;
	use IEEE.STD_LOGIC_1164.ALL;
	use IEEE.NUMERIC_STD.ALL;

entity tb_memory_v2 is
end;


architecture behavioral of tb_memory_v2 is



	component input_mem_v2 is
		generic(
			WRITE_WIDTH: integer:=8;
			READ_WIDTH: integer :=8;   --assuming READ_WIDTH=WRITE_WIDT, for now
			CYLCES_TO_WAIT: integer:=4;   --goes from 1 for a to and entire N_WORDS for b
			LATENCY			: integer :=4; 		--goes from 1 to what needed
			N_BITS_TOTAL	: integer :=64
			--MEMORY_DEPTH: integer:=16
			--FULL_READ_NUMBER: integer := 4
		);
		Port (

			clk 		: in std_logic;
			reset		: in std_logic;
			memory_full	: out std_logic:='0';

			wr_en		: in std_logic;
			wr_port		: in  std_logic_vector(WRITE_WIDTH-1 downto 0);
			rd_en		: in  std_logic;
			rd_port		: out std_logic_vector(READ_WIDTH-1 downto 0):=(others=>'0');
			start		: out std_logic:='0';

			---add start latency
			start_in	: in std_logic;
			EoC_in		: in std_logic
	  );
	end component;
	constant	N_BITS_TOTAL		: integer :=256;
	constant	WRITE_WIDTH		: integer := 16;
	constant	READ_WIDTH		: integer := 64;
	constant	CYLCES_TO_WAIT		: integer := 4;
	constant	MEM_MEMORY_DEPTH		: integer := N_BITS_TOTAL/READ_WIDTH;  --needed for memory_abn
	constant	CONTROLLER_MEMORY_DEPTH	: integer := N_BITS_TOTAL/WRITE_WIDTH;
	constant LATENCY:INTEGER :=4;
	constant CLK_PERIOD: time:=10 ns;
	signal clk : std_logic:='0';
	signal reset: std_logic:='0';
	signal start		:  std_logic:='0';

	---add start latency
	signal start_in	:  std_logic;
	signal EoC_in	:  std_logic;
	signal wr_en: std_logic;
	signal rd_en: std_logic;
	signal wr_port: std_logic_vector(WRITE_WIDTH-1 downto 0);
	signal rd_port: std_logic_vector(READ_WIDTH-1 downto 0);

begin
	clk<=not clk after CLK_PERIOD/2;
	mem_inst: input_mem_v2
    	generic map (
  		WRITE_WIDTH		=>WRITE_WIDTH,
  		READ_WIDTH		=>READ_WIDTH,
  		CYLCES_TO_WAIT		=>CYLCES_TO_WAIT,
  		LATENCY=>LATENCY,
  		--MEMORY_DEPTH		=>MEM_MEMORY_DEPTH,
		N_BITS_TOTAL=>N_BITS_TOTAL
  	)

  	port map(
  		clk		=>	clk,
  		reset		=>	reset,


  		wr_en		=>	wr_en,
  		wr_port		=>	wr_port,
  		rd_en		=>	rd_en,
  		rd_port		=>	rd_port,
		start		=> start,
		start_in	=> start_in,
		EoC_in		=> EoC_in

  	);

		rd_en<='1';
		load_memory:PROCESS
		begin
			reset<='1';
			EoC_in<='1';
			wait until rising_edge(clk);
			reset<='0';
			EoC_in<='0';
			wait until rising_edge(clk);


			wait until rising_edge(clk);
			wr_en<='1';

			for i in 0 to CONTROLLER_MEMORY_DEPTH-1 loop

				wr_port<= std_logic_vector(to_unsigned(i, wr_port'length));
				wait until rising_edge(clk);
			end loop;
			wr_en<='0';
			--for i in 0 to MEM_MEMORY_DEPTH +1  loop
			--	wait until rising_edge(clk);
			--end loop;
			wait until start='1';
			wait for CLK_PERIOD*2;
			start_in<='1';
			wait until rising_edge(clk);
			start_in<='0';
			wait;
		end process;

end behavioral;
