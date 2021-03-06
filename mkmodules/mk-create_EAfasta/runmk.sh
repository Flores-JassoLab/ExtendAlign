#!/bin/bash

## This small script creates the targets for mk, then makes a request for each of them
## It works with the following fasta file extensions: ".fa , .fna , .fasta"
## This files will be defined as the primary prereqs for mk
## The names of the final targets for mk will be defined by adding the extension: ".EAfa"
  ## ^^since at the end of the process, *.EAfa files are created
find -L . \
  -type f \
  -name "*.fa" -o -name "*.fna" -o -name "*.fasta" \
| sed "s#\$#.EAfa#" \
| xargs mk $@
  ## ^^ "mk $@" enables to pass mk arguments from the main flow execution
