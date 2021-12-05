#!/bin/bash -f
# ****************************************************************************
# Vivado (TM) v2021.1 (64-bit)
#
# Filename    : simulate.sh
# Simulator   : Xilinx Vivado Simulator
# Description : Script for simulating the design by launching the simulator
#
# Generated by Vivado on Sun Dec 05 10:45:06 CET 2021
# SW Build 3247384 on Thu Jun 10 19:36:07 MDT 2021
#
# IP Build 3246043 on Fri Jun 11 00:30:35 MDT 2021
#
# usage: simulate.sh
#
# ****************************************************************************
set -Eeuo pipefail
# simulate design
echo "xsim tb_mac_ab_behav -key {Behavioral:mac_ab:Functional:tb_mac_ab} -tclbatch tb_mac_ab.tcl -log simulate.log"
xsim tb_mac_ab_behav -key {Behavioral:mac_ab:Functional:tb_mac_ab} -tclbatch tb_mac_ab.tcl -log simulate.log

