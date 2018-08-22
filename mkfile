MKSHELL=/bin/bash

${ALIGNED_AND_UNALIGNED}/%.txt:        ${CORRECT_MISMATCHES}/%.txt	${QUERY_FASTA}/%.fa
       set -x
       outdir="$(dirname ${target})"
       mkdir -p "${outdir}"
       add-unaligned-sequences "${prereq}" \
       > "${target}.build" \
       && mv "${target}.build" $target

${CORRECT_MISMATCHES}/%.txt:	${EXTENDED_ALIGNMENT}/%.txt
	set -x
	outdir="$(dirname ${target})"
	mkdir -p "${outdir}"
	correct-mismatches \
		${prereq} \
	| sort-by-least-mismatch \
	| choose-first-query \
	| ea-header \
	> "${target}.build" \
	&& mv "${target}.build" $target

${EXTENDED_ALIGNMENT}'/(.+)~(.+)\.txt':R:	${QUERY_FASTA}'/\1\.fa'	${SUBJECT_FASTA}'/\2\.fa'	${QUERY_AND_SUBJECT_LENGTH}'/\1\~\2\.txt'
	set -x
	outdir="$(dirname ${target})"
	mkdir -p "${outdir}"
	extend-alignment \
		${prereq} \
	> "${target}.build" \
	&& mv "${target}.build" $target

${QUERY_AND_SUBJECT_LENGTH}'/(.+)~(.+)\.txt':R:	${QUERY_LENGTH}'/\1\.txt'	${SUBJECT_LENGTH}'/\2\.txt'	${BEST_BLAST_ALIGNMENT}'/\1\~\2\.txt'
	set -x
	outdir="$(dirname ${target})"
	mkdir -p "${outdir}"
	query-and-subject-length \
		${prereq} \
	> "${target}.build" \
	&& mv "${target}.build" $target

${QUERY_LENGTH}/%.txt:	${QUERY_FASTA}/%.fa
	set -x
	outdir="$(dirname ${target})"
	mkdir -p "${outdir}"
	sequence-length \
		"${prereq}" \
	> "${target}.build" \
	&& mv "${target}.build" $target

${SUBJECT_LENGTH}/%.txt:	${SUBJECT_FASTA}/%.fa
	set -x
	outdir="$(dirname ${target})"
	mkdir -p "${outdir}"
	sequence-length \
		"${prereq}" \
	> "${target}.build" \
	&& mv "${target}.build" $target

${BEST_BLAST_ALIGNMENT}/%.txt:	${BLAST_OUTPUT}/%.txt
	set -x
	mkdir -p `dirname "$target"`
	choose-best-alignment \
		${prereq} \
	> "${target}.build" \
	&& mv "${target}.build" $target

${BLAST_OUTPUT}'/(.+)~(.+)\.txt':R:	${QUERY_FASTA}'/\1\.fa'	${SUBJECT_FASTA}'/\2\.fa'
	set -x
	mkdir -p "$(dirname "${target}")"
	query-sequences \
		${prereq} \
	> "${target}.build" \
	&& mv "${target}.build" "${target}"

${QUERY_FASTA}/%.fa.fai:	${QUERY_FASTA}/%.fa
	set -x
	mkdir -p "$(dirname "${target}")"
	samtools faidx \
		${prereq}

${SUBJECT_FASTA}/%.fa.fai:	${SUBJECT_FASTA}/%.fa
	set -x
	mkdir -p "$(dirname "${target}")"
	samtools faidx \
		${prereq}

${SUBJECT_FASTA}/%.fa.nhr:	${SUBJECT_FASTA}/%.fa
	set -x
	mkdir -p "$(dirname "${target}")"
	makeblastdb \
		-in ${prereq} \
		-parse_seqids \
		-dbtype nucl

# Unit tests
# ==========
#
# Verify everything works correctly.
#
test	tests:QV:
	cd test
	rm -f tests.log
	./run_tests \
	|| less tests.log
