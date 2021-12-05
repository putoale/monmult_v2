
--  ############ Insert Only the Usefor Sections ################

---------- DEFAULT LIBRARY ---------
library IEEE;
	use IEEE.STD_LOGIC_1164.all;
	use IEEE.NUMERIC_STD.ALL;
--	use IEEE.MATH_REAL.all;

--	use STD.textio.all;
--	use ieee.std_logic_textio.all;



entity tb_mac_ab is
end tb_mac_ab;

architecture Behavioral of tb_mac_ab is

	------------------ CONSTANT DECLARATION -------------------------

	--------- Timing -----------
	constant	CLK_PERIOD 	:	TIME	:= 10 ns;
	constant	RESET_WND	:	TIME	:= 10 * CLK_PERIOD;
	----------------------------

	--- TB Initialiazzations ---
	constant	TB_CLK_INIT		:	STD_LOGIC	:= '0';
	constant	TB_RESET_INIT 	:	STD_LOGIC	:= '1';
	----------------------------


	------- DUT Generics -------
	constant DUT_N_WORDS           : POSITIVE range 4 to 512 := 16;
	constant DUT_N_BITS_PER_WORD   : POSITIVE range 8 to 64  := 8;
	----------------------------
	-----------------------------------------------------------------



	------------------------ TYPES DECLARATION ----------------------

	--------- SECTION ----------
	-- NONE
	----------------------------

	-----------------------------------------------------------------




	--------------------- FUNCTIONS DECLARATION ---------------------

	--------- SECTION ----------
	-- NONE
	----------------------------

	-----------------------------------------------------------------



	------ COMPONENT DECLARATION for the Device Under Test (DUT) ------

	-------- First DUT ---------
	component FSM_mac_ab is
		generic(
			N_WORDS				: integer	:=4;
			N_BITS_PER_WORD		: integer	:=8

		);
	    Port ( clk : in STD_LOGIC;
	           reset : in STD_LOGIC;
			   start : in std_logic;

			   a : in STD_LOGIC_VECTOR (N_BITS_PER_WORD-1  downto 0);
	           b : in STD_LOGIC_VECTOR (N_BITS_PER_WORD-1  downto 0);
	           t_mac_in : in STD_LOGIC_VECTOR (N_BITS_PER_WORD-1  downto 0);
	           t_adder_in : in STD_LOGIC_VECTOR (N_BITS_PER_WORD-1  downto 0);
	           t_mac_out : out STD_LOGIC_VECTOR (N_BITS_PER_WORD-1  downto 0);
	           c_mac_out : out STD_LOGIC_VECTOR (N_BITS_PER_WORD-1  downto 0)

			   );


	end component;
	----------------------------


	--------- Last DUT ---------
	-- NONE
	----------------------------

	------------------------------------------------------------------




	--------------------- SIGNALS DECLARATION -----------------------


	------- Clock/Reset  -------
	signal	reset	:	STD_LOGIC	:= TB_RESET_INIT;
	signal	clk		:	STD_LOGIC	:= TB_CLK_INIT;
	----------------------------

	----- First DUT Signals ----
	constant ADDER_VALUE: integer:= 2**DUT_N_BITS_PER_WORD -1 ;
	signal dut_start  :  std_logic := '0'; -- start signal from outside

	------------------------------Input data ports----------------------------------------
	signal dut_a  :  std_logic_vector (DUT_N_BITS_PER_WORD-1 downto 0):= (Others =>'0'); -- input word from mac_ab
	signal dut_b  :  std_logic_vector (DUT_N_BITS_PER_WORD-1 downto 0):= (Others =>'0'); -- input n'(0)
	--------------------------------------------------------------------------------------

	----------------------------------Output data ports-----------------------------------
	signal dut_t_mac_in :  std_logic_vector (DUT_N_BITS_PER_WORD-1 downto 0) := (Others =>'0');
	signal dut_t_adder_in :  std_logic_vector (DUT_N_BITS_PER_WORD-1 downto 0) := (Others =>'0');
	signal dut_t_mac_out	: std_logic_vector (DUT_N_BITS_PER_WORD-1 downto 0) := (Others =>'0');
	signal dut_c_mac_out	: std_logic_vector (DUT_N_BITS_PER_WORD-1 downto 0) := (Others =>'0');
	--------------------------------------------------------------------------------------
	----------------------------


	----- Last DUT Signals -----
	signal counter: integer range 0 to DUT_N_WORDS*DUT_N_WORDS-1 :=0;
	signal  int_value: integer range 0 to 2**(DUT_N_BITS_PER_WORD)-1 :=15;
	signal counter_mac: integer:=0;
	signal counter_add: integer:=0;
	----------------------------


	----- OTHERS Signals -------
	-- NONE
	----------------------------

	----------------------------------------------------------------




	-------------------------- ATTRIBUTES --------------------------

	--------- SECTION ----------
	-- NONE
	----------------------------

	-----------------------------------------------------------------




begin




	--------------------- COMPONENTS DUT WRAPPING --------------------

	-------- First DUT ---------
	mac_ab_dut: FSM_mac_ab
	Generic map(
			N_WORDS => DUT_N_WORDS,
			N_BITS_PER_WORD => DUT_N_BITS_PER_WORD
	)
	Port map (
			clk => clk,
			reset => reset,
			start => dut_start,
			a				=>  dut_a,
			b				=> dut_b,
			t_mac_in		=> dut_t_mac_in,
			t_adder_in		=> dut_t_adder_in,
			t_mac_out		=> dut_t_mac_out,
			c_mac_out		=> dut_c_mac_out

	);
	----------------------------

	-------------------------------------------------------------------


	--------------------- TEST BENCH DATA FLOW  -----------------------

	---------- clock ----------
	clk<= not clk after  CLK_PERIOD/2;
	----------------------------

	--------- SECTION ----------
	-- NONE
	----------------------------

	-------------------------------------------------------------------


	---------------------- TEST BENCH PROCESS -------------------------


	----- Reset Process --------
	reset_wave :process
	begin
		reset <= TB_RESET_INIT;
		wait for RESET_WND;

		reset <= not reset;
		wait until rising_edge(clk);

		wait;
    end process;
	----------------------------


   ------ Stimulus process -------
	 generate_4: if DUT_N_WORDS=4 generate
    stim_proc: process
    begin
		-- waiting the reset wave
		wait for RESET_WND;


		-- Start
		wait until rising_edge(clk);
		dut_start <= '1';
		for i in 0 to DUT_N_WORDS-1 loop
			for j in 0 to DUT_N_WORDS-1 loop
				counter<=counter+1;
				if counter  = DUT_N_WORDS*DUT_N_WORDS-1 then
					counter <= 0;
				end if;
				dut_a<=std_logic_vector(to_unsigned(counter, dut_a'length));
				if j= 0 then
					dut_b<= std_logic_vector(to_unsigned(counter, dut_a'length));
				end if;
				if i /= 0 then
				elsif j/=DUT_N_WORDS-1 then
					dut_t_mac_in <= std_logic_vector(to_unsigned(counter, dut_a'length));
				elsif j=DUT_N_WORDS-1 then
					dut_t_adder_in<= std_logic_vector(to_unsigned(ADDER_VALUE, dut_a'length));
				end if;
				int_value<=int_value+1;
				wait until rising_edge(clk);

			end loop;
		end loop;
    -- Stop
      wait;
    end process;
	end generate;

	----------------------------
	------ Stimulus process -------
  generate_bigger: if DUT_N_WORDS>4 generate
 	stim_proc: process
 	begin
 	-- waiting the reset wave
 	wait for RESET_WND;


 	-- Start
 	wait until rising_edge(clk);
 	dut_start <= '1';
 	for i in 0 to DUT_N_WORDS-1 loop
 		for j in 0 to DUT_N_WORDS-1 loop
 			counter<=counter+1;
 			if counter  = DUT_N_WORDS*DUT_N_WORDS-1 then
 				counter <= 0;

			--	din_dut<=	(others=>'0') when counter <4 else
			--						t_mac_in when counter < N_WORDS*N_WORDS-1 else
			--						t_adder_in when counter = N_WORDS*N_WORDS-1;
 			end if;
 			dut_a<=std_logic_vector(to_unsigned(counter, dut_a'length));
 			if j= 0 then
 				dut_b<= std_logic_vector(to_unsigned(counter, dut_a'length));
 			end if;
			dut_t_mac_in <= std_logic_vector(to_unsigned(counter, dut_a'length));
			dut_t_adder_in<= std_logic_vector(to_unsigned(ADDER_VALUE, dut_a'length));
 			wait until rising_edge(clk);

 		end loop;
 	end loop;
 	-- Stop
 		wait;
 	end process;
 end generate;


end;
