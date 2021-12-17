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
  constant DUT_N_BITS_PER_WORD : integer := 8;  --refers to the interface with the tb
  constant DUT_N_WORDS : integer := 8;
  constant DUT_N_BITS_TOTAL: integer := 64;

  constant DUT_INTERNAL_WIDTH : integer := 16 ;
  constant DUT_EXTERNAL_WIDTH : integer := DUT_N_BITS_PER_WORD;
  constant DUT_MEMORY_DEPTH : integer := DUT_N_BITS_TOTAL/DUT_INTERNAL_WIDTH; --goes to input_mem_abn
  constant DUT_EXTERNAL_MEMORY_DEPTH: integer := DUT_N_BITS_TOTAL/DUT_EXTERNAL_WIDTH;
  --File GENERICS
  constant N_TEST_VECTORS   : positive := 11;
  constant INPUT_FILE_NAME  : string := "input_vectors_64_8_8.txt";
  constant OUTPUT_FILE_NAME : string := "out_results.txt";

  --Types
    --array of N_WORDS to store an operand (e.g. to store "a")
  type test_vector_input_type is array (DUT_EXTERNAL_MEMORY_DEPTH-1 downto 0) of std_logic_vector(DUT_N_BITS_PER_WORD-1 downto 0);

    -- type to store all the values of a N_WORDS operand to test (e.g. all test vectors for "a","b",or "n")
  type test_vector_Nw_array is array(0 to N_TEST_VECTORS-1) of test_vector_input_type;

    -- type to store all the values of nn0 to test
  type test_vector_1w_array is array(0 to N_TEST_VECTORS-1) of std_logic_vector(DUT_N_BITS_PER_WORD-1 downto 0);

    -- type to store result of one monmult
  type output_result_array is array (DUT_EXTERNAL_MEMORY_DEPTH-1 downto 0) of std_logic_vector(DUT_N_BITS_PER_WORD-1 downto 0);

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

    -- memory with all test vectors of "nn0" operand
  signal nn0_memory : test_vector_1w_array := (Others => (Others=>'0'));

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

----------File Read Process----------

file_proc : process

--file        input_file            : text open read_mode is "input_vectors_256_4_64.txt";
file        input_file            : text open read_mode is INPUT_FILE_NAME;
variable    input_line            : line;
variable    slv_a_var             : std_logic_vector(DUT_N_BITS_PER_WORD-1 downto 0) := (Others =>'0');
variable    slv_b_var             : std_logic_vector(DUT_N_BITS_PER_WORD-1 downto 0) := (Others =>'0');
variable    slv_n_var             : std_logic_vector(DUT_N_BITS_PER_WORD-1 downto 0) := (Others =>'0');
variable    slv_nn0_var           : std_logic_vector(DUT_N_BITS_PER_WORD-1 downto 0) := (Others =>'0');
variable    good_v                : boolean;
begin

  while not endfile(input_file) loop

    for tv_counter in 0 to N_TEST_VECTORS-1 loop

      readline(input_file,input_line);

      for word_counter in DUT_N_WORDS-1 downto 0 loop

        --read one word of "a" and put it into memory
        hread(input_line,slv_a_var,good_v);
        a_memory(tv_counter)(word_counter) <= slv_a_var;

      end loop;

      for word_counter in DUT_N_WORDS-1 downto 0 loop

        --read one word of "b" and put it into memory
        hread(input_line,slv_b_var,good_v);
        b_memory(tv_counter)(word_counter) <= slv_b_var;

      end loop;

      for word_counter in DUT_N_WORDS-1 downto 0 loop

        --read one word of "n" and put it into memory
        hread(input_line,slv_n_var,good_v);
        n_memory(tv_counter)(word_counter) <= slv_n_var;

      end loop;

        --read "nn0" and put it into memory
        hread(input_line,slv_nn0_var,good_v);
        nn0_memory(tv_counter) <= slv_nn0_var;

    end loop;


  end loop;
  file_read_complete <= true;
  wait;

end process;

-------------------------------------

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
    dut_nn0 <= nn0_memory(tv_counter);

    for words_counter in 0 to DUT_N_WORDS-1 loop

      dut_a <= a_memory(tv_counter)(words_counter);
      dut_b <= b_memory(tv_counter)(words_counter);
      dut_n <= n_memory(tv_counter)(words_counter);
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

  for word_counter in 0 to DUT_N_WORDS-1 loop

    wait until rising_edge(clk);

    res_memory (word_counter) <= dut_result;



  end loop;

end process;




----------------------------------------------------------------

--------------------- output file write process------------------
file_write_proc: process

--file      output_file : text open write_mode is "output_results.txt";
file      output_file : text open write_mode is OUTPUT_FILE_NAME;
variable  output_line : line;

begin

    wait until dut_EoC = '1';

      wait until rising_edge(clk);

      for word_counter in DUT_N_WORDS-1 downto 0 loop

        wait until rising_edge(clk);


        hwrite(output_line, res_memory(word_counter) ,left, (DUT_N_BITS_PER_WORD/4)+1);

      end loop;

      writeline(output_file, output_line);
      writeline_complete <= true;
      wait until rising_edge(clk);
      writeline_complete <= false;

end process;
-----------------------------------------------------------------



end;
