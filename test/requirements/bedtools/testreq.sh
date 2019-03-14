#!/bin/bash

SCRIPT_DIR=$(dirname $0)
bedtools getfasta -fi $SCRIPT_DIR/material/sample.fa -bed $SCRIPT_DIR/material/sample.bed -fo -
