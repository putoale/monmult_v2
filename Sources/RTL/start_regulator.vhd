
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
--!takes as input the start output of the memories, and feeds to the modules and the memories a start signal, and it is useful if the memories are not filled at the same time
--!
ENTITY start_regulator IS

    PORT (
        clk              : IN STD_LOGIC;
        reset            : IN STD_LOGIC;
        in_1             : IN STD_LOGIC;         --! outputs of the memories, goes high when memory full, can be one cycle or more cycle long
        in_2             : IN STD_LOGIC;         --! outputs of the memories, goes high when memory full, can be one cycle or more cycle long
        in_3             : IN STD_LOGIC;         --! outputs of the memories, goes high when memory full, can be one cycle or more cycle long
        in_4             : IN STD_LOGIC;         --! outputs of the memories, goes high when memory full, can be one cycle or more cycle long
        EoC              : IN STD_LOGIC;         --!End of Conversion, resets the module when computation is over
        output_start     : OUT STD_LOGIC := '0'; --! notifies the memories that the can start exposing on the rd_port
        output_start_reg : OUT STD_LOGIC := '0'  --! notifies the computation modules that they can start reading
    );
END start_regulator;

ARCHITECTURE Behavioral OF start_regulator IS

    SIGNAL flag_1 : STD_LOGIC := '0'; --! flags to hold the value '1' of the input signal
    SIGNAL flag_2 : STD_LOGIC := '0'; --! flags to hold the value '1' of the input signal
    SIGNAL flag_3 : STD_LOGIC := '0'; --! flags to hold the value '1' of the input signal
    SIGNAL flag_4 : STD_LOGIC := '0'; --! flags to hold the value '1' of the input signal

    SIGNAL accept_1                 : STD_LOGIC := '1'; --! is '1' when the module has not yes stored a previous value '1'
    SIGNAL accept_2                 : STD_LOGIC := '1'; --! is '1' when the module has not yes stored a previous value '1'
    SIGNAL accept_3                 : STD_LOGIC := '1'; --! is '1' when the module has not yes stored a previous value '1'
    SIGNAL accept_4                 : STD_LOGIC := '1'; --! is '1' when the module has not yes stored a previous value '1'
    SIGNAL output_start_int         : STD_LOGIC := '0'; --! replica of output_start, needed in order for the output port to be readable
    SIGNAL output_start_reg_int     : STD_LOGIC := '0'; --! replica of output_start delayed by one cylce
    SIGNAL output_start_reg_reg_int : STD_LOGIC := '0'; --! replica of output_start delayed by two cylces
BEGIN
    output_start     <= output_start_int;
    output_start_reg <= output_start_reg_reg_int;
    PROCESS (clk, reset)
    BEGIN
        IF rising_edge(clk) THEN
            output_start_int         <= '0';
            output_start_reg_int     <= output_start_int;
            output_start_reg_reg_int <= output_start_reg_int;
            IF reset = '1' OR EoC = '1' THEN
                flag_1               <= '0';
                flag_2               <= '0';
                flag_3               <= '0';
                flag_4               <= '0';
                accept_1             <= '1';
                accept_2             <= '1';
                accept_3             <= '1';
                accept_4             <= '1';
                output_start_int     <= '0';
                output_start_reg_int <= '0';
            END IF;
            IF in_1 = '1' AND accept_1 = '1' THEN
                flag_1 <= '1';

            END IF;
            IF in_2 = '1'AND accept_2 = '1' THEN
                flag_2 <= '1';

            END IF;
            IF in_3 = '1'AND accept_3 = '1' THEN
                flag_3 <= '1';

            END IF;
            IF in_4 = '1'AND accept_4 = '1' THEN
                flag_4 <= '1';

            END IF;
            IF flag_1 = '1' AND flag_2 = '1' AND flag_3 = '1' AND flag_4 = '1' AND output_start_reg_int <= '0' THEN
                output_start_int                                                                            <= '1';
                flag_1                                                                                      <= '0';
                flag_2                                                                                      <= '0';
                flag_3                                                                                      <= '0';
                flag_4                                                                                      <= '0';
                accept_1                                                                                    <= '0';
                accept_2                                                                                    <= '0';
                accept_3                                                                                    <= '0';
                accept_4                                                                                    <= '0';
            END IF;
        END IF;
    END PROCESS;

END Behavioral;