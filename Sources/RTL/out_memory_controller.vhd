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

USE IEEE.NUMERIC_STD.ALL;
ENTITY out_mem_controller IS
    GENERIC (
        write_width : INTEGER := 64;
        read_width  : INTEGER := 16; --write_width must be a multiple of read_width. since this is an output controller

        n_bits_total : INTEGER := 256
    );
    PORT (
        clk       : IN STD_LOGIC;
        reset     : IN STD_LOGIC;
        out_valid : OUT STD_LOGIC; -- stays at 1 as long as there are valid data on rd_port (connects to the valid of monmult_module)
        wr_en     : IN STD_LOGIC; -- this is the valid of the sub
        wr_port   : IN STD_LOGIC_VECTOR(write_width - 1 DOWNTO 0);
        rd_port   : OUT STD_LOGIC_VECTOR(read_width - 1 DOWNTO 0);
        EoC_out   : OUT STD_LOGIC; --rises with the last word on the rd_port
        eoc_in    : IN STD_LOGIC
    );
END ENTITY out_mem_controller;

ARCHITECTURE behavioral OF out_mem_controller IS

    ------------------------------------------------------------------------------
    CONSTANT memory_depth : INTEGER := n_bits_total / read_width;
    --assuming here read_width to be lower than write_width, since this is an input memory
    CONSTANT n_write_slots : INTEGER := n_bits_total / write_width; --memory is divided into NREADSLOTS slots
    CONSTANT write_bigness : INTEGER := write_width / read_width; --a writing slots correponds to writebigness single memory slots

    TYPE memory_type IS ARRAY (memory_depth - 1 DOWNTO 0) OF STD_LOGIC_VECTOR(read_width - 1 DOWNTO 0);

    SIGNAL memory : memory_type;
    ------------------------------------------------------------------------------
    SIGNAL write_counter : INTEGER RANGE 0 TO memory_depth - 1 := 0;
    SIGNAL read_counter  : INTEGER RANGE 0 TO memory_depth - 1 := 0;

    SIGNAL write_complete : STD_LOGIC;
    SIGNAL read_complete  : STD_LOGIC;
    SIGNAL memory_full    : STD_LOGIC := '0';
    SIGNAL EoC_reg        : STD_LOGIC;
BEGIN

    PROCESS (clk, reset, EoC_in) IS

        VARIABLE memory_temp : STD_LOGIC_VECTOR(write_width - 1 DOWNTO 0) := (OTHERS => '0');

    BEGIN

        IF clk'event AND clk = '1' THEN
            EoC_reg <= EoC_in;
            IF (reset = '1' OR EoC_reg = '1' OR read_complete = '1') THEN
                memory_full    <= '0';
                memory         <= (OTHERS => (OTHERS => '0'));
                write_counter  <= 0;
                read_counter   <= 0;
                write_complete <= '0';
                read_complete  <= '0';
            ELSE
                out_valid <= '0'; --unless overriden later
                EoC_out   <= '0';
                -----------------------reading phase--------------------------------------
                IF (memory_full = '1' AND read_complete = '0' AND write_complete = '1') THEN

                    IF read_counter >= memory_depth THEN
                        read_counter  <= 0;
                        read_complete <= '1';
                        EoC_out       <= '1';
                    ELSE
                        rd_port      <= memory(read_counter);
                        read_counter <= read_counter + 1;
                        out_valid    <= '1';

                    END IF;
                END IF;
                --------------------------------------------------------------------------

                ------------------------------writing phase-------------------------------
                IF (wr_en = '1' AND memory_full = '0') THEN

                    write_counter <= write_counter + write_bigness;
                    preparing_wr : FOR i IN 0 TO write_bigness - 1 LOOP
                        --memory(write_counter +write_bigness -1 - i)<= wr_port(read_width  * (i + 1) - 1  downto read_width * i);
                        memory(write_counter + i) <= wr_port(read_width * (i + 1) - 1 DOWNTO read_width * i);
                    END LOOP;
                END IF;
                --------------------------------------------------------------------------
            END IF;
            IF (write_counter >= memory_depth) THEN
                write_counter  <= 0;
                write_complete <= '1';
                memory_full    <= '1';
            END IF;
        END IF;

    END PROCESS;

END ARCHITECTURE behavioral;