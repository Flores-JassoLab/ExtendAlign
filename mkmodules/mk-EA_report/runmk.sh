#!/bin/bash

## This small script creates the targets for mk, then makes a request for each of them
## It works with the following file extensions: ".with_nohits.tsv"
## This files will be defined as the primary prereqs for mk
## The names of the final targets for mk will be defined by replacing the .with_nohits.tsv extension with: "_EA_report.tsv"
  ## ^^since at the end of the summary process, *_EA_report.tsv files are created
find -L . \
  -type f \
  -name "*.with_nohits.tsv" \
| sed "s#.with_nohits.tsv#_EA_report.tsv#" \
| xargs mk $@
  ## ^^ "mk $@" enables to pass mk arguments from the main flow execution
