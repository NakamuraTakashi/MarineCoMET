#!/bin/bash
#
# Directory containing ROMS source code
ROMS_DIR=~/COAWST/COAWST_Eco/ROMS

ECO_DIR=${ROMS_DIR}/Nonlinear/Biology/reef_ecosys
MOD_DIR=${ROMS_DIR}/Modules
#
# The ROMS side has not yet been migrated from reef_ecosys to marine_comet
# (it still uses mod_reef_ecosys, reef_ecosys(), ...). Syncing now would put
# mod_marine_comet*.F next to mod_reef_ecosys*.F, and Module.mk compiles both.
if [ -f ${ECO_DIR}/mod_reef_ecosys.F ] || [ -f ${ECO_DIR}/mod_reef_ecosys_param.F ]; then
  echo "ERROR: ${ECO_DIR} still contains mod_reef_ecosys*.F."
  echo "       Rename the ROMS side to marine_comet before syncing."
  exit 1
fi
#
items=(
#  "test.txt"
  "mod_bivalve.F"
  "mod_coral.F"
  "mod_deb_model.F"
  "mod_decomposition.F"
  "mod_foodweb.F"
  "mod_geochem.F"
  "mod_macroalgae.F"
  "mod_marine_comet_param.F"
  "mod_marine_comet.F"
  "mod_seagrass.F"
  "mod_sedecosys.F"
)
items2=(
  "mod_aquaculture.F"
)
#
for item in "${items[@]}"; do
    echo "========================================"
    echo "ROMS to MarineCoMET: ${item}"
    rsync -avu ${ECO_DIR}/${item} src/${item}
    echo "----------------------------------------"
    echo "MarineCoMET to ROMS: ${item}"
    rsync -avu src/${item} ${ECO_DIR}/${item}
done
#
for item in "${items2[@]}"; do
    echo "========================================"
    echo "ROMS to MarineCoMET: ${item}"
    rsync -avu ${MOD_DIR}/${item} src/${item}
    echo "----------------------------------------"
    echo "MarineCoMET to ROMS: ${item}"
    rsync -avu src/${item} ${MOD_DIR}/${item}
done
#
