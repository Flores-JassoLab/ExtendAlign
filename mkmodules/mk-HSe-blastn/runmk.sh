#!/bin/bash

## This small script creates the targets for mk, then makes a request for each of them
## It works with the following fasta file extensions: ".fa , .fna , .fasta"
## This files will be defined as the primary prereqs for mk
## The names of the final targets for mk will be defined by replacing the .fa or .fna or .fasta extension with: ".blastn.tsv"
  ## ^^since at the end of the blastn process, *.blastn.tsv files are created
find -L . \
  -type f \
  -name "*.fa" -o -name "*.fna" -o -name "*.fasta" \
| sed "s#\$#.blastn.tsv#" \
| xargs mk $@
  ## ^^ "mk $@" enables to pass mk arguments from the main flow execution
