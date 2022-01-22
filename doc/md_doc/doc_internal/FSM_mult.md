# Entity: FSM_mult 

- **File**: FSM_mult.vhd
## Diagram

![Diagram](FSM_mult.svg "Diagram")
## Description

 This block implements an FSM controlling the inputs of a combinatorial 1w-multiplier. It also functions as a register for t_out_ab. 
 It starts after 1 clock cycle w.r.t. the start signal, and performs a multiplication every s cycles. The t_out port copies and syncronizes 
 the t_out data from mac_ab.
## Generics

| Generic name    | Type                     | Value | Description                      |
| --------------- | ------------------------ | ----- | -------------------------------- |
| N_WORDS         | POSITIVE range 4 to 8192 | 4     | Number of words per each operand |
| N_BITS_PER_WORD | POSITIVE range 8 to 512  | 32    | Number of bits per each word     |
## Ports

| Port name | Direction | Type                                          | Description                           |
| --------- | --------- | --------------------------------------------- | ------------------------------------- |
| clk       | in        | std_logic                                     | clock signal                          |
| reset     | in        | std_logic                                     | asyncronous reset signal              |
| start     | in        | std_logic                                     | start signal from outside             |
| t_in      | in        | std_logic_vector (N_BITS_PER_WORD-1 downto 0) | input word from mac_ab                |
| nn0       | in        | std_logic_vector (N_BITS_PER_WORD-1 downto 0) | input n'(0)                           |
| t_out     | out       | std_logic_vector (N_BITS_PER_WORD-1 downto 0) | output t (input t delayed by 1 cycle) |
| m_out     | out       | std_logic_vector (N_BITS_PER_WORD-1 downto 0) | output product                        |
## Signals

| Name      | Type                                          | Description                         |
| --------- | --------------------------------------------- | ----------------------------------- |
| i_counter | natural range 0 to N_WORDS                    | signal to count i cycle             |
| j_counter | natural range 0 to N_WORDS                    | signal to count words of an i_cycle |
| a_sig     | std_logic_vector (N_BITS_PER_WORD-1 downto 0) | signals to sample input data        |
| start_reg | std_logic                                     |                                     |
## Processes
- Mult_FSM: ( clk,reset )
  - **Description**
  This FSM controls the inputs of the combinatorial multiplier 
## Instantiations

- mult_1w: simple_1w_mult
