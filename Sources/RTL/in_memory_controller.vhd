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

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
USE IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

ENTITY in_mem_controller IS
    GENERIC (
        write_width : INTEGER := 16; --read_width must be a multiple of write_width. since this is an input controller
        read_width  : INTEGER := 64;

        n_bits_total : INTEGER := 256
    );
    PORT (
        clk       : IN STD_LOGIC;
        reset     : IN STD_LOGIC;
        out_valid : OUT STD_LOGIC; -- stays at 1 as long as there are valid data on rd_port
        wr_en     : IN STD_LOGIC; --this comes from the outside e.g. the testbench
        wr_port   : IN STD_LOGIC_VECTOR(write_width - 1 DOWNTO 0);
        rd_port   : OUT STD_LOGIC_VECTOR(read_width - 1 DOWNTO 0);
        eoc_in    : IN STD_LOGIC
    );
END ENTITY in_mem_controller;

ARCHITECTURE behavioral OF in_mem_controller IS

    ------------------------------------------------------------------------------
    CONSTANT memory_depth : INTEGER := n_bits_total / write_width;
    --assuming here WRITE_WIDTH to be lower than READ_WIDTH, since this is an input memory
    CONSTANT n_read_slots : INTEGER := n_bits_total / read_width; --memory is divided into NREADSLOTS slots
    CONSTANT read_bigness : INTEGER := read_width / write_width; --a reading slots correponds to READBIGNESS single memory slots

    TYPE memory_type IS ARRAY (memory_depth - 1 DOWNTO 0) OF STD_LOGIC_VECTOR(write_width - 1 DOWNTO 0);

    SIGNAL memory : memory_type;
    ------------------------------------------------------------------------------
    SIGNAL write_counter : INTEGER RANGE 0 TO memory_depth - 1 := 0;
    SIGNAL read_counter  : INTEGER RANGE 0 TO memory_depth - 1 := 0;

    SIGNAL write_complete : STD_LOGIC;
    SIGNAL read_complete  : STD_LOGIC;
    SIGNAL memory_full    : STD_LOGIC := '0';

BEGIN

    PROCESS (clk, reset, EoC_in) IS

        VARIABLE read_port_temp : STD_LOGIC_VECTOR(read_width - 1 DOWNTO 0) := (OTHERS => '0');

    BEGIN

        IF clk'event AND clk = '1' THEN

            IF (reset = '1' OR EoC_in = '1' OR read_complete = '1') THEN
                memory_full    <= '0';
                memory         <= (OTHERS => (OTHERS => '0'));
                write_counter  <= 0;
                read_counter   <= 0;
                write_complete <= '0';
                read_complete  <= '0';
            ELSE
                out_valid <= '0'; --unless overridden later
                ------------------------------writing phase-------------------------------
                IF (wr_en = '1' AND memory_full = '0') THEN
                    write_counter         <= write_counter + 1;
                    memory(write_counter) <= wr_port;
                    IF (write_counter >= memory_depth - 1) THEN
                        write_counter  <= 0;
                        memory_full    <= '1';
                        write_complete <= '1';
                    END IF;
                END IF;

                --------------------------------------------------------------------------

                -----------------------reading phase--------------------------------------
                IF (memory_full = '1' AND read_complete = '0') THEN
                    out_valid <= '1';
                    IF (read_counter >= memory_depth) THEN
                        read_counter  <= 0;
                        read_complete <= '1';

                    ELSE
                        read_counter <= read_counter + read_bigness;

                        preparing_rd_port : FOR i IN 0 TO read_bigness - 1 LOOP

                            read_port_temp((write_width) * (i + 1) - 1 DOWNTO write_width * i) := memory(read_counter + read_bigness - 1 - i);
                        END LOOP;
                        rd_port <= read_port_temp;

                    END IF;

                    --------------------------------------------------------------------------
                END IF;

            END IF;
        END IF;

    END PROCESS;

END ARCHITECTURE behavioral;