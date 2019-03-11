#!/bin/bash

## This small script creates the targets for mk, then makes a request for each of them
## It works with the EA fasta file extensions: ".EAfa"
## This files will be defined as the primary prereqs for mk
## The names of the final targets for mk will be defined by adding the extension: ".nsq"
  ## ^^since at the end of the makeblastdb process, *.nsq files are created
find -L . \
  -type f \
  -name "*.EAfa" \
| sed "s#\$#.nsq#" \
| xargs mk $@
  ## ^^ "mk $@" enables to pass mk arguments from the main flow execution
