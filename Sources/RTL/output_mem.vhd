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

ENTITY output_mem IS
    GENERIC (
        WRITE_WIDTH    : INTEGER := 8;
        READ_WIDTH     : INTEGER := 8; --assuming READ_WIDTH=WRITE_WIDT, for now
        CYLCES_TO_WAIT : INTEGER := 4; --goes from 1 for a to and entire N_WORDS for b
        LATENCY        : INTEGER := 4; --goes from 1 to what needed

        MEMORY_DEPTH : INTEGER := 16
    );
    PORT (

        clk   : IN STD_LOGIC;
        reset : IN STD_LOGIC;

        wr_en   : IN STD_LOGIC;
        wr_port : IN STD_LOGIC_VECTOR(WRITE_WIDTH - 1 DOWNTO 0);
        rd_en   : IN STD_LOGIC;
        rd_port : OUT STD_LOGIC_VECTOR(READ_WIDTH - 1 DOWNTO 0)
    );
END output_mem;

ARCHITECTURE Behavioral OF output_mem IS
    TYPE memory_type IS ARRAY (MEMORY_DEPTH - 1 DOWNTO 0) OF STD_LOGIC_VECTOR(READ_WIDTH - 1 DOWNTO 0);
    SIGNAL memory : memory_type;

    SIGNAL write_counter   : INTEGER RANGE 0 TO MEMORY_DEPTH := 0;
    SIGNAL read_counter    : INTEGER RANGE 0 TO MEMORY_DEPTH := 0;
    SIGNAL memory_full     : STD_LOGIC                       := '0';
    SIGNAL memory_empty    : STD_LOGIC;
    SIGNAL cycle_counter   : INTEGER   := 0;
    SIGNAL initial_counter : INTEGER   := 0;
    SIGNAL begin_reading   : STD_LOGIC := '0';
BEGIN

    PROCESS (clk)
    BEGIN
        IF reset = '1' THEN
            memory_full   <= '0';
            memory        <= (OTHERS => (OTHERS => '0'));
            begin_reading <= '0';
            write_counter <= 0;
            read_counter  <= 0;
        ELSIF rising_edge(clk) THEN
            IF wr_en = '1' AND memory_full = '0' THEN
                memory(write_counter) <= wr_port;
                write_counter         <= write_counter + 1;
                IF write_counter = MEMORY_DEPTH - 1 THEN
                    write_counter <= 0;
                    memory_full   <= '1';
                END IF;
            END IF;

            IF rd_en = '1' AND memory_full = '1' AND begin_reading = '1' THEN
                cycle_counter <= cycle_counter + 1;
                IF cycle_counter = CYLCES_TO_WAIT - 1 THEN
                    cycle_counter <= 0;
                    rd_port       <= memory(read_counter);
                    read_counter  <= read_counter + 1;
                    IF read_counter = MEMORY_DEPTH - 1 THEN
                        read_counter <= 0;
                    END IF;
                END IF;

            END IF;
        END IF;
    END PROCESS;
END Behavioral;