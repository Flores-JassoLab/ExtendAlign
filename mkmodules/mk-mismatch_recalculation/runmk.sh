#!/bin/bash

## This small script creates the targets for mk, then makes a request for each of them
## It works with the following fasta file extensions: ".extended_nucleotides.tsv"
## This files will be defined as the primary prereqs for mk
## The names of the final targets for mk will be defined by replacing the .extended_nucleotides.tsv extension with: ".recalculatedmm.tsv"
  ## ^^since at the end of the mismatch recalculation process, *.recalculatedmm.tsv files are created
find -L . \
  -type f \
  -name "*.extended_nucleotides.tsv" \
| sed "s#.extended_nucleotides.tsv#.recalculatedmm.tsv#" \
| xargs mk $@
  ## ^^ "mk $@" enables to pass mk arguments from the main flow execution
