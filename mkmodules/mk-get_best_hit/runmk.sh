#!/bin/bash

## This small script creates the targets for mk, then makes a request for each of them
## It works with the following fasta file extensions: ".blastn.tsv"
## This files will be defined as the primary prereqs for mk
## The names of the final targets for mk will be defined by replacing the .blastn.tsv extension with: ".blastnbesthit.tsv"
  ## ^^since at the end of the best hit extraction process, *.blastnbesthit.tsv files are created
find -L . \
  -type f \
  -name "*.blastn.tsv" \
| sed "s#.blastn.tsv#.blastnbesthit.tsv#" \
| xargs mk $@
  ## ^^ "mk $@" enables to pass mk arguments from the main flow execution
