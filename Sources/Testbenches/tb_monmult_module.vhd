
library IEEE;
library STD;
use std.textio.all;
use ieee.std_logic_textio.all;
use IEEE.STD_LOGIC_1164.ALL;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.	ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity tb_monmult_module is
end tb_monmult_module;

architecture Behavioral of tb_monmult_module is

	component monmult_module is
		generic (
			WRITE_WIDTH: integer :=8;
			READ_WIDTH: integer :=8;
			N_BITS_PER_WORD		:integer :=8;
			N_WORDS				:integer :=4;
			MEMORY_DEPTH: integer:=16

		);
		Port (
			clk: in std_logic;
			reset: in std_logic;
			wr_en_a: in std_logic;
			wr_en_b: in std_logic;
			wr_en_n_mac: in std_logic;
			wr_en_n_sub: in std_logic;
			EoC: out std_logic:='0';
			a					:in std_logic_vector(N_BITS_PER_WORD-1 downto 0);
			b					:in std_logic_vector(N_BITS_PER_WORD-1 downto 0);
			n					:in std_logic_vector(N_BITS_PER_WORD-1 downto 0);
			nn0				:in std_logic_vector(N_BITS_PER_WORD-1 downto 0);
			result		:out std_logic_vector(N_BITS_PER_WORD-1 downto 0):=(others=>'0')
		);
	end component;
	-----------_CONSTANTS---------------------------------------------------------
	--total is 256 bits, to be divided in 4*64
	constant N_BITS_PER_WORD: integer:=64;
	constant N_WORDS: integer :=4;
	constant	MEMORY_DEPTH: integer:=4;
	constant WRITE_WIDTH: integer :=64;
	constant READ_WIDTH: integer :=64;

	constant CLK_PERIOD: time:=10 ns;
	constant C_FILE_NAME :string  := "/home/matteo/Documents/monmult_v2/Sources/Python/tb_vec_gentxtout_results.txt"; --absolute path
	constant time_between_tests: time := CLK_PERIOD * N_WORDS *N_WORDS;
	------------------------------------------------------------------------------

	----------SIGNALS-------------------------------------------------------------
	signal clk: std_logic:='0';
	signal reset: std_logic:='0';
	signal wr_en_a: std_logic;
	signal wr_en_b: std_logic;
	signal wr_en_n_mac: std_logic;
	signal wr_en_n_sub: std_logic;
	signal a: std_logic_vector(N_BITS_PER_WORD-1 downto 0);
	signal b: std_logic_vector(N_BITS_PER_WORD-1 downto 0);
	signal n: std_logic_vector(N_BITS_PER_WORD-1 downto 0);
	signal nn0: std_logic_vector(N_BITS_PER_WORD-1 downto 0);
	signal result: std_logic_vector(N_BITS_PER_WORD-1 downto 0);
	signal EoC: std_logic;
	------------------------------------------------------------------------------

	---------FILE HANDLES---------------------------------------------------------

	------------------------------------------------------------------------------
begin
	---------------------MODULE INSTANTIATION-------------------------------------

	monmult_inst: monmult_module
		generic map(
			WRITE_WIDTH=> 						WRITE_WIDTH,
			READ_WIDTH=> 							READ_WIDTH,
			N_BITS_PER_WORD		=> 			N_BITS_PER_WORD,
			N_WORDS				=> 					N_WORDS,
			MEMORY_DEPTH=> 						MEMORY_DEPTH

		)
		Port map (
			clk 					=> clk,
			reset 				=> reset,
			wr_en_a 			=> wr_en_a,
			wr_en_b 			=> wr_en_b,
			wr_en_n_mac	=> wr_en_n_mac,
			wr_en_n_sub 	=> wr_en_n_sub,
			EoC				=> EoC,
			a							=> a,
			b							=> b,
			n							=> n,
			nn0						=> nn0,
			result				=> result

				);



	------------------------------------------------------------------------------
	clk<=not clk after CLK_PERIOD/2;

	reset<='1', '0' after 10 ns;
	stimulus: process

	file fptr: text open read_mode is C_FILE_NAME;

	variable file_line     :line;
	--variable var_data1     :std_logic_vector(N_BITS_PER_WORD-1 downto 0);
	variable var_data1     :std_logic_vector(N_BITS_PER_WORD-1 downto 0);
	variable char     :character;

	begin
		wait until reset = '0' ;
		while (not endfile(fptr) ) loop
			wait until rising_edge(clk);
			readline(fptr, file_line);
			--this statement is used three times, for a, b, n
			for i in 0 to N_WORDS-1 loop --looping over the words composing an input i.e a
				wr_en_a<='1';
				--hread(file_line, var_data1);
				hread(file_line, var_data1);
				a      <= var_data1;
				wait until rising_edge(clk);
				read(file_line, char);
				wait until rising_edge(clk);
				wr_en_a<='0';
			end loop;
			for i in 0 to N_WORDS-1 loop --looping over the words composing an input i.e a
				--hread(file_line, var_data1);
				wr_en_b<='1';

				hread(file_line, var_data1);
				b      <= var_data1;
				wait until rising_edge(clk);
				read(file_line, char);
				wait until rising_edge(clk);
				wr_en_b<='0';

			end loop;
			for i in 0 to N_WORDS-1 loop --looping over the words composing an input i.e a
				--hread(file_line, var_data1);
				wr_en_n_mac<='1';
				wr_en_n_sub<='1';
				hread(file_line, var_data1);
				n      <= var_data1;
				wait until rising_edge(clk);
				read(file_line, char);
				wait until rising_edge(clk);
				wr_en_n_mac<='0';
				wr_en_n_sub<='1';
			end loop;
			--now the nn0 read
			hread(file_line, var_data1);
			nn0<=var_data1;
			wait until rising_edge(clk);

			wait for CLK_PERIOD*100;
		end loop;
		file_close(fptr);
		wait;

end process;
end architecture;
