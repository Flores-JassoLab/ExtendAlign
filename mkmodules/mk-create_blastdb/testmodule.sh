#!/bin/bash

## This small script runs a module test with the sample data

echo "[>..] test running this module with data in test/data"
## Remove old test results, if any; then create test/reults dir
rm -rf test/results
mkdir -p test/results
echo "[>>.] results will be created in test/results"
## Execute runmk.sh, it will find the basic example in test/data ; -a arg forces target creation even if results are up to date
## Move results from test/data to test/results
## files are *.nhr, *.nin, *.nog, *.nsd, *.nsi, *.nsq
##	^^ so we simplify mv using *.n* as pattern
##  ^^ Also copy the remaining *.EAfa files from test/data, since they are referenced by blastn later
bash runmk.sh -a \
&& mv test/data/*.n* test/results \
&& cp test/data/* test/results \
&& echo "[>>>] Module Test Successful"
