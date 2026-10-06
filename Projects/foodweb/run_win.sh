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
mkdir -p output_2023NP
#
./ecosys_test.exe < foodweb_2023NP.in
#./ecosys_test.exe < foodweb_C.in
#./ecosys_test.exe < foodweb_2NP.in
#./ecosys_test.exe < foodweb_N.in
#./ecosys_test.exe < foodweb_2N.in
#./ecosys_test.exe < foodweb_P.in
#
# Plot time series CSV files
uv run ../../postproc/python/plot_csv_timeseries.py -o output_2023NP -p output_2023NP/plots

#mv output/ output_2023NP/
