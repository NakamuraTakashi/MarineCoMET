#!/bin/bash
#
# --- Diel (zoom) plot settings ----------------------------------------
#   ZOOM_DAYS  : length of the short window used for the diel plots (days)
#   ZOOM_START : first day of that window.  Empty = middle of the run,
#                taken from Tmax in coral_01.in.
#   Both can be overridden from the shell, e.g.
#       ZOOM_START=180 ZOOM_DAYS=5 ./run_plot.sh
#ZOOM_DAYS=${ZOOM_DAYS:-3}
#ZOOM_START=${ZOOM_START:-}
ZOOM_DAYS=5
ZOOM_START=50
#
# Plot time series CSV files (full period)
uv run ../../postproc/python/plot_csv_timeseries.py -o output01 -p output01/plots
#
# Plot the diel cycle over a short window
if [ -z "${ZOOM_START}" ]; then
  ZOOM_START=$(awk -F'=' '/^[[:space:]]*Tmax/ {v=$2; sub(/[dD].*/,"",v); \
                gsub(/[^0-9.]/,"",v); if (v+0>0) printf "%.0f", v/2; exit}' coral_01.in)
fi
if [ -n "${ZOOM_START}" ]; then
  echo "Diel plots: day ${ZOOM_START} + ${ZOOM_DAYS} days -> output01/plots_diel"
  uv run ../../postproc/python/plot_csv_timeseries.py -o output01 --no-full \
    -s "${ZOOM_START}" -d "${ZOOM_DAYS}" -z output01/plots_diel
else
  echo "run_win.sh: could not read Tmax from coral_01.in; skipping diel plots."
  echo "            Set ZOOM_START explicitly, e.g. ZOOM_START=180 ./run_win.sh"
fi
