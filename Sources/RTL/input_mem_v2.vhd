

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;




entity input_mem_v2 is
	generic(
		WRITE_WIDTH: integer:=8;
		READ_WIDTH: integer :=8;   --assuming READ_WIDTH=WRITE_WIDT, for now
		CYLCES_TO_WAIT: integer:=4;   --goes from 1 for a to and entire N_WORDS for b
		LATENCY			: integer :=4; 		--goes from 1 to what needed
		N_BITS_TOTAL	: integer :=64;
		MEMORY_DEPTH: integer:=16
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
end input_mem_v2;


architecture Behavioral of input_mem_v2 is

	component input_mem_abn is
		generic(
			WRITE_WIDTH: integer:=8;
			READ_WIDTH: integer :=8;   --assuming READ_WIDTH=WRITE_WIDT, for now
			CYLCES_TO_WAIT: integer:=4;   --goes from 1 for a to and entire N_WORDS for b
			LATENCY			: integer :=4; 		--goes from 1 to what needed
			--INPUT_VS_OUTPUT: string:="INPUT";
			MEMORY_DEPTH: integer:=16
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



	component in_mem_controller is
	  generic (
	    WRITE_WIDTH : integer := 16; --read_width must be a multiple of write_width. since this is an input controller
	    READ_WIDTH  : integer := 64;

	    N_BITS_TOTAL : integer := 256
	  );
	  port (
	    clk       : in    std_logic;
	    reset     : in    std_logic;
	    out_valid : out   std_logic; -- stays at 1 as long as there are valid data on rd_port
	    wr_en     : in    std_logic; --this comes from the outside e.g. the testbench
	    wr_port   : in    std_logic_vector(write_width - 1 downto 0);
	    rd_port   : out   std_logic_vector(read_width - 1 downto 0);
	    eoc_in    : in    std_logic
	  );
	end component;


	signal rd_port_controller: std_logic_vector(READ_WIDTH-1 downto 0);
	signal out_valid_controller: std_logic;
begin

	controller_inst: in_mem_controller
	generic map(
		WRITE_WIDTH		=> WRITE_WIDTH,
		READ_WIDTH		=>READ_WIDTH,
		N_BITS_TOTAL	=>N_BITS_TOTAL
	)
	port map(
		clk			=>clk,
		reset		=>reset,
		out_valid	=> out_valid_controller,
		wr_en		=> wr_en,
		wr_port		=> wr_port,
		rd_port		=> rd_port_controller,
		eoc_in		=> EoC_in
	);

	memory_inst: input_mem_abn
	generic map(
		WRITE_WIDTH=>READ_WIDTH,
		READ_WIDTH=>READ_WIDTH,
		CYLCES_TO_WAIT =>CYLCES_TO_WAIT,
		LATENCY=>LATENCY,
		MEMORY_DEPTH=>MEMORY_DEPTH
	)
	port map(

		clk		=>	clk,
		reset		=> reset,
		memory_full		=> memory_full,
		wr_en		=>out_valid_controller,
		wr_port		=>rd_port_controller,
		rd_en		=> rd_en,
		rd_port		=> rd_port,
		start		=> start,
		start_in		=> start_in,
		EoC_in		=> EoC_in
	);



end Behavioral;
