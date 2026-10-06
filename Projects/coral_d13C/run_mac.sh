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
  ${INCLUDE} -I/opt/homebrew/include -L/opt/homebrew/lib -lnetcdff \
  -o ecosys_test.exe

rm *.mod
#
mkdir -p output
#
#./ecosys_test.exe < coral_01.in
./ecosys_test.exe < coral_bl_T25.in
./ecosys_test.exe < coral_bl_T33.in
./ecosys_test.exe < coral_bl_T13.in
./ecosys_test.exe < coral_bl_T17.in
./ecosys_test.exe < coral_bl_T21.in
./ecosys_test.exe < coral_bl_T29.in
#
