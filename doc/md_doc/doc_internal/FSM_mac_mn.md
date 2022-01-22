# Entity: FSM_mac_mn 

- **File**: FSM_mac_mn.vhd
## Diagram

![Diagram](FSM_mac_mn.svg "Diagram")
## Description

this FSM uses two counters i and j both going from 0 to N_WORDS-1 and are used to control what to expose at the output at every cycle
this FSM:
starts at cycle 0
reads n every cycle  (n is equivalent to a in mac_ab)
reads m every cycle with j=0	(m is equivalent to b in mac_ab)
reads t from multiplier. the multiplier has registered  the t value of mac_ab, to give a 1 cycle delay
cout is brought to the output everytime, adder has to sample it at the correct clock cycle
## Generics

| Generic name    | Type    | Value | Description |
| --------------- | ------- | ----- | ----------- |
| N_WORDS         | integer | 4     |             |
| N_BITS_PER_WORD | integer | 8     |             |
## Ports

| Port name | Direction | Type                                           | Description                                                                                        |
| --------- | --------- | ---------------------------------------------- | -------------------------------------------------------------------------------------------------- |
| clk       | in        | STD_LOGIC                                      |                                                                                                    |
| reset     | in        | STD_LOGIC                                      |                                                                                                    |
| start     | in        | std_logic                                      | indicates that memories are full and computation is going to start, can be one or more cycles long |
| n         | in        | std_logic_vector (N_BITS_PER_WORD-1  downto 0) |                                                                                                    |
| m         | in        | std_logic_vector (N_BITS_PER_WORD-1  downto 0) |                                                                                                    |
| t_in      | in        | std_logic_vector (N_BITS_PER_WORD-1  downto 0) |                                                                                                    |
| t_mac_out | out       | std_logic_vector (N_BITS_PER_WORD-1  downto 0) |                                                                                                    |
| c_mac_out | out       | std_logic_vector (N_BITS_PER_WORD-1  downto 0) |                                                                                                    |
## Signals

| Name          | Type                      | Description                                                       |
| ------------- | ------------------------- | ----------------------------------------------------------------- |
| i             | integer                   | counter, cfr mac_ab                                               |
| j             | integer                   | counter, cfr mac_ab                                               |
| n_dut         | std_logic_vector(n'range) | wrapper signal for the combinatorial mac module                   |
| m_dut         | std_logic_vector(n'range) | wrapper signal for the combinatorial mac module                   |
| t_in_dut      | std_logic_vector(n'range) | wrapper signal for the combinatorial mac module                   |
| c_in_dut      | std_logic_vector(n'range) | wrapper signal for the combinatorial mac module                   |
| s_out_dut     | std_logic_vector(n'range) | wrapper signal for the combinatorial mac module                   |
| c_out_dut     | std_logic_vector(n'range) | wrapper signal for the combinatorial mac module                   |
| start_reg     | std_logic                 |                                                                   |
| finished      | std_logic                 | unused in this implementation                                     |
| start_counter | integer                   | counts up to LATENCY, and measures time before computation begins |
| start_comp    | std_logic                 |                                                                   |
## Constants

| Name    | Type    | Value | Description                                      |
| ------- | ------- | ----- | ------------------------------------------------ |
| LATENCY | integer | 1     | clock cycles to wait after having received start |
## Processes
- FSM_process: ( clk,reset )
## Instantiations

- mac_inst: simple_1w_mac
