
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

USE IEEE.NUMERIC_STD.ALL;
--!this module takes care of storing the entire input vector, and exposes the rigth word at the output at each cycle
--!this module will be istantiated three times:
--! * for the input a, which exposes one word per cycle
--! * for the input b, which expses one word every N_WORDS cycles
--! * for the input n, which exposes one word per cycle but with an initial delay

ENTITY input_mem_abn IS
    GENERIC (
        WRITE_WIDTH    : INTEGER                 := 8;
        READ_WIDTH     : INTEGER                 := 8; --!In this implementation, READ_WIDTH=WRITE_WIDTH
        CYLCES_TO_WAIT : INTEGER                 := 4; --!after the first word has been exposed, after how many cycles the next word will be exposed
        LATENCY        : INTEGER                 := 4; --!Initial time to wait after receving start_in before exposing the first word
        MEMORY_DEPTH   : INTEGER RANGE 4 TO 8192 := 16 --!in this implementation, is equal to TOT_BITS/WRITE_WIDTH
    );
    PORT (

        clk         : IN STD_LOGIC;
        reset       : IN STD_LOGIC;
        memory_full : OUT STD_LOGIC := '0'; --!unused in this implementation

        wr_en   : IN STD_LOGIC;                                                     --!has to be kept high while writing
        wr_port : IN STD_LOGIC_VECTOR(WRITE_WIDTH - 1 DOWNTO 0);                    --!accepts one word at a time, loaded by the testbench
        rd_en   : IN STD_LOGIC;                                                     --!has to be kept high while reading
        rd_port : OUT STD_LOGIC_VECTOR(READ_WIDTH - 1 DOWNTO 0) := (OTHERS => '0'); --!exposes one word at a time, at the right cycle
        start   : OUT STD_LOGIC                                 := '0';             --!used to notify start_regulator that reading phase is over

        ---add start latency
        start_in : IN STD_LOGIC; --!this notifies the memory that all memories are full and ready to start providing data
        EoC_in   : IN STD_LOGIC  --!End of Conversion input to notify the memory that the content of the memory can be reset on order to be ready for another computation
    );
END input_mem_abn;

ARCHITECTURE Behavioral OF input_mem_abn IS
    TYPE memory_type IS ARRAY (MEMORY_DEPTH - 1 DOWNTO 0) OF STD_LOGIC_VECTOR(READ_WIDTH - 1 DOWNTO 0);
    SIGNAL memory : memory_type;

    SIGNAL write_counter   : INTEGER RANGE 0 TO MEMORY_DEPTH := 0;   --! counts the times a writing in the memory is done, does only one full cycle
    SIGNAL read_counter    : INTEGER RANGE 0 TO MEMORY_DEPTH := 0;   --! counts the times a reading from the memory is done, does as many full cycles as necessary
    SIGNAL memory_full_int : STD_LOGIC                       := '0'; --!used to tell if reading phase can start
    SIGNAL cycle_counter   : INTEGER                         := 0;   --!counts the cycle between one reading and the next(i.e 1 for a, N_WORDS for b)
    SIGNAL initial_counter : INTEGER                         := 0;   --!counts the cycle to wait before the beginning of the reading phase
    SIGNAL begin_reading   : STD_LOGIC                       := '0'; --!flag, to 1 when writing phase is finished
    SIGNAL start_flag      : STD_LOGIC                       := '0'; --! used to manage the start signal, which may be high  for one or more cycles
    SIGNAL start_int       : STD_LOGIC                       := '0'; --! used to manage the start signal, which may be high  for one or more cycles
BEGIN
    memory_full <= memory_full_int;
    start       <= start_int;
    start_int   <= memory_full_int;
    PROCESS (clk, reset, EoC_in)
    BEGIN

        IF rising_edge(clk) THEN
            ---------------------RESET-----------------------------------
            IF reset = '1' OR EoC_in = '1' THEN
                --resetting the memory means interrupting any reading or writing in
                --process and erasing the content of the memory: it is done on an
                --external signal and when the computation is finished, in order to
                --be ready for the next one
                memory_full_int <= '0';
                memory          <= (OTHERS => (OTHERS => '0'));
                begin_reading   <= '0';
                write_counter   <= 0;
                read_counter    <= 0;
                cycle_counter   <= 0;
                initial_counter <= 0;
                start_flag      <= '0';
                --------------------------------------------------------------------------
            ELSE

                IF start_in = '1' THEN
                    start_flag <= '1';
                END IF;
                ---------------INITIAL WAITING TIME------------------------------
                IF begin_reading = '0' AND (start_in = '1' OR start_flag = '1') THEN
                    initial_counter <= initial_counter + 1;
                    IF initial_counter = LATENCY - 1 THEN
                        begin_reading   <= '1';
                        initial_counter <= 0;
                    END IF;
                END IF;
                ----------------------------------------------------------------

                ----------------WRITE PROCESS---------------------------------
                --in this implementation, the memory is completely written BEFORE it can be read
                IF wr_en = '1' AND memory_full_int = '0' THEN
                    memory(write_counter) <= wr_port;
                    write_counter         <= write_counter + 1;
                    IF write_counter = MEMORY_DEPTH - 1 THEN
                        write_counter   <= 0;
                        memory_full_int <= '1';
                    ELSE
                        memory_full_int <= '0';
                    END IF;
                END IF;
                ----------------------------------------------------------------

                ----------------READ PROCESS---------------------------------
                --this process takes care of exposing the right word at the right cycle
                IF rd_en = '1' AND memory_full_int = '1' AND begin_reading = '1' THEN
                    cycle_counter <= cycle_counter + 1;
                    rd_port       <= memory(read_counter);
                    IF cycle_counter = CYLCES_TO_WAIT - 1 THEN
                        cycle_counter <= 0;
                        read_counter  <= read_counter + 1;
                        IF read_counter = MEMORY_DEPTH - 1 THEN
                            read_counter <= 0;
                        END IF;
                    END IF;
                    ----------------------------------------------------------------
                END IF;
            END IF;

        END IF;
    END PROCESS;
END Behavioral;