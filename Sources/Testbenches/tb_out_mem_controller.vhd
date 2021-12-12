library IEEE;
  use IEEE.STD_LOGIC_1164.all;

  -- Uncomment the following library declaration if using
  -- arithmetic functions with Signed or Unsigned values
  use IEEE.NUMERIC_STD.all;

entity tb_out_mem_controller is
end entity tb_out_mem_controller;

architecture behavioral of tb_out_mem_controller is

  component out_mem_controller is
    generic (
      write_width : integer := 16;
      read_width  : integer := 64;

      n_bits_total : integer := 256
    );
    port (
      clk       : in    std_logic;
      reset     : in    std_logic;
      out_valid : out   std_logic;
      wr_en     : in    std_logic;
      wr_port   : in    std_logic_vector(write_width - 1 downto 0);
      rd_port   : out   std_logic_vector(read_width - 1 downto 0);
      eoc_out   : out std_logic;
      eoc_in    : in    std_logic
    );
  end component;
  -------------------------------input_memory_case---------------------------
  constant write_width  : integer := 16;
  constant read_width   : integer := 8;
  constant n_bits_total : integer := 64;
  constant memory_depth : integer :=n_bits_total / write_width;
  ---------------------------------------------------------------------------


  constant clk_period : time :=10 ns;
  signal   clk        : std_logic:='0';
  signal   reset      : std_logic;
  signal   out_valid  : std_logic;
  signal   wr_en      : std_logic;
  signal   wr_port    : std_logic_vector(write_width - 1 downto 0);
  signal   rd_port    : std_logic_vector(read_width - 1 downto 0);
  signal eoc_out: std_logic;
  signal eoc_in : std_logic;

  type in_vector_type is array (memory_depth - 1 downto 0) of std_logic_vector(write_width - 1 downto 0);


  signal in_vector     : std_logic_vector(n_bits_total - 1 downto 0);
  signal in_vector_one : std_logic_vector(n_bits_total / 2 - 1 downto 0);
  signal in_vector_two : std_logic_vector(n_bits_total / 2 - 1 downto 0);

  signal out_vector : std_logic_vector(n_bits_total - 1 downto 0);
  signal j: integer:=memory_depth-1;
begin

  --in_vector_one <= std_logic_vector(to_unsigned(x"11223344", n_bits_total / 2));
  --in_vector_two <= std_logic_vector(to_unsigned(x"55667788", n_bits_total / 2));
  in_vector_one<=x"01234567";
  in_vector_two<=x"89abcdef";
  in_vector <= in_vector_one & in_vector_two;

  inst : component out_mem_controller
    generic map (
      write_width  => write_width,
      read_width   => read_width,
      n_bits_total => n_bits_total
    )
    port map (
      clk       => clk,
      reset     => reset,
      out_valid => out_valid,
      wr_en     => wr_en,
      wr_port   => wr_port,
      rd_port   => rd_port,
      eoc_out =>eoc_out,
      eoc_in    => eoc_in
    );

  clk <= not clk after clk_period / 2;

  process is
  begin
	wr_en<='0';
    reset<= '1' ;
    wait for clk_period*3;
    reset<='0';

    EoC_in<='1';
    wait for clk_period*2;
    EoC_in <='0';
    wait for clk_period*2;
    wait until rising_edge(clk);

    for i in 0 to memory_depth-1  loop
      wr_en<='1';
      wr_port <= in_vector((write_width)*(i+1 )-1 downto i*write_width);
      wait until rising_edge(clk);
    end loop;

		wr_en<='0';
    if out_valid='1' then
      for i in 0 to memory_depth-1 loop
        out_vector((read_width)*(i+1 ) -1  downto i*read_width) <= rd_port ;
		wait for clk_period;
      end loop;
    end if;
    wait for clk_period*10;
    wait;
        end process;

end architecture behavioral;
