
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
--! this shift register is put inside of mac_ab in order to buffer its t input
ENTITY sr IS
    GENERIC (
        SR_WIDTH : NATURAL  := 8;
        SR_DEPTH : POSITIVE := 4;
        SR_INIT  : INTEGER  := 0
    );
    PORT (

        ---------- Reset/Clock ----------
        reset : IN STD_LOGIC;
        clk   : IN STD_LOGIC;
        ---------------------------------

        ------------- Data --------------
        din  : IN STD_LOGIC_VECTOR(SR_WIDTH - 1 DOWNTO 0);
        dout : OUT STD_LOGIC_VECTOR(SR_WIDTH - 1 DOWNTO 0) := (OTHERS => '0')
        ---------------------------------

    );
END sr;

ARCHITECTURE Behavioral OF sr IS
    CONSTANT INIT_SLV : STD_LOGIC_VECTOR(SR_WIDTH - 1 DOWNTO 0) := STD_LOGIC_VECTOR(to_unsigned(SR_INIT, SR_WIDTH));

    TYPE MEM_ARRAY_TYPE IS ARRAY(0 TO SR_DEPTH - 1) OF STD_LOGIC_VECTOR(SR_WIDTH - 1 DOWNTO 0);
    SIGNAL mem : MEM_ARRAY_TYPE := (OTHERS => INIT_SLV);

BEGIN

    dout <= mem(SR_DEPTH - 1);

    shift_reg : PROCESS (reset, clk)
    BEGIN

        IF (reset = '1') THEN
            mem <= (OTHERS => INIT_SLV);

        ELSIF rising_edge(clk) THEN
            mem <= din & mem(0 TO SR_DEPTH - 2);

        END IF;

    END PROCESS;

END Behavioral;