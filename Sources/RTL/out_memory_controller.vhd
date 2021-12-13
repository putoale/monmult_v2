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

  use IEEE.NUMERIC_STD.all;


entity out_mem_controller is
  generic (
    write_width : integer := 64;
    read_width  : integer := 16;  --write_width must be a multiple of read_width. since this is an output controller

    n_bits_total : integer := 256
  );
  port (
    clk       : in    std_logic;
    reset     : in    std_logic;
    out_valid : out   std_logic; -- stays at 1 as long as there are valid data on rd_port (connects to the valid of monmult_module)
    wr_en     : in    std_logic; -- this is the valid of the sub
    wr_port   : in    std_logic_vector(write_width - 1 downto 0);
    rd_port   : out   std_logic_vector(read_width - 1 downto 0);
    EoC_out   : out std_logic;  --rises with the last word on the rd_port
    eoc_in    : in    std_logic
  );
end entity out_mem_controller;

architecture behavioral of out_mem_controller is

  ------------------------------------------------------------------------------
  constant memory_depth : integer := n_bits_total / read_width;
  --assuming here read_width to be lower than write_width, since this is an input memory
  constant n_write_slots : integer := n_bits_total / write_width; --memory is divided into NREADSLOTS slots
  constant write_bigness : integer := write_width / read_width;  --a writing slots correponds to writebigness single memory slots

  type memory_type is array (memory_depth - 1 downto 0) of std_logic_vector(read_width - 1 downto 0);

  signal memory : memory_type;
  ------------------------------------------------------------------------------
  signal write_counter : integer range 0 to memory_depth - 1 := 0;
  signal read_counter  : integer range 0 to memory_depth - 1 := 0;

  signal write_complete : std_logic;
  signal read_complete  : std_logic;
  signal memory_full    : std_logic := '0';
  signal EoC_reg        : std_logic;
begin

  process (clk, reset, EoC_in) is

    variable memory_temp : std_logic_vector(write_width - 1 downto 0) := (others => '0');

  begin

    if clk'event and clk = '1' then
      EoC_reg<=EoC_in;
      if (reset = '1' or EoC_reg = '1' or read_complete= '1') then
        memory_full    <= '0';
        memory         <= (others => (others => '0'));
        write_counter  <= 0;
        read_counter   <= 0;
        write_complete <= '0';
        read_complete  <= '0';
      else
      out_valid<='0'; --unless overriden later
      EoC_out<='0';
      -----------------------reading phase--------------------------------------
        if (memory_full = '1' and read_complete = '0' and write_complete= '1')  then

        if read_counter >= memory_depth then
    		read_counter<=0;
        	read_complete<='1';
        	EoC_out<='1';
		else
		  rd_port<=memory(read_counter);
          read_counter<=read_counter+1;
          out_valid<='1';

        end if;
	end if;
          --------------------------------------------------------------------------

             ------------------------------writing phase-------------------------------
        if (wr_en = '1' and memory_full = '0') then

            write_counter <= write_counter + write_bigness;
              preparing_wr : for i in 0 to write_bigness - 1 loop
                --memory(write_counter +write_bigness -1 - i)<= wr_port(read_width  * (i + 1) - 1  downto read_width * i);
				memory(write_counter + i)<= wr_port(read_width  * (i + 1) - 1  downto read_width * i);
            end loop;
    	end if;
	    --------------------------------------------------------------------------
        end if;
		  if (write_counter >= memory_depth) then
		    write_counter  <= 0;
		    write_complete <= '1';
		    memory_full<='1';
		  end if;
    end if;

  end process;

end architecture behavioral;
