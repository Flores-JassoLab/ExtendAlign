#!/bin/bash

## This small script creates the targets for mk, then makes a request for each of them
## It works with the following fasta file extensions: ".recalculatedmm.tsv"
## This files will be defined as the primary prereqs for mk
## The names of the final targets for mk will be defined by replacing the .recalculatedmm.tsv extension with: ".with_nohits.tsv"
  ## ^^since at the end of the no hit queries appending process, *.with_nohits.tsv files are created
find -L . \
  -type f \
  -name "*.recalculatedmm.tsv" \
| sed "s#.recalculatedmm.tsv#.with_nohits.tsv#" \
| xargs mk $@
  ## ^^ "mk $@" enables to pass mk arguments from the main flow execution
