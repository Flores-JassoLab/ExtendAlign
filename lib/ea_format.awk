# This document describes the document format for ExtendAlign(ment)
# and should be used by each awk within this analysis.
#
BEGIN {
#
# 1.  The file MUST be separarated by tabs:
#
	OFS = FS = "\t"
	ORS = RS = "\n"
#
# 2. The columns are for handling the following information:
#
	HEADER = "query_name" OFS \
		"subj_name" OFS \
		"identity" OFS \
		"alignment_length" OFS \
		"mismatch" OFS \
		"gapopen" OFS \
		"query_start" OFS \
		"query_end" OFS \
		"subj_start" OFS \
		"subj_end" OFS \
		"e_value" OFS \
		"bit_score" OFS \
		"strand" OFS \
		"query_length" OFS \
		"subj_length" OFS \
		"query_3_seq" OFS \
		"query_5_seq" OFS \
		"subj_3_seq" OFS \
		"subj_5_seq" OFS \
		"complete_query_seq" OFS \
		"complete_subj_seq" OFS \
		"extended_mismatch" OFS \
		"total_mismatch"

	split(HEADER, columns, OFS)

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
	strand = 13
	query_length = 14
	subj_length = 15
	query_3_seq = 16
	query_5_seq = 17
	subj_3_seq = 18
	subj_5_seq = 19
	complete_query_seq = 20
	complete_subj_seq = 21
	extended_mismatch = 22
	total_mismatch = 23
#
# When a column does not have a value, we use the special value NA.
#
# **FIXME**: There could be a query sequence containing "NA",
# so we should rethink this convention.
#
	NA = "*"
}

function ea_header() {
	print HEADER
}
