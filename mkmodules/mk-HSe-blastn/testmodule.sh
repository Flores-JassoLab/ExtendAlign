#!/bin/bash

## This small script runs a module test with the sample data

echo "[>..] test running this module with data in test/data"
## Remove old test results, if any; then create test/reults dir
rm -rf test/results
mkdir -p test/results
echo "[>>.] results will be created in test/results"
## Execute runmk.sh, it will find the basic example in test/data ; -a arg forces target creation even if results are up to date
## Move results from test/data to test/results
## files are *.blastn.tsv
## During runmk.sh execution, pass the test parameters required by the main mk rules
bash runmk.sh -a \
  BLAST_DATABASE="../../test/data/blastdb/mmu-premiRNAs22.fa.EAfa" \
  BLAST_THREADS="1" \
  BLAST_STRAND="both" \
  BLAST_MAX_TARGET_SEQS="100" \
  BLAST_EVALUE="10" \
&& mv test/data/*.blastn.tsv test/results \
&& echo "[>>>] Module Test Successful"
