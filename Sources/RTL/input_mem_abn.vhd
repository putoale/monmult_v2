
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

use IEEE.NUMERIC_STD.ALL;
--!this module takes care of storing the entire input vector, and exposes the rigth word at the output at each cycle
--!this module will be istantiated three times:
--! * for the input a, which exposes one word per cycle
--! * for the input b, which expses one word every N_WORDS cycles
--! * for the input n, which exposes one word per cycle but with an initial delay

entity input_mem_abn is
	generic(
		WRITE_WIDTH: integer:=8;
		READ_WIDTH: integer :=8;   					--!In this implementation, READ_WIDTH=WRITE_WIDTH
		CYLCES_TO_WAIT: integer:=4;					--!after the first word has been exposed, after how many cycles the next word will be exposed
		LATENCY			: integer :=4; 				--!Initial time to wait after receving start_in before exposing the first word
		MEMORY_DEPTH: integer range 4 to 8192:=16	--!in this implementation, is equal to TOT_BITS/WRITE_WIDTH
	);
	Port (

		clk 		: in std_logic;
		reset		: in std_logic;
		memory_full	: out std_logic:='0';

		wr_en		: in std_logic;													--!has to be kept high while writing
		wr_port		: in  std_logic_vector(WRITE_WIDTH-1 downto 0);					--!accepts one word at a time, loaded by the testbench
		rd_en		: in  std_logic;												--!has to be kept high while reading
		rd_port		: out std_logic_vector(READ_WIDTH-1 downto 0):=(others=>'0');	--!exposes one word at a time, at the right cycle
		start		: out std_logic:='0';											--!unused in this implementation

		---add start latency
		start_in	: in std_logic;													--!this notifies the memory that all memories are full and ready to start providing data
		EoC_in		: in std_logic													--!End of Conversion input to notify the memory that the content of the memory can be reset on order to be ready for another computation
  );
end input_mem_abn;

architecture Behavioral of input_mem_abn is
	type memory_type is array (MEMORY_DEPTH-1 downto 0) of std_logic_vector(READ_WIDTH-1 downto 0);
	signal memory:memory_type;

	signal write_counter: integer range 0 to MEMORY_DEPTH :=0;
	signal read_counter: integer range 0 to MEMORY_DEPTH :=0;
	signal memory_full_int: std_logic:='0';
	signal cycle_counter: integer:=0;
	signal initial_counter: integer:=0;
	signal begin_reading: std_logic:='0';
	signal start_flag: std_logic:='0';
	signal start_int : std_logic := '0';
begin
	memory_full<=memory_full_int;
	start <= start_int;
	start_int<=memory_full_int;
	process(clk,reset, EoC_in)
	begin

		if rising_edge(clk ) then
			---------------------RESET-----------------------------------
			if reset = '1' or EoC_in = '1' then
				memory_full_int<='0';
				memory<=(others=>(others=>'0'));
				begin_reading<='0';
				write_counter<=0;
				read_counter<=0;
				cycle_counter<=0;
				initial_counter<=0;
				start_flag<='0';
			--------------------------------------------------------------------------
			else

				if start_in='1' then
					start_flag<='1';
				end if;
				---------------INITIAL WAITING TIME------------------------------
				if begin_reading= '0' and (start_in = '1' or  start_flag='1') then
					initial_counter<=initial_counter+1;
					if initial_counter = LATENCY-1 then
						begin_reading<='1';
						initial_counter<=0;
					end if;
				end if;
				----------------------------------------------------------------

				----------------WRITE PROCESS---------------------------------
				--in this implementation, the memory is completely written BEFORE it can be read
				if wr_en='1'  and memory_full_int = '0' then
					memory(write_counter)<=wr_port;
					write_counter<=write_counter+1;
					if write_counter = MEMORY_DEPTH-1 then
						write_counter<=0;
						memory_full_int<='1';
						else
						memory_full_int<= '0';
					end if;
				end if;
				----------------------------------------------------------------

				----------------READ PROCESS---------------------------------
				--this process takes care of exposing the right word at the right cycle
				if rd_en='1' and memory_full_int='1' and begin_reading='1'  then
					cycle_counter<=cycle_counter+1 ;
					rd_port<=memory(read_counter);
					if cycle_counter = CYLCES_TO_WAIT-1 then
						cycle_counter<=0;
						read_counter<=read_counter+1;
						if read_counter = MEMORY_DEPTH-1 then
							read_counter<=0;
						end if;
					end if;
					----------------------------------------------------------------
				end if;
			end if;



		end if;
	end process;
end Behavioral;
