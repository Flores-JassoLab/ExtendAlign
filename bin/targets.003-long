#!/bin/bash

find -L . \
	-type f \
	-name "*.blastn.txt" \
	! -name "*.blastn.total_mismatches.txt" \
| sed "s#.txt#.total_mismatches.txt#" \
| xargs mk $@
