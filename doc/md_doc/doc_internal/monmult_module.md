# Entity: monmult_module 

- **File**: monmult_module.vhd
## Diagram

![Diagram](monmult_module.svg "Diagram")
## Description

 this is the module that contains all the others, and wires them together
## Generics

| Generic name    | Type    | Value | Description                                     |
| --------------- | ------- | ----- | ----------------------------------------------- |
| WRITE_WIDTH     | integer | 16    | MUST BE SET THE SAME AS NUMBER OF BITS PER WORD |
| READ_WIDTH      | integer | 16    | MUST BE SET THE SAME AS NUMBER OF BITS PER WORD |
| N_BITS_PER_WORD | integer | 16    |                                                 |
| N_WORDS         | integer | 16    | IS THE RESULT OF TOTAL_BITS/N_BITS_PER_WORD     |
| MEMORY_DEPTH    | integer | 16    | IT IS THE SAME OF N_WORDS                       |
## Ports

| Port name   | Direction | Type                                         | Description                                                                               |
| ----------- | --------- | -------------------------------------------- | ----------------------------------------------------------------------------------------- |
| clk         | in        | std_logic                                    |                                                                                           |
| reset       | in        | std_logic                                    |                                                                                           |
| wr_en_a     | in        | std_logic                                    | will be rised by the testbench when the data are ready to be loaded in the input memories |
| wr_en_b     | in        | std_logic                                    | will be rised by the testbench when the data are ready to be loaded in the input memories |
| wr_en_n_mac | in        | std_logic                                    | will be rised by the testbench when the data are ready to be loaded in the input memories |
| wr_en_n_sub | in        | std_logic                                    | will be rised by the testbench when the data are ready to be loaded in the input memories |
| a           | in        | std_logic_vector(N_BITS_PER_WORD-1 downto 0) | data inputs to be loaded to input memories will be fed one word at a time                 |
| b           | in        | std_logic_vector(N_BITS_PER_WORD-1 downto 0) | data inputs to be loaded to input memories will be fed one word at a time                 |
| n           | in        | std_logic_vector(N_BITS_PER_WORD-1 downto 0) | data inputs to be loaded to input memories will be fed one word at a time                 |
| nn0         | in        | std_logic_vector(N_BITS_PER_WORD-1 downto 0) | data inputs to be loaded to input memories will be fed one word at a time                 |
| EoC         | out       | std_logic                                    | End Of Conversion, is high on the last word of the valid result                           |
| valid_out   | out       | std_logic                                    | Is high only when the subtractor is giving out the correct result                         |
| result      | out       | std_logic_vector(N_BITS_PER_WORD-1 downto 0) |                                                                                           |
## Signals

| Name          | Type                                         | Description                                                          |
| ------------- | -------------------------------------------- | -------------------------------------------------------------------- |
| a_mem         | std_logic_vector(N_BITS_PER_WORD-1 downto 0) |                                                                      |
| b_mem         | std_logic_vector(N_BITS_PER_WORD-1 downto 0) |                                                                      |
| n_mac_mem     | std_logic_vector(N_BITS_PER_WORD-1 downto 0) |                                                                      |
| n_sub_mem     | std_logic_vector(N_BITS_PER_WORD-1 downto 0) |                                                                      |
| start_a       | std_logic                                    |                                                                      |
| start_b       | std_logic                                    |                                                                      |
| start_n_mac   | std_logic                                    |                                                                      |
| start_n_sub   | std_logic                                    |                                                                      |
| EoC_sig       | std_logic                                    |                                                                      |
| EoC_reg       | std_logic                                    |                                                                      |
| memory_full   | std_logic                                    |                                                                      |
| start_mem     | std_logic                                    | signals that memories can begin exposing data at their outputs       |
| start_modules | std_logic                                    | signal that modules can start to wait for their respective latencies |
## Constants

| Name          | Type    | Value                             | Description                                                                                                 |
| ------------- | ------- | --------------------------------- | ----------------------------------------------------------------------------------------------------------- |
| LATENCY_AB    | integer | 1                                 | this constant controls after how many cycles startig from the start signal is mac_ab going to start reading |
| LATENCY_N_SUB | integer | LATENCY_AB +N_WORDS*(N_WORDS-1)+4 | this constant controls after how many cycles startig from the start signal is sub going to start reading    |
| LATENCY_N_MAC | integer | LATENCY_AB+2                      | this constant controls after how many cycles startig from the start signal is mac_mn going to start reading |
## Processes
- unnamed: ( clk )
## Instantiations

- inst_cios_1w: cios_top_1w
- mem_a_inst: input_mem_abn
- mem_b_inst: input_mem_abn
- mem_n_mac_inst: input_mem_abn
- mem_n_sub_inst: input_mem_abn
- regulator_inst: start_regulator
