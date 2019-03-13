#!/bin/bash

SCRIPT_DIR=$(dirname $0)
blastn -query $SCRIPT_DIR/material/query.fa -db $SCRIPT_DIR/material/subject.fa -task blastn
