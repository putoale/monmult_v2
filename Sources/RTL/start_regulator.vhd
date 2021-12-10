
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;


entity start_regulator is

	port(
			clk	:	in std_logic;
			reset:	in std_logic;
			in_1: in std_logic;
			in_2: in std_logic;
			in_3: in std_logic;
			in_4: in std_logic;
			EoC: in std_logic;
			output_start	:		out std_logic:='0';
			output_start_reg:	out std_logic:='0'
	);
end start_regulator;

architecture Behavioral of start_regulator is

		signal flag_1: std_logic:='0';
		signal flag_2: std_logic:='0';
		signal flag_3: std_logic:='0';
		signal flag_4: std_logic:='0';

		signal  accept_1: std_logic:='1';
		signal  accept_2: std_logic:='1';
		signal  accept_3: std_logic:='1';
		signal accept_4: std_logic:='1';
		signal output_start_int: std_logic:='0';
		signal output_start_reg_int: std_logic:='0';
		signal output_start_reg_reg_int: std_logic := '0';
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
