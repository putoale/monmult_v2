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

entity input_mem is
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
end input_mem;

architecture Behavioral of input_mem is
	type memory_type is array (MEMORY_DEPTH-1 downto 0) of std_logic_vector(READ_WIDTH-1 downto 0);
	signal memory:memory_type;

	signal write_counter: integer range 0 to MEMORY_DEPTH :=0;
	signal read_counter: integer range 0 to MEMORY_DEPTH :=0;
	signal memory_full: std_logic;
	signal memory_empty: std_logic;
	signal cycle_counter: integer:=0;
begin

	process(clk)
	begin
		if rising_edge(clk ) then
			if wr_en='1' then
				memory(write_counter)<=wr_port;
				write_counter<=write_counter+1;
				if write_counter = MEMORY_DEPTH-1 then
					write_counter<=0;
					memory_full<='1';
				end if;
			end if;

			if rd_en='1' and memory_full='1' then
				cycle_counter<=cycle_counter+1 ;
				if cycle_counter = CYLCES_TO_WAIT-1 then
					cycle_counter<=0;
					rd_port<=memory(read_counter);
					read_counter<=read_counter+1;
					if read_counter = MEMORY_DEPTH-1 then
						read_counter<=0;
					end if;
				end if;

			end if;




		end if;
	end process;
end Behavioral;
