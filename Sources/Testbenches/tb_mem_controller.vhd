library IEEE;
  use IEEE.STD_LOGIC_1164.all;

  -- Uncomment the following library declaration if using
  -- arithmetic functions with Signed or Unsigned values
  use IEEE.NUMERIC_STD.all;

entity tb_mem_controller is
end entity tb_mem_controller;

architecture behavioral of tb_mem_controller is

  component in_mem_controller is
    generic (
      write_width : integer := 16;
      read_width  : integer := 64;

      n_bits_total : integer := 256
    );
    port (
      clk       : in    std_logic;
      reset     : in    std_logic;
      out_ready : out   std_logic;
      wr_en     : in    std_logic;
      wr_port   : in    std_logic_vector(write_width - 1 downto 0);
      rd_port   : out   std_logic_vector(read_width - 1 downto 0);
      eoc_in    : in    std_logic
    );
  end component;

  constant write_width  : integer := 8;
  constant read_width   : integer := 16;
  constant n_bits_total : integer := 64;
  constant memory_depth : integer :=n_bits_total / write_width;

  constant clk_period : time :=10 ns;
  signal   clk        : std_logic;
  signal   reset      : std_logic;
  signal   out_ready  : std_logic;
  signal   wr_en      : std_logic;
  signal   wr_port    : std_logic_vector(write_width - 1 downto 0);
  signal   rd_port    : std_logic_vector(read_width - 1 downto 0);

  signal eoc_in : std_logic;

  type in_vector_type is array (memory_depth - 1 downto 0) of std_logic_vector(write_width - 1 downto 0);

  signal in_vector_columns : in_vector_type;

  signal in_vector     : std_logic_vector(n_bits_total - 1 downto 0);
  signal in_vector_one : std_logic_vector(n_bits_total / 2 - 1 downto 0);
  signal in_vector_two : std_logic_vector(n_bits_total / 2 - 1 downto 0);

  signal out_vector : std_logic_vector(n_bits_total - 1 downto 0);
  signal j: integer:=memory_depth-1;
begin

  --in_vector_one <= std_logic_vector(to_unsigned(x"11223344", n_bits_total / 2));
  --in_vector_two <= std_logic_vector(to_unsigned(x"55667788", n_bits_total / 2));
  in_vector_one<=x"11223344";
  in_vector_two<=x"33445566";
  in_vector <= in_vector_two & in_vector_one;

  inst : component in_mem_controller
    generic map (
      write_width  => write_width,
      read_width   => read_width,
      n_bits_total => n_bits_total
    )
    port map (
      clk       => clk,
      reset     => reset,
      out_ready => out_ready,
      wr_en     => wr_en,
      wr_port   => wr_port,
      rd_port   => rd_port,
      eoc_in    => eoc_in
    );

  clk <= not clk after clk_period / 2;

  process is
  begin
    reset<= '1' ;
    wait for clk_period*10;
    reset<='0';
    wr_en<='0';
    
    
    for i in 0 to memory_depth-1  loop 
      wr_en<='1';
      j<= memory_depth -1 - i;
      wr_port <= in_vector((write_width-1)*(i+1 ) downto i*write_width);
      end loop;
    wait;

    if out_ready='1' then  
      for i in 0 to memory_depth-1 then  
        out_vector<= rd_port
      end loop;
  
        end process;

end architecture behavioral;
