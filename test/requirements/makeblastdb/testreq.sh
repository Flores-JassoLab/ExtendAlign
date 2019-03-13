#!/bin/bash

SCRIPT_DIR=$(dirname $0)

makeblastdb -in $SCRIPT_DIR/material/subject.fa -parse_seqids -dbtype nucl \
&& rm $SCRIPT_DIR/material/subject.fa.*
