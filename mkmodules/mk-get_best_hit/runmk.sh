#!/bin/bash

## This small script creates the targets for mk, then makes a request for each of them
## It works with the following file extensions: ".EAblastn.tsv"
## This files will be defined as the primary prereqs for mk
## The names of the final targets for mk will be defined by replacing the .blastn.tsv extension with: ".blastnbesthit.tsv"
  ## ^^since at the end of the best hit extraction process, *.EAblastnbesthit.tsv files are created
find -L . \
  -type f \
  -name "*.EAblastn.tsv" \
| sed "s#.EAblastn.tsv#.EAblastnbesthit.tsv#" \
| xargs mk $@
  ## ^^ "mk $@" enables to pass mk arguments from the main flow execution
