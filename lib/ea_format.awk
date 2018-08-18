# This document describes the document format for ExtendAlign(ment)
# and should be used by each awk within this analysis.
#
BEGIN {
#
# 1.  The file MUST be separarated by tabs:
#
	OFS = FS = "\t"
#
# 2. The columns are for handling the following information:
#
	query_name = 1
	subj_name = 2
	identity = 3
	alignment_length = 4
	mismatch = 5
	gapopen = 6
	query_start = 7
	query_end = 8
	subj_start = 9
	subj_end = 10
	e_value = 11
	bit_score = 12
	query_length = 13
	subj_length = 14
	query_3_seq = 15
	query_5_seq = 16
	subj_3_seq = 17
	subj_5_seq = 18
	complete_query_seq = 19
	complete_subj_seq = 20
	extended_mismatch = 21
	total_mismatch = 22
#
# When a column does not have a value, we use the special value NA.
#
# **FIXME**: There could be a query sequence containing "NA",
# so we should rethink this convention.
#
	NA = "NA"
}

function ea_header() {
	print "query_name", "subj_name", "identity", "alignment_length", "mismatch", \
	"gapopen", "query_start", "query_end", "subj_start", "subj_end", "e_value", \
	"bit_score", "query_length", "subj_length", "query_3_seq", "query_5_seq", \
	"subj_3_seq", "subj_5_seq", "complete_query_seq", "complete_subj_seq", \
	 "extended_mismatch", "total_mismatch"
}
