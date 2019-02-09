#!/bin/bash

## This small script creates the targets for mk, then makes a request for each of them
## It works with the following fasta file extensions: ".EAcoordinates.tsv"
## This files will be defined as the primary prereqs for mk
## The names of the final targets for mk will be defined by replacing the .tsv extension with: ".extended_nucleotides.tsv"
  ## ^^since at the end of the nucleotide extraction process, *.extended_nucleotides.tsv files are created
find -L . \
  -type f \
  -name "*.EAcoordinates.tsv" \
| sed "s#.tsv#.extended_nucleotides.tsv#" \
| xargs mk $@
  ## ^^ "mk $@" enables to pass mk arguments from the main flow execution
