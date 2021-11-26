
---------- DEFAULT LIBRARY ---------
library IEEE;
	use IEEE.STD_LOGIC_1164.all;
	use IEEE.NUMERIC_STD.ALL;
--	use IEEE.MATH_REAL.all;

--	use STD.textio.all;
--	use ieee.std_logic_textio.all;

------------------------------------


---------- OTHERS LIBRARY ----------
-- NONE
------------------------------------




entity tb_memory is
end tb_memory;


architecture Behavioral of tb_memory is
	component input_mem is
		generic(
			WRITE_WIDTH: integer:=8;
			READ_WIDTH: integer :=8;   --assuming READ_WIDTH=WRITE_WIDT, for now
			CYLCES_TO_WAIT: integer:=4;   --goes from 1 for a to and entire N_WORDS for b
			MEMORY_DEPTH: integer:=16
		);
		Port (

			clk : in std_logic;
			reset: in std_logic;

			wr_en: in std_logic;
			wr_port:in  std_logic_vector(WRITE_WIDTH-1 downto 0);
			rd_en:in  std_logic;
			rd_port: out std_logic_vector(READ_WIDTH-1 downto 0)


	  );
  end component;
	constant	WRITE_WIDTH		: integer := 8;
	constant	READ_WIDTH		: integer := 8;
	constant	CYLCES_TO_WAIT		: integer := 4;
	constant	MEMORY_DEPTH		: integer := 16;

	constant CLK_PERIOD: time:=10 ns;
	signal clk : std_logic:='0';
	signal reset: std_logic:='0';
	signal wr_en: std_logic;
	signal rd_en: std_logic;
	signal wr_port: std_logic_vector(WRITE_WIDTH-1 downto 0);
	signal rd_port: std_logic_vector(READ_WIDTH-1 downto 0);

  begin

  mem_inst: input_mem
  	generic map (
		WRITE_WIDTH		=>WRITE_WIDTH,
		READ_WIDTH		=>READ_WIDTH,
		CYLCES_TO_WAIT		=>CYLCES_TO_WAIT,
		MEMORY_DEPTH		=>MEMORY_DEPTH
	)

	port map(
		clk		=>	clk,
		reset		=>	reset,


		wr_en		=>	wr_en,
		wr_port		=>	wr_port,
		rd_en		=>	rd_en,
		rd_port		=>	rd_port
	);


 	clk<=not clk after CLK_PERIOD/2;

	load_memory:PROCESS
	begin
		wr_en<='1';
		wait until rising_edge(clk);
		for i in 0 to MEMORY_DEPTH-1 loop

			wr_port<= std_logic_vector(to_unsigned(i, wr_port'length));
			wait until rising_edge(clk);
		end loop;
		wr_en<='1';
		wait;
	end process;

	read_memory: PROCESS
	begin
		rd_en<='1';
		wait until rising_edge(clk);
		for i in 0 to 5 loop
			for j in 0 to MEMORY_DEPTH-1 loop

			end loop;
		end loop;
	end process;
end Behavioral;
