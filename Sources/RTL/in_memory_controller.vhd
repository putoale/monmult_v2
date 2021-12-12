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
    WRITE_WIDTH : integer := 16; --write_width must be a multiple of read_width 
    READ_WIDTH : integer := 64;

    N_BITS_TOTAL : integer := 256
  );
  port (

    clk : in std_logic;
    reset : in std_logic;
    out_ready : out std_logic; -- stays at 1 as long as there are valid data on rd_port
    wr_en : in std_logic; --this comes from the outside e.g. the testbench
    wr_port : in std_logic_vector(WRITE_WIDTH - 1 downto 0);
    rd_port : out std_logic_vector(READ_WIDTH - 1 downto 0);
    EoC_in : in std_logic
  );
end in_mem_controller;

architecture Behavioral of in_mem_controller is
  ------------------------------------------------------------------------------
  constant MEMORY_DEPTH : integer := N_BITS_TOTAL / WRITE_WIDTH;
  --assuming here READ_WIDTH to be lower than WRITE_WIDTH, since this is an input memory
  constant READ_SLOTS : integer := N_BITS_TOTAL/READ_WIDTH;
  type memory_type is array (MEMORY_DEPTH - 1 downto 0) of std_logic_vector(WRITE_WIDTH - 1 downto 0);
  signal memory : memory_type;
  ------------------------------------------------------------------------------
  signal write_counter : integer range 0 to MEMORY_DEPTH - 1 := 0;
  signal read_counter : integer range 0 to MEMORY_DEPTH - 1 := 0;

  signal write_complete : std_logic;
  signal read_complete : std_logic;
  signal memory_full : std_logic := '0';
begin

  process (clk, reset, EoC_in)
    variable read_port_temp : std_logic_vector(READ_WIDTH - 1 downto 0) := (others => '0');
  begin

    if rising_edge(clk) then
      if reset = '1' or EoC_in = '1' then
        memory_full <= '0';
        memory <= (others => (others => '0'));
        write_counter <= 0;
        read_counter <= 0;
        write_complete <= '0';
        read_complete <= '0';
      else
        ------------------------------writing phase-------------------------------
        if wr_en = '1' and memory_full = '0' then
          write_counter <= read_counter + 1;
          if write_counter = MEMORY_DEPTH then
            write_counter <= 0;
            memory_full <= '1';
            write_complete <= '1';
          end if;
          memory(write_counter) <= wr_port;
        end if;

        --------------------------------------------------------------------------

        -----------------------reading phase--------------------------------------
        if memory_full = '1' and write_complete = '0' and read_complete = '0' then
          read_counter <= read_counter + READ_SLOTS;
          preparing_rd_port : for i in 0 to READ_SLOTS - 1 loop
            read_port_temp((READ_WIDTH - 1) * i downto READ_WIDTH * i) := memory(read_counter + i);
          end loop;
          rd_port <= read_port_temp;
          if read_counter = MEMORY_DEPTH then
            read_counter <= 0;
            read_complete <= '1';
          end if;

          --------------------------------------------------------------------------

        end if;
      end if;

    end if;
  end process;
end Behavioral;