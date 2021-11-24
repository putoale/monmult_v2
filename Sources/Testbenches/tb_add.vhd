
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




entity tb_add is
end tb_add;

architecture Behavioral of tb_add is

	------------------ CONSTANT DECLARATION -------------------------

	--------- Timing -----------
	constant	CLK_PERIOD 	:	TIME	:= 10 ns;
	constant	RESET_WND	:	TIME	:= 10*CLK_PERIOD;
	----------------------------

	--- TB Initialiazzations ---
	constant	TB_CLK_INIT		:	STD_LOGIC	:= '0';
	constant	TB_RESET_INIT 	:	STD_LOGIC	:= '1';
	----------------------------


	------- DUT Generics -------
  constant DUT_N_WORDS         : POSITIVE range 4 to 512 := 5;
  constant DUT_N_BITS_PER_WORD : POSITIVE range 8 to 64  := 8;
	----------------------------

	---------- OTHERS ----------
	constant D_IN_LENGTH : POSITIVE range 2 to 512 := 2;
	----------------------------

	-----------------------------------------------------------------



	------------------------ TYPES DECLARATION ----------------------

	--------- SECTION ----------
	type data_in_type is array(0 to (D_IN_LENGTH-1)) of std_logic_vector(DUT_N_BITS_PER_WORD-1 downto 0);
	----------------------------

	-----------------------------------------------------------------




	--------------------- FUNCTIONS DECLARATION ---------------------

	--------- SECTION ----------
	-- NONE
	----------------------------

	-----------------------------------------------------------------



	------ COMPONENT DECLARATION for the Device Under Test (DUT) ------

	-------- First DUT ---------
  component FSM_add is
    Generic(
              N_WORDS         : POSITIVE range 4 to 512 := 4;
              N_BITS_PER_WORD : POSITIVE range 8 to 64  := 32
    );
    Port (
            -------------------------- Clk/Reset --------------------
            clk   : in std_logic;
            reset : in std_logic;
            ---------------------------------------------------------

            --------------------- Ctrl signals ----------------------
            start : in std_logic;
            ---------------------------------------------------------

            ---------------------- Input data ports -----------------
            c_in_ab : in std_logic_vector (N_BITS_PER_WORD-1 downto 0);
            c_in_mn : in std_logic_vector (N_BITS_PER_WORD-1 downto 0);
            ---------------------------------------------------------

            ---------------------- Output data ports -----------------
            c_out : out std_logic_vector (N_BITS_PER_WORD-1 downto 0):=(Others =>'0');
            t_out : out std_logic_vector (N_BITS_PER_WORD-1 downto 0):=(Others =>'0')
            ---------------------------------------------------------


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

  --------------------- Ctrl signals ----------------------
  signal dut_start : std_logic;
  ---------------------------------------------------------

  ---------------------- Input data ports -----------------
  signal dut_c_in_ab : std_logic_vector (DUT_N_BITS_PER_WORD-1 downto 0):= (Others =>'0');
  signal dut_c_in_mn : std_logic_vector (DUT_N_BITS_PER_WORD-1 downto 0):= (Others =>'0');
  ---------------------------------------------------------

  ---------------------- Output data ports -----------------
  signal dut_c_out : std_logic_vector (DUT_N_BITS_PER_WORD-1 downto 0):=(Others =>'0');
  signal dut_t_out : std_logic_vector (DUT_N_BITS_PER_WORD-1 downto 0):=(Others =>'0');
  ---------------------------------------------------------
	----------------------------


	----- Last DUT Signals -----
	-- NONE
	----------------------------


	----- OTHERS Signals -------
  signal c_in_ab_array : data_in_type := (X"02",
																					X"11");

  signal c_in_mn_array : data_in_type := (X"44",
  																			 X"FF");

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
	FSM_add_dut : FSM_add
  Generic Map(
                N_WORDS => DUT_N_WORDS,
                N_BITS_PER_WORD => DUT_N_BITS_PER_WORD

  )
  Port map(
            clk   => clk,
            reset => reset,

            start => dut_start,

            c_in_ab => dut_c_in_ab,
            c_in_mn => dut_c_in_mn,

            c_out => dut_c_out,
            t_out => dut_t_out

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

    stim_proc_ab: process
    begin
		-- waiting the reset wave
		wait for RESET_WND;

    -- Start

    for i in 0 to DUT_N_WORDS-1 loop
      wait until rising_edge(clk);
    end loop;

    for i in 0 to D_IN_LENGTH-1 loop

      dut_c_in_ab <= c_in_ab_array(i);
      wait until rising_edge(clk);

    end loop;

    -- Stop

      wait;
    end process;

    stim_proc_mn: process
    begin
		-- waiting the reset wave
		wait for RESET_WND;

    -- Start

    for i in 0 to DUT_N_WORDS + 1 loop
      wait until rising_edge(clk);
    end loop;

    for i in 0 to D_IN_LENGTH-1 loop

      dut_c_in_mn <= c_in_mn_array(i);
      wait until rising_edge(clk);

    end loop;

    -- Stop

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
