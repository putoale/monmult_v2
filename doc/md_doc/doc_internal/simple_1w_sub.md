# Entity: simple_1w_sub 

- **File**: simple_1w_sub.vhd
## Diagram

![Diagram](simple_1w_sub.svg "Diagram")
## Generics

| Generic name    | Type                    | Value | Description |
| --------------- | ----------------------- | ----- | ----------- |
| N_BITS_PER_WORD | POSITIVE range 8 to 512 | 8     |             |
## Ports

| Port name | Direction | Type                                          | Description |
| --------- | --------- | --------------------------------------------- | ----------- |
| d1_in     | in        | std_logic_vector (N_BITS_PER_WORD-1 downto 0) |             |
| d2_in     | in        | std_logic_vector (N_BITS_PER_WORD-1 downto 0) |             |
| b_in      | in        | std_logic_vector(0 downto 0)                  |             |
| diff_out  | out       | std_logic_vector (N_BITS_PER_WORD-1 downto 0) |             |
| b_out     | out       | std_logic_vector (0 downto 0)                 |             |
## Signals

| Name     | Type                                       | Description |
| -------- | ------------------------------------------ | ----------- |
| sub_temp | std_logic_vector(N_BITS_PER_WORD downto 0) |             |
| sub      | std_logic_vector(N_BITS_PER_WORD downto 0) |             |
