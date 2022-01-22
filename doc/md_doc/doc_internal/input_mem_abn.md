# Entity: input_mem_abn 

- **File**: input_mem_abn.vhd
## Diagram

![Diagram](input_mem_abn.svg "Diagram")
## Description

this module takes care of storing the entire input vector, and exposes the rigth word at the output at each cycle
this module will be istantiated three times:
 * for the input a, which exposes one word per cycle
 * for the input b, which expses one word every N_WORDS cycles
 * for the input n, which exposes one word per cycle but with an initial delay
## Generics

| Generic name   | Type                    | Value | Description                                                                                |
| -------------- | ----------------------- | ----- | ------------------------------------------------------------------------------------------ |
| WRITE_WIDTH    | integer                 | 8     |                                                                                            |
| READ_WIDTH     | integer                 | 8     | In this implementation, READ_WIDTH=WRITE_WIDTH                                             |
| CYLCES_TO_WAIT | integer                 | 4     | after the first word has been exposed, after how many cycles the next word will be exposed |
| LATENCY        | integer                 | 4     | Initial time to wait after receving start_in before exposing the first word                |
| MEMORY_DEPTH   | integer range 4 to 8192 | 16    | in this implementation, is equal to TOT_BITS/WRITE_WIDTH                                   |
## Ports

| Port name   | Direction | Type                                     | Description                                                                                                                           |
| ----------- | --------- | ---------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------- |
| clk         | in        | std_logic                                |                                                                                                                                       |
| reset       | in        | std_logic                                |                                                                                                                                       |
| memory_full | out       | std_logic                                | unused in this implementation                                                                                                         |
| wr_en       | in        | std_logic                                | has to be kept high while writing                                                                                                     |
| wr_port     | in        | std_logic_vector(WRITE_WIDTH-1 downto 0) | accepts one word at a time, loaded by the testbench                                                                                   |
| rd_en       | in        | std_logic                                | has to be kept high while reading                                                                                                     |
| rd_port     | out       | std_logic_vector(READ_WIDTH-1 downto 0)  | exposes one word at a time, at the right cycle                                                                                        |
| start       | out       | std_logic                                | used to notify start_regulator that reading phase is over                                                                             |
| start_in    | in        | std_logic                                | this notifies the memory that all memories are full and ready to start providing data                                                 |
| EoC_in      | in        | std_logic                                | End of Conversion input to notify the memory that the content of the memory can be reset on order to be ready for another computation |
## Signals

| Name            | Type                            | Description                                                                               |
| --------------- | ------------------------------- | ----------------------------------------------------------------------------------------- |
| memory          | memory_type                     |                                                                                           |
| write_counter   | integer range 0 to MEMORY_DEPTH | counts the times a writing in the memory is done, does only one full cycle                |
| read_counter    | integer range 0 to MEMORY_DEPTH | counts the times a reading from the memory is done, does as many full cycles as necessary |
| memory_full_int | std_logic                       | used to tell if reading phase can start                                                   |
| cycle_counter   | integer                         | counts the cycle between one reading and the next(i.e 1 for a, N_WORDS for b)             |
| initial_counter | integer                         | counts the cycle to wait before the beginning of the reading phase                        |
| begin_reading   | std_logic                       | flag, to 1 when writing phase is finished                                                 |
| start_flag      | std_logic                       | used to manage the start signal, which may be high  for one or more cycles                |
| start_int       | std_logic                       |                                                                                           |
## Types

| Name        | Type | Description |
| ----------- | ---- | ----------- |
| memory_type |      |             |
## Processes
- unnamed: ( clk,reset, EoC_in )
