# Entity: simple_1w_adder 

- **File**: simple_1w_adder.vhd
## Diagram

![Diagram](simple_1w_adder.svg "Diagram")
## Generics

| Generic name    | Type                    | Value | Description |
| --------------- | ----------------------- | ----- | ----------- |
| N_BITS_PER_WORD | POSITIVE range 2 to 512 | 32    |             |
## Ports

| Port name | Direction | Type                                           | Description |
| --------- | --------- | ---------------------------------------------- | ----------- |
| a         | in        | std_logic_vector (N_BITS_PER_WORD-1 downto 0)  |             |
| b         | in        | std_logic_vector (N_BITS_PER_WORD-1 downto 0)  |             |
| s         | out       | std_logic_vector (N_BITS_PER_WORD -1 downto 0) |             |
| c         | out       | std_logic_vector (N_BITS_PER_WORD -1 downto 0) |             |
## Signals

| Name | Type                                                 | Description |
| ---- | ---------------------------------------------------- | ----------- |
| sum  | std_logic_vector ( (2*N_BITS_PER_WORD) - 1 downto 0) |             |
