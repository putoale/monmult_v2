----------------------------------------------------------------------------------
-- Company:
-- Engineer:
--
-- Create Date: 11/21/2021 07:09:07 PM
-- Design Name:
-- Module Name: input_mem - Behavioral
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity input_mem_abn is
	generic(
		WRITE_WIDTH: integer:=8;
		READ_WIDTH: integer :=8;   --assuming READ_WIDTH=WRITE_WIDT, for now
		CYLCES_TO_WAIT: integer:=4;   --goes from 1 for a to and entire N_WORDS for b
		LATENCY			: integer :=4; 		--goes from 1 to what needed
		--INPUT_VS_OUTPUT: string:="INPUT";
		MEMORY_DEPTH: integer:=16;
		FULL_READ_NUMBER: integer := 4
	);
	Port (

		clk : in std_logic;
		reset: in std_logic;
		memory_full: out std_logic:='0';

		wr_en: in std_logic;
		wr_port:in  std_logic_vector(WRITE_WIDTH-1 downto 0);
		rd_en:in  std_logic;
		rd_port: out std_logic_vector(READ_WIDTH-1 downto 0):=(others=>'0');
		start: out std_logic:='0';
		EoC_in: in std_logic
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
begin
	memory_full<=memory_full_int;
	process(clk,reset, EoC_in)
		--variable begin_reading:='0';
	begin

		if rising_edge(clk ) then
			if reset = '1' or EoC_in = '1' then
				memory_full_int<='0';
				memory<=(others=>(others=>'0'));
				begin_reading<='0';
				--begin_reading:='0';
				write_counter<=0;
				read_counter<=0;
				cycle_counter<=0;
			end if;
			start<=memory_full_int;
			if begin_reading= '0' and memory_full_int='1' then
				initial_counter<=initial_counter+1;
				if initial_counter = LATENCY-1 then
					begin_reading<='1';
					--begin_reading:='0';
					initial_counter<=0;
				end if;
			end if;

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

			end if;




		end if;
	end process;
end Behavioral;
