# This document describes the document format for ExtendAlign(ment)
# and should be used by each awk within this analysis.
#
BEGIN {
#
# 1.  The file MUST be separarated by tabs:
#
	RS = "(^|\n)>"
	FS = "\n"
#
# 2. The columns are for handling the following information:
#
	name = 1
	sequence = 2
}
