#!/bin/bash -f
# ****************************************************************************
# Vivado (TM) v2021.1 (64-bit)
#
# Filename    : simulate.sh
# Simulator   : Xilinx Vivado Simulator
# Description : Script for simulating the design by launching the simulator
#
# Generated by Vivado on Mon Nov 22 11:31:32 CET 2021
# SW Build 3247384 on Thu Jun 10 19:36:07 MDT 2021
#
# IP Build 3246043 on Fri Jun 11 00:30:35 MDT 2021
#
# usage: simulate.sh
#
# ****************************************************************************
set -Eeuo pipefail
# simulate design
echo "xsim FSM_mac_mn_behav -key {Behavioral:mac_mn:Functional:FSM_mac_mn} -tclbatch FSM_mac_mn.tcl -log simulate.log"
xsim FSM_mac_mn_behav -key {Behavioral:mac_mn:Functional:FSM_mac_mn} -tclbatch FSM_mac_mn.tcl -log simulate.log

