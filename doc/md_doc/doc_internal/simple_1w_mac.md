# Entity: simple_1w_mac 

- **File**: simple_1w_mac.vhd
## Diagram

![Diagram](simple_1w_mac.svg "Diagram")
## Generics

| Generic name | Type     | Value | Description |
| ------------ | -------- | ----- | ----------- |
| N_BITS       | positive | 8     |             |
## Ports

| Port name | Direction | Type                                | Description |
| --------- | --------- | ----------------------------------- | ----------- |
| a_j       | in        | std_logic_vector(N_BITS-1 downto 0) |             |
| b_i       | in        | std_logic_vector(N_BITS-1 downto 0) |             |
| t_in      | in        | std_logic_vector(N_BITS-1 downto 0) |             |
| c_in      | in        | std_logic_vector(N_BITS-1 downto 0) |             |
| s_out     | out       | std_logic_vector(N_BITS-1 downto 0) |             |
| c_out     | out       | std_logic_vector(N_BITS-1 downto 0) |             |
## Signals

| Name    | Type                          | Description |
| ------- | ----------------------------- | ----------- |
| big_sum | unsigned(2*N_BITS-1 downto 0) |             |
| aj_bi   | unsigned(2*N_BITS-1 downto 0) |             |
| t_c     | unsigned(2*N_BITS-1 downto 0) |             |
