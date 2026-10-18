#!/bin/bash
#
# Build the model once, then run every case (*.in) concurrently in the
# background and plot each case's output.
#
# Usage
#   ./run_win.sh                      # every *.in in this directory
#   ./run_win.sh coral_01.in warm.in  # only the named cases
#   ./run_win.sh -j 4                 # at most 4 concurrent runs
#   ./run_win.sh --no-build           # reuse the existing executable
#   ./run_win.sh --no-plot            # run the model, skip plotting
#
# --- Preparing cases --------------------------------------------------
#   Copy coral_01.in, edit the conditions, and give each copy its OWN
#   OUTFILE_prefix in the &output namelist, e.g.
#       OUTFILE_prefix = 'output_warm/test'
#   Every output file the model writes starts with that prefix, so distinct
#   prefixes are what keeps concurrent runs from overwriting each other.
#   The script refuses to start if two cases share a prefix.  The output
#   directory itself does not need to exist; it is created here.
#
#   cppdefs.h is compile-time, so all cases in one invocation share the same
#   CPP options.  To compare different CPP settings, run the script once per
#   setting (the executable is rebuilt each time unless --no-build is given).
#
# --- Diel (zoom) plot settings ----------------------------------------
#   ZOOM_DAYS  : length of the short window used for the diel plots (days)
#   ZOOM_START : first day of that window.  Empty = middle of the run,
#                taken from Tmax in each case's .in file.
#   Diel plots are produced only when at least one of the two is set, e.g.
#       ZOOM_START=180 ZOOM_DAYS=5 ./run_win.sh
#       ZOOM_DAYS=3 ./run_win.sh

set -u

SRC_DIR=../../src
INCLUDE="-I${PWD}"
FFLAGS="-fbounds-check -ffree-form -O3"
#FFLAGS="-fbounds-check -ffree-form -O0 -g -fcheck=array-temps,bounds,do,mem,pointer,recursion"
EXE=ecosys_test.exe
LOG_DIR=logs
PLOT_SCRIPT=../../postproc/python/plot_csv_timeseries.py

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

ZOOM_DAYS=${ZOOM_DAYS:-}
ZOOM_START=${ZOOM_START:-}

die() { printf 'run_win.sh: %s\n' "$*" >&2; exit 1; }

# ----------------------------------------------------------------------
# Command line
# ----------------------------------------------------------------------
NJOBS=$(nproc 2>/dev/null || echo 4)
DO_BUILD=1
DO_PLOT=1
CASES=()

while (( $# > 0 )); do
  case $1 in
    -j|--jobs)   [[ ${2:-} =~ ^[0-9]+$ ]] || die "-j needs a number"
                 NJOBS=$2; shift 2 ;;
    -j*)         NJOBS=${1#-j}; shift ;;
    --no-build)  DO_BUILD=0; shift ;;
    --no-plot)   DO_PLOT=0; shift ;;
    -h|--help)   sed -n '2,/^$/p' "$0" | sed 's/^#\s\?//'; exit 0 ;;
    -*)          die "unknown option: $1" ;;
    *)           CASES+=("$1"); shift ;;
  esac
done
(( NJOBS >= 1 )) || die "-j must be at least 1"

if (( ${#CASES[@]} == 0 )); then
  shopt -s nullglob
  CASES=(*.in)
  shopt -u nullglob
fi
(( ${#CASES[@]} > 0 )) || die "no .in files found in ${PWD}"

# ----------------------------------------------------------------------
# Read OUTFILE_prefix out of a case's &output namelist
# ----------------------------------------------------------------------
get_outfile_prefix() {
  sed -n "s/^[[:space:]]*OUTFILE_prefix[[:space:]]*=[[:space:]]*['\"]\([^'\"]*\)['\"].*/\1/Ip" "$1" | head -1
}

# Middle of the run, from Tmax in the case's .in file (used when ZOOM_START
# is not set).  Prints nothing when Tmax cannot be read.
get_zoom_start() {
  awk -F'=' '/^[[:space:]]*Tmax/ {v=$2; sub(/[dD].*/,"",v); \
             gsub(/[^0-9.]/,"",v); if (v+0>0) printf "%.0f", v/2; exit}' "$1"
}

# ----------------------------------------------------------------------
# Validate every case up front: a bad .in should stop us before we spend
# minutes building and running the others.
# ----------------------------------------------------------------------
declare -A PREFIX_OWNER=()
PREFIXES=()
OUTDIRS=()

for in_file in "${CASES[@]}"; do
  [[ -f $in_file ]] || die "no such case file: $in_file"
  prefix=$(get_outfile_prefix "$in_file")
  [[ -n $prefix ]] || die "$in_file: no OUTFILE_prefix in the &output namelist"
  owner=${PREFIX_OWNER[$prefix]:-}
  if [[ -n $owner ]]; then
    die "$in_file and $owner both use OUTFILE_prefix '$prefix'.
            Concurrent runs would overwrite each other's output.
            Give each case its own prefix."
  fi
  PREFIX_OWNER[$prefix]=$in_file
  PREFIXES+=("$prefix")
  OUTDIRS+=("$(dirname "$prefix")")
done

# ----------------------------------------------------------------------
# Build (once - the executable is shared by every case)
# ----------------------------------------------------------------------
if (( DO_BUILD )); then
  echo "=== Building ${EXE} ==="
  rm -f ./*.exe
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
    -o ${EXE} || die "compilation failed"
  rm -f ./*.mod
  echo
fi
[[ -x ./${EXE} ]] || die "./${EXE} not found - build it first (drop --no-build)"

# ----------------------------------------------------------------------
# Run every case in the background, at most NJOBS at a time
# ----------------------------------------------------------------------
mkdir -p "${LOG_DIR}"

run_case() {
  local in_file=$1 log=$2 stat=$3
  local t0=${SECONDS}
  ./${EXE} < "${in_file}" > "${log}" 2>&1
  local rc=$? elapsed=$(( SECONDS - t0 ))
  printf '%d\n' "${rc}" > "${stat}"
  if (( rc == 0 )); then
    printf '  [done]   %-28s %5ds\n' "${in_file}" "${elapsed}"
  else
    printf '  [FAILED] %-28s %5ds  rc=%d  -> %s\n' "${in_file}" "${elapsed}" "${rc}" "${log}"
  fi
}

echo "=== Running ${#CASES[@]} case(s), up to ${NJOBS} at a time ==="
for i in "${!CASES[@]}"; do
  in_file=${CASES[i]}
  stem=$(basename "${in_file}" .in)
  mkdir -p "${OUTDIRS[i]}"
  rm -f "${LOG_DIR}/${stem}.status"
  # Throttle: wait for a slot before starting the next case.
  while (( $(jobs -rp | wc -l) >= NJOBS )); do
    wait -n 2>/dev/null || true
  done
  printf '  [start]  %-28s -> %s\n' "${in_file}" "${PREFIXES[i]}*"
  run_case "${in_file}" "${LOG_DIR}/${stem}.log" "${LOG_DIR}/${stem}.status" &
done
wait
echo

# ----------------------------------------------------------------------
# Collect results
# ----------------------------------------------------------------------
# Only cases that finished cleanly are worth plotting; a crashed run leaves
# a truncated CSV behind and the plots would be misleading.
OK_CASES=()
FAILED_CASES=()
for i in "${!CASES[@]}"; do
  stem=$(basename "${CASES[i]}" .in)
  rc=$(cat "${LOG_DIR}/${stem}.status" 2>/dev/null || echo 1)
  if [[ $rc == 0 ]]; then OK_CASES+=("$i"); else FAILED_CASES+=("$i"); fi
done

# ----------------------------------------------------------------------
# Plot, one job per output directory
# ----------------------------------------------------------------------
# plot_csv_timeseries.py plots every CSV in a directory, so cases sharing an
# output directory are covered by a single invocation.
if (( DO_PLOT )) && (( ${#OK_CASES[@]} > 0 )); then
  echo "=== Plotting ==="
  declare -A PLOTTED=()
  for i in "${OK_CASES[@]}"; do
    dir=${OUTDIRS[i]}
    [[ -n ${PLOTTED[$dir]:-} ]] && continue
    PLOTTED[$dir]=1
    stem=$(basename "${CASES[i]}" .in)

    zoom_start=${ZOOM_START}
    zoom_days=${ZOOM_DAYS}
    if [[ -n $zoom_start || -n $zoom_days ]]; then
      [[ -z $zoom_start ]] && zoom_start=$(get_zoom_start "${CASES[i]}")
    fi

    while (( $(jobs -rp | wc -l) >= NJOBS )); do
      wait -n 2>/dev/null || true
    done
    (
      log=${LOG_DIR}/${stem}.plot.log
      uv run "${PLOT_SCRIPT}" -o "${dir}" -p "${dir}/plots" > "${log}" 2>&1
      rc=$?
      if [[ -n $zoom_start || -n $zoom_days ]]; then
        if [[ -n $zoom_start ]]; then
          uv run "${PLOT_SCRIPT}" -o "${dir}" --no-full \
            ${zoom_start:+-s "${zoom_start}"} ${zoom_days:+-d "${zoom_days}"} \
            -z "${dir}/plots_diel" >> "${log}" 2>&1 || rc=$?
        else
          echo "could not read Tmax from ${CASES[i]}; skipping diel plots." >> "${log}"
          echo "set ZOOM_START explicitly, e.g. ZOOM_START=180 ./run_win.sh" >> "${log}"
        fi
      fi
      if (( rc == 0 )); then
        printf '  [done]   %-28s -> %s/plots\n' "${dir}" "${dir}"
      else
        printf '  [FAILED] %-28s rc=%d  -> %s\n' "${dir}" "${rc}" "${log}"
      fi
    ) &
  done
  wait
  echo
fi

# ----------------------------------------------------------------------
# Summary
# ----------------------------------------------------------------------
echo "=== Summary ==="
printf '  cases run : %d\n' "${#CASES[@]}"
printf '  succeeded : %d\n' "${#OK_CASES[@]}"
printf '  failed    : %d\n' "${#FAILED_CASES[@]}"
for i in "${FAILED_CASES[@]-}"; do
  [[ -z ${i} ]] && continue
  printf '    %-28s %s/%s.log\n' "${CASES[i]}" "${LOG_DIR}" "$(basename "${CASES[i]}" .in)"
done
(( ${#FAILED_CASES[@]} == 0 )) || exit 1
