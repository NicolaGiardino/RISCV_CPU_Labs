@echo off
REM ****************************************************************************
REM Vivado (TM) v2019.1 (64-bit)
REM
REM Filename    : simulate.bat
REM Simulator   : Xilinx Vivado Simulator
REM Description : Script for simulating the design by launching the simulator
REM
REM Generated by Vivado on Wed May 26 21:54:07 +0200 2021
REM SW Build 2552052 on Fri May 24 14:49:42 MDT 2019
REM
REM Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
REM
REM usage: simulate.bat
REM
REM ****************************************************************************
echo "xsim RISCV_TB_behav -key {Behavioral:sim_2:Functional:RISCV_TB} -tclbatch RISCV_TB.tcl -view C:/Users/nicol/Documents/GitHub/VHDL_Course/RV32I_SingleStage/RISCV_VivadoVHDLProject_vicilogic/xilinxprj/RISCV/RISCV_TB_behav.wcfg -log simulate.log"
call xsim  RISCV_TB_behav -key {Behavioral:sim_2:Functional:RISCV_TB} -tclbatch RISCV_TB.tcl -view C:/Users/nicol/Documents/GitHub/VHDL_Course/RV32I_SingleStage/RISCV_VivadoVHDLProject_vicilogic/xilinxprj/RISCV/RISCV_TB_behav.wcfg -log simulate.log
if "%errorlevel%"=="0" goto SUCCESS
if "%errorlevel%"=="1" goto END
:END
exit 1
:SUCCESS
exit 0
