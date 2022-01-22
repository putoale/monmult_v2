
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


use IEEE.NUMERIC_STD.ALL;
--!takes as input the start output of the memories, and feeds to the modules and the memories a start signal, and it is useful if the memories are not filled at the same time
--!
entity start_regulator is

	port(
			clk	:	in std_logic;
			reset:	in std_logic;
			in_1: in std_logic; --! outputs of the memories, goes high when memory full, can be one cycle or more cycle long
			in_2: in std_logic; --! outputs of the memories, goes high when memory full, can be one cycle or more cycle long
			in_3: in std_logic; --! outputs of the memories, goes high when memory full, can be one cycle or more cycle long
			in_4: in std_logic; --! outputs of the memories, goes high when memory full, can be one cycle or more cycle long
			EoC: in std_logic;	--!End of Conversion, resets the module when computation is over
			output_start	:		out std_logic:='0';	--! notifies the memories that the can start exposing on the rd_port
			output_start_reg:	out std_logic:='0'	--! notifies the computation modules that they can start reading
	);
end start_regulator;

architecture Behavioral of start_regulator is

		signal flag_1: std_logic:='0';  --! flags to hold the value '1' of the input signal
		signal flag_2: std_logic:='0';  --! flags to hold the value '1' of the input signal
		signal flag_3: std_logic:='0';  --! flags to hold the value '1' of the input signal
		signal flag_4: std_logic:='0';  --! flags to hold the value '1' of the input signal

		signal  accept_1: std_logic:='1';  --! is '1' when the module has not yes stored a previous value '1'
		signal  accept_2: std_logic:='1';  --! is '1' when the module has not yes stored a previous value '1'
		signal  accept_3: std_logic:='1';  --! is '1' when the module has not yes stored a previous value '1'
		signal accept_4: std_logic:='1';  --! is '1' when the module has not yes stored a previous value '1'
		signal output_start_int: std_logic:='0';						--! replica of output_start, needed in order for the output port to be readable
		signal output_start_reg_int: std_logic:='0';				--! replica of output_start delayed by one cylce
		signal output_start_reg_reg_int: std_logic := '0';	--! replica of output_start delayed by two cylces
begin
	output_start<=output_start_int;
	output_start_reg<=output_start_reg_reg_int;
	process(clk, reset)
	begin
			if rising_edge(clk) then
				output_start_int<='0';
				output_start_reg_int<=output_start_int;
				output_start_reg_reg_int <= output_start_reg_int;
				if reset='1' or EoC = '1' then
					flag_1<='0';
					flag_2<='0';
					flag_3<='0';
					flag_4<='0';
					accept_1<='1';
					accept_2<='1';
					accept_3<='1';
					accept_4<='1';
					output_start_int<='0';
					output_start_reg_int<='0';
				end if;
				if in_1='1' and 	accept_1='1' then
					flag_1<='1';

				end if;
				if in_2='1'and 	accept_2='1' then
					flag_2<='1';

				end if;
				if in_3='1'and 	accept_3='1' then
					flag_3<='1';

				end if;
				if in_4='1'and 	accept_4='1' then
					flag_4<='1';

				end if;
				if flag_1='1' and flag_2='1' and flag_3='1' and flag_4='1' and output_start_reg_int<='0' then
					output_start_int<='1';
					flag_1<='0';
					flag_2<='0';
					flag_3<='0';
					flag_4<='0';
					accept_1<='0';
					accept_2<='0';
					accept_3<='0';
					accept_4<='0';
				end if;


			end if;
	end process;

end Behavioral;
