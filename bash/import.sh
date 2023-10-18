#!/bin/bash

# This script will import transports one by one sequentially.
# The list of transport should be given in <TRANSPORT-LIST.txt> file where
# each transport should be in new line.

TPLIST="/usr/sap/trans/auto_import/trlist.txt"
TPSTATUS="${TPLIST}.RClog"

for i in $(cat ${TPLIST}); do
  echo "Importing ${i}." >> ${TPSTATUS}
  /sapmnt/<SID>/exe/uc/rs6000_64/tp import $i <SID> client=<client number> u01234689 pf=/usr/sap/trans/bin/TP_DOMAIN_<SID>.PFL
  RC=$?
  echo "$(date)...Transport ${i} Status RC=${RC}" >> ${TPSTATUS}
  if [ "$RC" -ne 0 ] && [ "$RC" -ne 4 ]; then
    break
  else
    echo "Imported ${i} successfully with code ${RC}."
  fi
done