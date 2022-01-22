# Entity: sr 

- **File**: sr.vhd
## Diagram

![Diagram](sr.svg "Diagram")
## Description

 this shift register is put inside of mac_ab in order to buffer its t input
## Generics

| Generic name | Type     | Value | Description |
| ------------ | -------- | ----- | ----------- |
| SR_WIDTH     | NATURAL  | 8     |             |
| SR_DEPTH     | POSITIVE | 4     |             |
| SR_INIT      | INTEGER  | 0     |             |
## Ports

| Port name | Direction | Type                                  | Description |
| --------- | --------- | ------------------------------------- | ----------- |
| reset     | in        | STD_LOGIC                             |             |
| clk       | in        | STD_LOGIC                             |             |
| din       | in        | STD_LOGIC_VECTOR(SR_WIDTH-1 downto 0) |             |
| dout      | out       | STD_LOGIC_VECTOR(SR_WIDTH-1 downto 0) |             |
## Signals

| Name | Type           | Description |
| ---- | -------------- | ----------- |
| mem  | MEM_ARRAY_TYPE |             |
## Constants

| Name     | Type                                  | Value                                                                               | Description |
| -------- | ------------------------------------- | ----------------------------------------------------------------------------------- | ----------- |
| INIT_SLV | STD_LOGIC_VECTOR(SR_WIDTH-1 downto 0) | std_logic_vector(to_unsigned(SR_INIT,<br><span style="padding-left:20px">SR_WIDTH)) |             |
## Types

| Name           | Type | Description |
| -------------- | ---- | ----------- |
| MEM_ARRAY_TYPE |      |             |
## Processes
- shift_reg: ( reset, clk )
