----------------------------------------------------------------------------------
-- Company:
-- Engineer:
--
-- Create Date: 11/21/2021 07:09:07 PM
-- Design Name:
-- Module Name: input_mem - Behavioral
-- Project Name:
-- Target Devices:
-- Tool Versions:
-- Description:
--
-- Dependencies:
--
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
----------------------------------------------------------------------------------

library IEEE;
  use IEEE.STD_LOGIC_1164.all;

  -- Uncomment the following library declaration if using
  -- arithmetic functions with Signed or Unsigned values
  use IEEE.NUMERIC_STD.all;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity in_mem_controller is
  generic (
    write_width : integer := 16; --read_width must be a multiple of write_width. since this is an input controller
    read_width  : integer := 64;

    n_bits_total : integer := 256
  );
  port (
    clk       : in    std_logic;
    reset     : in    std_logic;
    out_valid : out   std_logic; -- stays at 1 as long as there are valid data on rd_port
    wr_en     : in    std_logic; --this comes from the outside e.g. the testbench
    wr_port   : in    std_logic_vector(write_width - 1 downto 0);
    rd_port   : out   std_logic_vector(read_width - 1 downto 0);
    eoc_in    : in    std_logic
  );
end entity in_mem_controller;

architecture behavioral of in_mem_controller is

  ------------------------------------------------------------------------------
  constant memory_depth : integer := n_bits_total / write_width;
  --assuming here WRITE_WIDTH to be lower than READ_WIDTH, since this is an input memory
  constant n_read_slots : integer := n_bits_total / read_width; --memory is divided into NREADSLOTS slots
  constant read_bigness : integer := read_width / write_width;  --a reading slots correponds to READBIGNESS single memory slots

  type memory_type is array (memory_depth - 1 downto 0) of std_logic_vector(write_width - 1 downto 0);

  signal memory : memory_type;
  ------------------------------------------------------------------------------
  signal write_counter : integer range 0 to memory_depth - 1 := 0;
  signal read_counter  : integer range 0 to memory_depth - 1 := 0;

  signal write_complete : std_logic;
  signal read_complete  : std_logic;
  signal memory_full    : std_logic := '0';

begin

  process (clk, reset, EoC_in) is

    variable read_port_temp : std_logic_vector(read_width - 1 downto 0) := (others => '0');

  begin

    if clk'event and clk = '1' then
      
      if (reset = '1' or EoC_in = '1' or read_complete= '1') then
        memory_full    <= '0';
        memory         <= (others => (others => '0'));
        write_counter  <= 0;
        read_counter   <= 0;
        write_complete <= '0';
        read_complete  <= '0';
      else
       out_valid<='0'; --unless overridden later
        ------------------------------writing phase-------------------------------
        if (wr_en = '1' and memory_full = '0') then
          write_counter         <= write_counter + 1;
          memory(write_counter) <= wr_port;
          if (write_counter >= memory_depth - 1) then
            write_counter  <= 0;
            memory_full    <= '1';
            write_complete <= '1';
          end if;
        end if;

        --------------------------------------------------------------------------

        -----------------------reading phase--------------------------------------
        if (memory_full = '1' and read_complete = '0') then  
          out_valid<='1';
          if (read_counter >= memory_depth) then
            read_counter  <= 0;
            read_complete <= '1';
          
          else 
            read_counter <= read_counter + read_bigness;
            
              preparing_rd_port : for i in 0 to read_bigness - 1 loop
          
              read_port_temp((write_width ) * (i + 1) - 1  downto write_width * i) := memory(read_counter +read_bigness -1 - i);
            end loop;
            rd_port      <= read_port_temp;
            
          end if;

          --------------------------------------------------------------------------
          end if;

          end if;
      end if;

  end process;

end architecture behavioral;
