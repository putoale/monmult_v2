# Entity: cios_top_1w 

- **File**: cios_top_1w.vhd
## Diagram

![Diagram](cios_top_1w.svg "Diagram")
## Description

 This module includes all the computational blocks. It's embedded inside monmult_module, together with the memories.
## Generics

| Generic name    | Type    | Value | Description |
| --------------- | ------- | ----- | ----------- |
| N_BITS_PER_WORD | integer | 8     |             |
| N_WORDS         | integer | 4     |             |
## Ports

| Port name | Direction | Type                                         | Description                                                                                                        |
| --------- | --------- | -------------------------------------------- | ------------------------------------------------------------------------------------------------------------------ |
| clk       | in        | std_logic                                    |                                                                                                                    |
| reset     | in        | std_logic                                    |                                                                                                                    |
| a         | in        | std_logic_vector(N_BITS_PER_WORD-1 downto 0) |                                                                                                                    |
| b         | in        | std_logic_vector(N_BITS_PER_WORD-1 downto 0) |                                                                                                                    |
| n_mac     | in        | std_logic_vector(N_BITS_PER_WORD-1 downto 0) |                                                                                                                    |
| n_sub     | in        | std_logic_vector(N_BITS_PER_WORD-1 downto 0) |                                                                                                                    |
| start     | in        | std_logic                                    | indicates that memories are full and computation is going to start, can be one or more cycles long                 |
| nn0       | in        | std_logic_vector(N_BITS_PER_WORD-1 downto 0) | this is the least significant word of the inverse of N modulo R, which is computed by the PC and fed to the module |
| EoC       | out       | std_logic                                    | End Of Conversion, is high on the last word of the valid result                                                    |
| valid_out | out       | std_logic                                    | Is high only when the subtractor is giving out the correct result                                                  |
| result    | out       | std_logic_vector(N_BITS_PER_WORD-1 downto 0) |                                                                                                                    |
## Signals

| Name         | Type                                           | Description |
| ------------ | ---------------------------------------------- | ----------- |
| t_out_ab     | std_logic_vector(N_BITS_PER_WORD-1 downto 0)   |             |
| c_out_ab     | std_logic_vector(N_BITS_PER_WORD-1 downto 0)   |             |
| m            | std_logic_vector (N_BITS_PER_WORD-1  downto 0) |             |
| t_mac_out_mn | std_logic_vector (N_BITS_PER_WORD-1  downto 0) |             |
| c_out_mn     | std_logic_vector (N_BITS_PER_WORD-1  downto 0) |             |
| t_out_mn     | std_logic_vector (N_BITS_PER_WORD-1  downto 0) |             |
| c_in_ab      | std_logic_vector (N_BITS_PER_WORD-1 downto 0)  |             |
| c_in_mn      | std_logic_vector (N_BITS_PER_WORD-1 downto 0)  |             |
| c_out        | std_logic_vector (N_BITS_PER_WORD-1 downto 0)  |             |
| t_out        | std_logic_vector (N_BITS_PER_WORD-1 downto 0)  |             |
| t_in         | std_logic_vector (N_BITS_PER_WORD-1 downto 0)  |             |
| n_in         | std_logic_vector (N_BITS_PER_WORD-1 downto 0)  |             |
| t_adder      | std_logic_vector (N_BITS_PER_WORD-1 downto 0)  |             |
| t_out_mult   | std_logic_vector (N_BITS_PER_WORD-1 downto 0)  |             |
## Instantiations

- mac_ab_inst: FSM_mac_ab
- mac_mn_inst: FSM_mac_mn
- mult_inst: FSM_mult
- add_inst: FSM_add
- sub_inst: FSM_sub_v2
