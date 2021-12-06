#!/bin/bash
export LANG="en_US.utf8"
/tools/Xilinx/Vivado/2021.1/bin/vivado -source monmult_v2.tcl
/tools/Xilinx/Vivado/2021.1/bin/vivado monmult_v2.xpr
