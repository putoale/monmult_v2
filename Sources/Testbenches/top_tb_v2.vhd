library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
--	use IEEE.MATH_REAL.all;
  use STD.textio.all;
  use ieee.std_logic_textio.all;

entity top_tb_v2 is
end;

architecture bench of top_tb_v2 is

  component monmult_module_v2
    generic (
      INTERNAL_WIDTH : integer;
      EXTERNAL_WIDTH : integer;
      N_BITS_PER_WORD : integer;
      N_WORDS : integer;
     -- MEMORY_DEPTH : integer;
	  N_BITS_TOTAL: integer
    );
      port (
      clk : in std_logic;
      reset : in std_logic;

      wr_en_a : in std_logic;
      wr_en_b : in std_logic;

      wr_en_n_mac : in std_logic;
      wr_en_n_sub : in std_logic;
	  wr_en_nn0	: in std_logic;
      a : in std_logic_vector(EXTERNAL_WIDTH-1 downto 0);

      b : in std_logic_vector(EXTERNAL_WIDTH-1 downto 0);

      n : in std_logic_vector(EXTERNAL_WIDTH-1 downto 0);

      nn0 : in std_logic_vector(EXTERNAL_WIDTH-1 downto 0);

      EoC : out std_logic;

      valid_out : out std_logic := '0';

      result : out std_logic_vector(EXTERNAL_WIDTH-1 downto 0)
    );
  end component;

  -- Clock period
  constant CLK_PERIOD : time  := 1 ns; --edited to try many test vectors
  constant RESET_WND	:	TIME	:= 10*CLK_PERIOD;

  -- TB Initialiazations
	constant	TB_CLK_INIT		:	STD_LOGIC	:= '0';
	constant	TB_RESET_INIT 	:	STD_LOGIC	:= '1';

  -- Generics
  constant DUT_N_BITS_PER_WORD : integer := 64;  --refers to the interface with the tb
  constant DUT_N_WORDS : integer := 4;
  constant DUT_N_BITS_TOTAL: integer := 256;

  constant DUT_INTERNAL_WIDTH : integer := 32;
  constant DUT_EXTERNAL_WIDTH : integer := 64;
  constant DUT_MEMORY_DEPTH : integer := DUT_N_BITS_TOTAL/DUT_INTERNAL_WIDTH; --goes to input_mem_abn
  constant DUT_EXTERNAL_MEMORY_DEPTH: integer := DUT_N_BITS_TOTAL/DUT_EXTERNAL_WIDTH;
  --File GENERICS
  constant N_TEST_VECTORS   : positive := 1;
  --constant INPUT_FILE_NAME  : string := "input_vectors_64_8_8.txt";
  --constant OUTPUT_FILE_NAME : string := "out_results.txt";

  --Types
    --array of N_WORDS to store an operand (e.g. to store "a")
  type test_vector_input_type is array (DUT_EXTERNAL_MEMORY_DEPTH-1 downto 0) of std_logic_vector(DUT_EXTERNAL_WIDTH-1 downto 0);

    -- type to store all the values of a N_WORDS operand to test (e.g. all test vectors for "a","b",or "n")
  type test_vector_Nw_array is array(0 to N_TEST_VECTORS-1) of test_vector_input_type;

  type test_vector_1_nn0_array is array (DUT_INTERNAL_WIDTH/DUT_EXTERNAL_WIDTH -1 downto 0) of std_logic_vector(DUT_EXTERNAL_WIDTH-1 downto 0);

    -- type to store all the values of nn0 to test
  type test_vector_N_nn0_array is array(0 to N_TEST_VECTORS-1) of test_vector_1_nn0_array;

    -- type to store result of one monmult
  type output_result_array is array (DUT_EXTERNAL_MEMORY_DEPTH-1 downto 0) of std_logic_vector(DUT_EXTERNAL_WIDTH-1 downto 0);

  -- Ports
  signal clk              : std_logic := TB_CLK_INIT;
  signal reset            : std_logic:= TB_RESET_INIT;
  signal dut_wr_en_a      : std_logic:='0';
  signal dut_wr_en_b      : std_logic:='0';
  signal dut_wr_en_n_mac  : std_logic:='0';
  signal dut_wr_en_n_sub  : std_logic:='0';
  signal dut_wr_en_nn0    : std_logic:='0';
  signal dut_a            : std_logic_vector(DUT_N_BITS_PER_WORD-1 downto 0):= (Others =>'0');
  signal dut_b            : std_logic_vector(DUT_N_BITS_PER_WORD-1 downto 0):= (Others =>'0');
  signal dut_n            : std_logic_vector(DUT_N_BITS_PER_WORD-1 downto 0):= (Others =>'0');
  signal dut_nn0          : std_logic_vector(DUT_N_BITS_PER_WORD-1 downto 0):= (Others =>'0');
  signal dut_EoC          : std_logic := '0';
  signal dut_valid_out    : std_logic := '0';
  signal dut_result       : std_logic_vector(DUT_N_BITS_PER_WORD-1 downto 0):= (Others =>'0');

  --Other signals
  signal file_read_complete : boolean := false;
  signal writeline_complete : boolean := false;

    -- memory with all test vectors of "a" operand
  signal a_memory   : test_vector_Nw_array := (Others =>(Others => (Others=>'0')));

    -- memory with all test vectors of "b" operand
  signal b_memory   : test_vector_Nw_array := (Others =>(Others => (Others=>'0')));

    -- memory with all test vectors of "n" operand
  signal n_memory   : test_vector_Nw_array := (Others =>(Others => (Others=>'0')));


  signal nn0_memory : test_vector_N_nn0_array := (Others => (Others => (Others=>'0')));

    -- memory for one test vector result
  signal res_memory : output_result_array := (Others => (Others => '0'));

begin

  monmult_module_inst : monmult_module_v2
    generic map (
      EXTERNAL_WIDTH => DUT_EXTERNAL_WIDTH,
      INTERNAL_WIDTH => DUT_INTERNAL_WIDTH,
      N_BITS_PER_WORD => DUT_N_BITS_PER_WORD,
      N_WORDS => DUT_N_WORDS,
      --MEMORY_DEPTH => dut_MEMORY_DEPTH,
	  N_BITS_TOTAL => dut_N_BITS_TOTAL
    )
    port map (
      clk => clk,
      reset => reset,
      wr_en_a => dut_wr_en_a,
      wr_en_b => dut_wr_en_b,
      wr_en_n_mac => dut_wr_en_n_mac,
      wr_en_n_sub => dut_wr_en_n_sub,
	  wr_en_nn0=> dut_wr_en_nn0,
	  a => dut_a,
      b => dut_b,
      n => dut_n,
      nn0 => dut_nn0,
      EoC => dut_EoC,
      valid_out => dut_valid_out,
      result => dut_result
    );

---------- clock -------------------
	clk <= not clk after  CLK_PERIOD/2;
------------------------------------

----- Reset Process --------
reset_wave : process
begin
  reset <= TB_RESET_INIT;
  wait for RESET_WND;

  reset <= not reset;
  wait until rising_edge(clk);

  wait;
  end process;
----------------------------


a_memory(0)(0) <= X"E41BE5BD";
a_memory(0)(1) <= X"E54EA01C";
a_memory(0)(2) <= X"5FD8132D";
a_memory(0)(3) <= X"AE3C50BD";
a_memory(0)(4) <= X"9F96C5AF";
a_memory(0)(5) <= X"1324A68D";
a_memory(0)(6) <= X"08D97804";
a_memory(0)(7) <= X"8F69BF76";

b_memory(0)(0) <= X"F9852CD2";
b_memory(0)(1) <= X"1DE6A57F";
b_memory(0)(2) <= X"70BA175B";
b_memory(0)(3) <= X"EA2FFFC2";
b_memory(0)(4) <= X"A40A26A7";
b_memory(0)(5) <= X"D424CF6F";
b_memory(0)(6) <= X"3CC8843F";
b_memory(0)(7) <= X"9135D1ED";

n_memory(0)(0) <= X"B6FB5F6D";
n_memory(0)(1) <= X"A48F54FC";
n_memory(0)(2) <= X"63AF7B4B";
n_memory(0)(3) <= X"3E9C3631";
n_memory(0)(4) <= X"CD781A52";
n_memory(0)(5) <= X"6FB464A6";
n_memory(0)(6) <= X"6BB3E127";
n_memory(0)(7) <= X"E74E2C25";

nn0_memory(0)(0) <= X"5A6EB41C";
nn0_memory(0)(1) <= X"91A1F053";

file_read_complete <= true;


-------- module feed process---------
data_feed_proc : process

begin

  wait for RESET_WND;
  wait until rising_edge(clk);

  if (file_read_complete = false) then

    wait until file_read_complete = true;
  end if;

  wait until rising_edge(clk);




  for tv_counter in 0 to N_TEST_VECTORS-1 loop

    dut_wr_en_a     <= '1';
    dut_wr_en_b     <= '1';
    dut_wr_en_n_mac <= '1';
    dut_wr_en_n_sub <= '1';
    dut_wr_en_nn0   <= '1';



    for words_counter in 0 to (DUT_N_WORDS * DUT_INTERNAL_WIDTH/DUT_EXTERNAL_WIDTH)-1 loop

      dut_a <= a_memory(tv_counter)(words_counter);
      dut_b <= b_memory(tv_counter)(words_counter);
      dut_n <= n_memory(tv_counter)(words_counter);

      if words_counter < DUT_INTERNAL_WIDTH/DUT_EXTERNAL_WIDTH then
        dut_nn0 <= nn0_memory(tv_counter)(words_counter);
      else
        dut_wr_en_nn0   <= '0';
      end if;

      wait until rising_edge(clk);
    end loop;

    dut_wr_en_a     <= '0';
    dut_wr_en_b     <= '0';
    dut_wr_en_n_mac <= '0';
    dut_wr_en_n_sub <= '0';

    wait until rising_edge(dut_EoC);
    wait until rising_edge(clk);

  end loop;
      wait;

end process;
-----------------------------------------------------------------

------------------ output memory write process------------------

out_res_mem_proc: process

begin

  wait until dut_valid_out = '1';

  for word_counter in 0 to (DUT_N_WORDS * DUT_INTERNAL_WIDTH/DUT_EXTERNAL_WIDTH)-1 loop

    wait until rising_edge(clk);

    res_memory (word_counter) <= dut_result;



  end loop;

end process;




----------------------------------------------------------------



end;
