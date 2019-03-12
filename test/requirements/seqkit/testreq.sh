#!/bin/bash

SCRIPT_DIR=$(dirname $0)
seqkit fx2tab --length $SCRIPT_DIR/material/sample.fa
