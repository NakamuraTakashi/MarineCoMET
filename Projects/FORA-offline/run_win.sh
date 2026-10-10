#!/bin/bash
#
rm *.exe
#
SRC_DIR=../../src
INCLUDE="-I${PWD}"
#FFLAGS="-fbounds-check -ffree-form -O3"
FFLAGS="-fbounds-check -ffree-form -O0 -g -fcheck=array-temps,bounds,do,mem,pointer,recursion"

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
  ${SRC_DIR}/mod_infile.F90 \
  ${SRC_DIR}/mod_roms_netcdf.F90 \
  ${SRC_DIR}/main_OCN_offline.F90 \
  ${INCLUDE} -I/usr/include -L/usr/lib -lnetcdff \
  -o fora-offline.exe

rm *.mod
#
mkdir -p output02
#
./fora-offline.exe < fora-off_01.in
#
cdo yearmax -selname,DCW,DHW /mnt/w/nakamura/output/temp_stress_19600101.0000-20201231.0000.nc yearmax_DHW_DCW_19600101.0000-20201231.0000.nc
#