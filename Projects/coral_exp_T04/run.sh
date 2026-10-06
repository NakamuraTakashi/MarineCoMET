#!/bin/sh
#
rm *.exe
#
SRC_DIR=../../src
INCLUDE="-I${PWD}"
FFLAGS="-fbounds-check -ffree-form -O3"
#FFLAGS="-fbounds-check -ffree-form -O0 -g -fcheck=array-temps,bounds,do,mem,pointer,recursion"

gfortran ${FFLAGS} \
  ${SRC_DIR}/mod_calendar.f90 \
  ${SRC_DIR}/mod_geochem.F  \
  ${SRC_DIR}/mod_marine_comet_param.F \
  ${SRC_DIR}/mod_aquaculture.F \
  ${SRC_DIR}/mod_param.F \
  ${SRC_DIR}/mod_reef_flow.F \
  ${SRC_DIR}/mod_heat.F \
  ${SRC_DIR}/mod_decomposition.F \
  ${SRC_DIR}/mod_foodweb.F \
  ${SRC_DIR}/mod_sedecosys.F \
  ${SRC_DIR}/mod_deb_model.F \
  ${SRC_DIR}/mod_bivalve.F \
  ${SRC_DIR}/mod_coral.F \
  ${SRC_DIR}/mod_macroalgae.F \
  ${SRC_DIR}/mod_seagrass.F \
  ${SRC_DIR}/mod_marine_comet.F \
  ${SRC_DIR}/mod_input.F \
  ${SRC_DIR}/mod_output.F \
  ${SRC_DIR}/main.F \
  ${INCLUDE} -I/usr/include -L/usr/lib -lnetcdff \
  -o ecosys_test.exe

rm *.mod
#
mkdir -p output
#
./ecosys_test.exe < coral_pre_2w.in
#./ecosys_test.exe < coral_main_L0000_T28.in
#./ecosys_test.exe < coral_main_L0000_T32.in
#./ecosys_test.exe < coral_main_L0100_T28.in
#./ecosys_test.exe < coral_main_L0100_T32.in
#./ecosys_test.exe < coral_main_L0250_T28.in
#./ecosys_test.exe < coral_main_L0250_T32.in
#./ecosys_test.exe < coral_main_L0500_T28.in
#./ecosys_test.exe < coral_main_L0500_T32.in
#./ecosys_test.exe < coral_main_L1000_T28.in
#./ecosys_test.exe < coral_main_L1000_T32.in
#
