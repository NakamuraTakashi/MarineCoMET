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
  ${SRC_DIR}/mod_param.F \
  ${SRC_DIR}/mod_reef_flow.F \
  ${SRC_DIR}/mod_heat.F \
  ${SRC_DIR}/mod_decomposition.F \
  ${SRC_DIR}/mod_foodweb.F \
  ${SRC_DIR}/mod_sedecosys.F \
  ${SRC_DIR}/mod_coral.F \
  ${SRC_DIR}/mod_macroalgae.F \
  ${SRC_DIR}/mod_seagrass.F \
  ${SRC_DIR}/mod_marine_comet.F \
  ${SRC_DIR}/mod_input.F \
  ${SRC_DIR}/mod_output.F \
  ${SRC_DIR}/main.F \
  ${INCLUDE} -I/usr/local/include -L/usr/local/lib -lnetcdff \
  -o ecosys_test.exe

  # ${INCLUDE} -I/opt/homebrew/include -L/opt/homebrew/lib -lnetcdff \

rm *.mod
#
mkdir -p output
#
./ecosys_test.exe < seagrass_test1.in
#
