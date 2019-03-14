#!/bin/bash

## This small script runs a module test with the sample data

echo "[>..] test running this module with data in test/data"
## Remove old test results, if any; then create test/reults dir
rm -rf test/results
mkdir -p test/results
echo "[>>.] results will be created in test/results"
## Execute runmk.sh, it will find the basic example in test/data ; -a arg forces target creation even if results are up to date
## Move results from test/data to test/results
## files are *.extended_nucleotides.tsv, .bed.tmp and .bedfasta.tmp files
## During runmk.sh execution, pass the test parameters required by the main mk rules
bash runmk.sh -a \
  QUERY_FASTA="../../test/data/query/sample_query.fa" \
    SUBJECT_FASTA="../../test/data/subject/sample_subject.fa" \
&& mv test/data/*.extended_nucleotides.tsv test/data/*.tmp*  test/results \
&& echo "[>>>] Module Test Successful"
