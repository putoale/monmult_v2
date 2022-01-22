# Entity: FSM_mac_ab 

- **File**: FSM_mac_ab.vhd
## Diagram

![Diagram](FSM_mac_ab.svg "Diagram")
## Description

this FSM uses two counters i and j both going from 0 to N_WORDS-1 and are used to control what to expose at the output at every cycle
this FSM:
starts at cycle 0
reads a every cycle
reads b every cycle
reads t = 0 for i=0
reads t = t_mac_in for i>=1, j<N_WORDS
reads t = t_adder_in for i>=1, j=N_WORDS
if N_WORDS>4, a shift register is added in order to take into account the delay between the clock mac_mn exposes its t output and mac_ab reads it
cout is brought to the output everytime, adder has to sample the correct one
## Generics

| Generic name    | Type    | Value | Description |
| --------------- | ------- | ----- | ----------- |
| N_WORDS         | integer | 4     |             |
| N_BITS_PER_WORD | integer | 8     |             |
## Ports

| Port name  | Direction | Type                                           | Description |
| ---------- | --------- | ---------------------------------------------- | ----------- |
| clk        | in        | STD_LOGIC                                      |             |
| reset      | in        | STD_LOGIC                                      |             |
| start      | in        | std_logic                                      |             |
| a          | in        | std_logic_vector (N_BITS_PER_WORD-1  downto 0) |             |
| b          | in        | std_logic_vector (N_BITS_PER_WORD-1  downto 0) |             |
| t_mac_in   | in        | std_logic_vector (N_BITS_PER_WORD-1  downto 0) |             |
| t_adder_in | in        | std_logic_vector (N_BITS_PER_WORD-1  downto 0) |             |
| t_mac_out  | out       | std_logic_vector (N_BITS_PER_WORD-1  downto 0) |             |
| c_mac_out  | out       | std_logic_vector (N_BITS_PER_WORD-1  downto 0) |             |
## Signals

| Name          | Type                               | Description                                           |
| ------------- | ---------------------------------- | ----------------------------------------------------- |
| i             | integer                            | coarse counter                                        |
| j             | integer                            | fine counter                                          |
| sr_in         | std_logic_vector(t_adder_in'range) |                                                       |
| a_dut         | std_logic_vector(a'range)          | wrapper signal for the combinatorial mac module       |
| b_dut         | std_logic_vector(a'range)          | wrapper signal for the combinatorial mac module       |
| t_in_dut      | std_logic_vector(a'range)          | wrapper signal for the combinatorial mac module       |
| c_in_dut      | std_logic_vector(a'range)          | wrapper signal for the combinatorial mac module       |
| s_out_dut     | std_logic_vector(a'range)          | wrapper signal for the combinatorial mac module       |
| c_out_dut     | std_logic_vector(a'range)          | wrapper signal for the combinatorial mac module       |
| din_dut       | std_logic_vector(t_mac_in'range)   | wrapper signal for the sr                             |
| dout_dut      | std_logic_vector(t_mac_in'range)   | wrapper signal for the sr                             |
| counter       | integer                            |                                                       |
| start_reg     | std_logic                          |                                                       |
| send_t_mac_in | std_logic                          | controls when the sr needs to store the mac_mn output |
| send_t_adder  | std_logic                          | controls when the sr needs to store the adder output  |
| counter_mac   | integer                            |                                                       |
## Processes
- FSM_process: ( clk,reset )
## Instantiations

- mac_inst: simple_1w_mac
