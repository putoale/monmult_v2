
--  ############ Insert Only the Usefor Sections ################

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




entity tb_sub_v2 is
end tb_sub_v2;

architecture Behavioral of tb_sub_v2 is

	------------------ CONSTANT DECLARATION -------------------------

	--------- Timing -----------
	constant	CLK_PERIOD 	:	TIME	:= 10 ns;
	constant	RESET_WND	:	TIME	:= 10*CLK_PERIOD;
	----------------------------

	--- TB Initialiazations ---
	constant	TB_CLK_INIT		:	STD_LOGIC	:= '0';
	constant	TB_RESET_INIT 	:	STD_LOGIC	:= '1';
	----------------------------


	------- DUT Generics -------
  	constant DUT_N_BITS_PER_WORD : POSITIVE range 8 to 64 := 8;
  	constant DUT_N_WORDS : POSITIVE range 4 to 512 := 4;
	----------------------------

	---------- OTHERS ----------
	constant CLK_TO_DATA_IN : POSITIVE := DUT_N_WORDS * (DUT_N_WORDS-1) + 2;
	----------------------------

	-----------------------------------------------------------------



	------------------------ TYPES DECLARATION ----------------------

	--------- SECTION ----------
	type data_in_type is array(0 to DUT_N_WORDS-1) of std_logic_vector(DUT_N_BITS_PER_WORD-1 downto 0);
	----------------------------

	-----------------------------------------------------------------




	--------------------- FUNCTIONS DECLARATION ---------------------

	--------- SECTION ----------
	-- NONE
	----------------------------

	-----------------------------------------------------------------



	------ COMPONENT DECLARATION for the Device Under Test (DUT) ------

	-------- First DUT ---------
  component FSM_sub_v2 is
    Generic(
              N_BITS_PER_WORD : POSITIVE range 8 to 64 := 32;
              N_WORDS : POSITIVE range 4 to 512 := 4
    );
    Port (
            --------------------- Clk / Reset------------------
            clk   : in std_logic;
            reset : in std_logic;
            ---------------------------------------------------

            ----------------- Control signals------------------
            start : in std_logic;
            EoC   : out std_logic;
            ---------------------------------------------------

            -------------------- Input data -------------------
            t_in_mac : std_logic_vector (N_BITS_PER_WORD-1 downto 0);
			t_in_add : std_logic_vector (N_BITS_PER_WORD-1 downto 0);
            n_in : std_logic_vector (N_BITS_PER_WORD-1 downto 0);
            ---------------------------------------------------

            ------------------- Output data -------------------
            mult_result : out std_logic_vector(N_BITS_PER_WORD-1 downto 0) := (Others =>'0')
            ---------------------------------------------------
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

  ----------------- Control signals------------------
  signal dut_start : std_logic;
  signal dut_EoC   : std_logic;
  ---------------------------------------------------

  -------------------- Input data -------------------
  signal dut_t_in_mac : std_logic_vector (DUT_N_BITS_PER_WORD-1 downto 0):= (Others =>'0');
  signal dut_t_in_add : std_logic_vector (DUT_N_BITS_PER_WORD-1 downto 0):= (Others =>'0');
  signal dut_n_in : std_logic_vector (DUT_N_BITS_PER_WORD-1 downto 0):= (Others =>'0');
  ---------------------------------------------------

  ------------------- Output data -------------------
  signal dut_mult_result : std_logic_vector(DUT_N_BITS_PER_WORD-1 downto 0) := (Others =>'0');
  ---------------------------------------------------

  ------------------------------Input data ports----------------------------------------

  signal big_in_array : data_in_type := (
                                          X"88",
                                          X"99",
                                          X"AA",
                                          X"BB"
                                          );

  signal small_in_array : data_in_type := (X"02",
                                          X"11",
                                          X"22",
                                          X"33"
                                          );
  --------------------------------------------------------------------------------------

	----------------------------


	----- Last DUT Signals -----
	-- NONE
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
	FSM_sub_inst : FSM_sub_v2
  Generic map(
                N_BITS_PER_WORD => DUT_N_BITS_PER_WORD,
                N_WORDS => DUT_N_WORDS

  )
  Port map(
            clk => clk,
            reset => reset,
            start => dut_start,
            EoC   => dut_EoC,

            t_in_mac  => dut_t_in_mac,
			t_in_add  => dut_t_in_add,
            n_in  => dut_n_in,

            mult_result => dut_mult_result
  );
	----------------------------


	--------- Last DUT ---------
	-- NONE
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
    dut_start <= '1';
		wait until rising_edge(clk);
		dut_start <= '0';

		wait;
    end process;
	----------------------------


   ------ Stimulus process -------

    stim_proc: process
    begin
		-- waiting the reset wave
		wait for RESET_WND;
    wait until rising_edge(clk);

    for i in 0 to CLK_TO_DATA_IN -1 loop
      wait until rising_edge(clk);
    end loop;

		for i in 0 to DUT_N_WORDS-2 loop

			dut_t_in_mac <= small_in_array(i);
			dut_n_in <= big_in_array(i);
			wait until rising_edge(clk);

		end loop;
			dut_n_in <= X"ED";
			dut_t_in_add <= big_in_array(small_in_array'high);

		-- Start


        -- Stop
		wait;




      wait;
    end process;
	----------------------------


	------ Sync Process --------
	-- NONE
	----------------------------


	----- Async Process --------
	-- NONE
	----------------------------


	--------- SECTION ----------
	-- NONE
	----------------------------

	-------------------------------------------------------------------


end;
