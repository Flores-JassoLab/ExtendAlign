#!/bin/bash

## This small script creates the targets for mk, then makes a request for each of them
## It works with the following file extensions: ".EAblastn.tsv" or ".EAblastnbesthit.tsv"
## This files will be defined as the primary prereqs for mk
## The names of the final targets for mk will be defined by replacing the .EAblastn.tsv or .EAblastnbesthit.tsv extension with: ".EAcoordinates.tsv"
  ## ^^since at the end of the bed coordinates calculation process, *.EAcoordinates.tsv files are created
find -L . \
  -type f \
  -name "*.EAblastn.tsv" \
  -o -name "*.EAblastnbesthit.tsv" \
| sed \
    -e "s#.EAblastn.tsv#.EAcoordinates.tsv#" \
    -e "s#.EAblastnbesthit.tsv#.EAcoordinates.tsv#" \
| xargs mk $@
  ## ^^ "mk $@" enables to pass mk arguments from the main flow execution
