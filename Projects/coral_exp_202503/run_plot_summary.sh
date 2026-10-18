#!/bin/bash
#
# Overlay the same variable from every case in an output directory, without
# rerunning the model.  Figures go to <output dir>/plot_summary.
#
# Usage
#   ./run_plot_summary.sh                     # output01, every case found
#   ./run_plot_summary.sh output02            # another output directory
#   ./run_plot_summary.sh output01 T15-L400 T25-L400   # only these cases
#
# --- Zoom window (optional) -------------------------------------------
#   ZOOM_START=50 ZOOM_DAYS=5 ./run_plot_summary.sh
#   draws the window into <output dir>/plot_summary_diel instead.

OUT_DIR=${1:-output01}
shift $(( $# > 0 ? 1 : 0 ))

# Same list as SUMMARY_VARS in run_all.sh: <file>:<col>[,<col>...]
SUMMARY_VARS=(
  "crl01:Pg,Pn,G"
  "zphot01:Fv_Fm"
  "zoo01:Chl,Chl_ug_cm-2,dens"
)

ZOOM_DAYS=${ZOOM_DAYS:-}
ZOOM_START=${ZOOM_START:-}

var_args=()
for v in "${SUMMARY_VARS[@]}"; do var_args+=(-v "$v"); done
(( $# > 0 )) && var_args+=(-c "$@")

if [[ -n ${ZOOM_START} || -n ${ZOOM_DAYS} ]]; then
  uv run ../../postproc/python/plot_case_overlay.py -o "${OUT_DIR}" \
    -p "${OUT_DIR}/plot_summary_diel" "${var_args[@]}" \
    ${ZOOM_START:+-s "${ZOOM_START}"} ${ZOOM_DAYS:+-d "${ZOOM_DAYS}"}
else
  uv run ../../postproc/python/plot_case_overlay.py -o "${OUT_DIR}" \
    -p "${OUT_DIR}/plot_summary" "${var_args[@]}"
fi
