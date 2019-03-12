#!/bin/bash

SCRIPT_DIR=$(dirname $0)

echo "[>..] Running test for required software at $SCRIPT_DIR"
echo "====="
for REQ in $(find $SCRIPT_DIR -mindepth 1 -maxdepth 1 -type d)
do
  TOOL=$(basename $REQ)
  bash $REQ/testreq.sh > /dev/null
  EXSTATUS=$?
  if [ "$EXSTATUS" == 0 ]
  then
    echo "[SUCCESS] $TOOL is accessible from command line"
  fi
  if [ "$EXSTATUS" != 0 ]
  then
    echo "[!!FAIL] $TOOL is not installed or it is not in your PATH"
    exit 1
  fi
done
echo -e "=====\n[>>>] All comand line requirements are reachable"
