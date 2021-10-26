#!/bin/bash

## This small script runs a module test with the sample data

echo "[>..] test running this module with data in test/data"
## Remove old test results, if any; then create test/reults dir
rm -rf test/results
mkdir -p test/results
echo "[>>.] results will be created in test/results"
## Execute runmk.sh, it will find the basic example in test/data ; -a arg forces target creation even if results are up to date
## Move results from test/data to test/results
## files are *_EA_report.* files
bash runmk.sh -a \
&& mv test/data/*_EA_report.* test/results \
&& echo "[>>>] Module Test Successful"
