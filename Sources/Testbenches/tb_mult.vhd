
--  ############ Insert Only the Usefor Sections ################

---------- DEFAULT LIBRARY ---------
library IEEE;
	use IEEE.STD_LOGIC_1164.all;
	use IEEE.NUMERIC_STD.ALL;
--	use IEEE.MATH_REAL.all;

--	use STD.textio.all;
--	use ieee.std_logic_textio.all;



entity tb_mult is
end tb_mult;

architecture Behavioral of tb_mult is

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
	constant DUT_N_WORDS           : POSITIVE range 4 to 512 := 4;
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
	component FSM_mult is
	  Generic (
	            N_WORDS           : POSITIVE range 4 to 512 := 4;
	            N_BITS_PER_WORD   : POSITIVE range 8 to 64  := 32
	  );
	  Port (
	        ----------------------CLK AND RESET PORTS------------------
	        clk     : in std_logic;
	        reset   : in std_logic;
	        -----------------------------------------------------------

	        start  : in std_logic; -- start signal from outside

	        ------------------------------Input data ports----------------------------------------
	        t_in   : in std_logic_vector (N_BITS_PER_WORD-1 downto 0); -- input word from mac_ab
	        nn0    : in std_logic_vector (N_BITS_PER_WORD-1 downto 0); -- input n'(0)
	        --------------------------------------------------------------------------------------

	        ----------------------------------Output data ports-----------------------------------
	        t_out : out std_logic_vector (N_BITS_PER_WORD-1 downto 0) := (Others =>'0');
	        m_out : out std_logic_vector (N_BITS_PER_WORD-1 downto 0) := (Others =>'0')
	        --------------------------------------------------------------------------------------

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

	signal dut_start  :  std_logic := '0'; -- start signal from outside

	------------------------------Input data ports----------------------------------------
	signal dut_t_in   :  std_logic_vector (DUT_N_BITS_PER_WORD-1 downto 0):= (Others =>'0'); -- input word from mac_ab
	signal dut_nn0    :  std_logic_vector (DUT_N_BITS_PER_WORD-1 downto 0):= (Others =>'0'); -- input n'(0)
	--------------------------------------------------------------------------------------

	----------------------------------Output data ports-----------------------------------
	signal dut_t_out :  std_logic_vector (DUT_N_BITS_PER_WORD-1 downto 0) := (Others =>'0');
	signal dut_m_out :  std_logic_vector (DUT_N_BITS_PER_WORD-1 downto 0) := (Others =>'0');
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
	mult_dut: FSM_mult
	Generic map(
								N_WORDS => DUT_N_WORDS,
								N_BITS_PER_WORD => DUT_N_BITS_PER_WORD
	)
	Port map (
							clk => clk,
							reset => reset,

							start => dut_start,

							t_in  => dut_t_in,
							nn0		=> dut_nn0,

							t_out => dut_t_out,
							m_out => dut_m_out

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


		-- Start

		

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
