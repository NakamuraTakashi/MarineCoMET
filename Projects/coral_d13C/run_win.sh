#!/bin/bash
#
# --- Diel (zoom) plot settings ----------------------------------------
#   ZOOM_DAYS  : length of the short window used for the diel plots (days)
#   ZOOM_START : first day of that window.  Empty = middle of the run,
#                taken from Tmax in coral_01.in.
#   Both can be overridden from the shell, e.g.
#       ZOOM_START=180 ZOOM_DAYS=5 ./run_win.sh
#ZOOM_DAYS=${ZOOM_DAYS:-3}
#ZOOM_START=${ZOOM_START:-}
ZOOM_DAYS=5
ZOOM_START=180

#
rm *.exe
#
SRC_DIR=../../src
INCLUDE="-I${PWD}"
FFLAGS="-fbounds-check -ffree-form -O3"
#FFLAGS="-fbounds-check -ffree-form -O0 -g -fcheck=array-temps,bounds,do,mem,pointer,recursion"

# --- Debug build: catch uninitialised values ---------------------------------
#   Fortran namelist input assigns only the variables that appear in the .in file
#   and leaves the rest untouched, without any diagnostic.  A variable that has no
#   initialiser and is omitted from the .in therefore holds whatever was in memory
#   (a test read back -1.14e+294 for a real and 0 for an integer).  Every variable
#   in the "initial" namelist now has a default in mod_param.F, but the flags below
#   catch anything that slips through: uninitialised reals are filled with
#   signaling NaN, so the first use aborts with SIGFPE and a backtrace instead of
#   quietly propagating.  Worth running once after adding a namelist variable.
#FFLAGS="-fbounds-check -ffree-form -O0 -g -fbacktrace -finit-real=snan -finit-integer=-99999 -ffpe-trap=invalid,zero,overflow"

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
mkdir -p output02
#
./ecosys_test.exe < coral_01.in
#
# Plot time series CSV files (full period)
uv run ../../postproc/python/plot_csv_timeseries.py -o output02 -p output02/plots
#
# Plot the diel cycle over a short window
if [ -z "${ZOOM_START}" ]; then
  ZOOM_START=$(awk -F'=' '/^[[:space:]]*Tmax/ {v=$2; sub(/[dD].*/,"",v); \
                gsub(/[^0-9.]/,"",v); if (v+0>0) printf "%.0f", v/2; exit}' coral_01.in)
fi
if [ -n "${ZOOM_START}" ]; then
  echo "Diel plots: day ${ZOOM_START} + ${ZOOM_DAYS} days -> output02/plots_diel"
  uv run ../../postproc/python/plot_csv_timeseries.py -o output02 --no-full \
    -s "${ZOOM_START}" -d "${ZOOM_DAYS}" -z output02/plots_diel
else
  echo "run_win.sh: could not read Tmax from coral_01.in; skipping diel plots."
  echo "            Set ZOOM_START explicitly, e.g. ZOOM_START=180 ./run_win.sh"
fi
