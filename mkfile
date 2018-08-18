<| emptyenv s6-envdir config env

$ALIGNED_AND_UNALIGNED/%.txt:	$CORRECT_MISMATCHES/%.txt
	set -x
	outdir="$(dirname ${target})"
	mkdir -p "${outdir}"
	add-unaligned-sequences "${prereq}" \
	> "${target}.build" \
	&& mv "${target}.build" $target

$CORRECT_MISMATCHES/%.txt:	$FULLY_ALIGNED/%.txt	$EXTENDED_ALIGNMENT/%.txt
	set -x
	outdir="$(dirname ${target})"
	mkdir -p "${outdir}"
	correct-mismatches \
		"${prereq}" \
	| sort-by-least-mismatch \
	| choose-first-query \
	| ea-header \
	> "${target}.build" \
	&& mv "${target}.build" $target

$EXTENDED_ALIGNMENT/%.txt:	$INCORRECT_MISMATCH/%.txt
	set -x
	outdir="$(dirname ${target})"
	mkdir -p "${outdir}"
	extend-alignment $prereq \
	> "${target}.build" \
	&& mv "${target}.build" $target

$FULLY_ALIGNED/%.txt:	$QUERY_LENGTH/%.txt
	set -x
	outdir="$(dirname ${target})"
	mkdir -p "${outdir}"
	format-fully-aligned-sequences \
		$prereq \
	| fix-malformed-fields \
	> "${target}.build" \
	&& mv "${target}.build" $target

$INCORRECT_MISMATCH/%.txt:	$QUERY_LENGTH/%.txt
	set -x
	outdir="$(dirname ${target})"
	mkdir -p "${outdir}"
	sequences-with-incorrect-mismatch \
		$prereq \
	> "${target}.build" \
	&& mv "${target}.build" $target

$QUERY_LENGTH/%.txt:	$NO_HEADER/%.txt	$QUERYFASTA	$SUBJECT_LENGTH/%.txt
	set -x
	outdir="$(dirname ${target})"
	mkdir -p "${outdir}"
	SUBJECT="${outdir}/${stem}.subjectlength.txt"
	SEQUENCES="${outdir}/${stem}.noheader.txt"
	query-and-subject-length "${SUBJECT}" "${SEQUENCES}" \
	> "${target}.build" \
	&& mv "${target}.build" $target

$NO_HEADER/%.txt:	$JOINT_STRANDS/%.txt
	set -x
	outdir="$(dirname ${target})"
	mkdir -p "${outdir}"
	skip-header $prereq \
	> "${target}.build" \
	&& mv "${target}.build" $target

$SUBJECT_LENGTH/%.txt:	$SUBJECTFASTA
	set -x
	outdir="$(dirname ${target})"
	mkdir -p "${outdir}"
	query-length "${prereq}" \
	> "${target}.build" \
	&& mv "${target}.build" $target

$JOINT_STRANDS/%.txt:	$REQUERY_MINUS_STRAND/%.txt	$SPLIT_STRANDS/%.plus.txt
	set -x
	TMPDIR="`dirname ${target}`"
	mkdir -p "${TMPDIR}"
	remove-strand-column \
		${prereq} \
	> "${target}.build" \
	&& mv "${target}.build" $target

$REQUERY_MINUS_STRAND/%.txt:	$MINUS_STRAND_REVERSE_COMPLEMENT/%.fa
	set -x
	mkdir -p `dirname "$target"`
	query-sequences \
	| choose-best-alignment \
	| blast-header \
	> "${target}.build" \
	&& mv "${target}.build" $target

$MINUS_STRAND_REVERSE_COMPLEMENT/%.fa:	$MINUS_STRAND_SEQUENCES/%.fa
	set -x
	mkdir -p `dirname "$target"`
	fastx_reverse_complement \
		-i $prereq \
		-o /dev/fd/1 \
	> "${target}.build" \
	&& mv "${target}.build" $target

$MINUS_STRAND_SEQUENCES/%.fa:	$SPLIT_STRANDS/%.minus.txt
	set -x
	mkdir -p `dirname "$target"`
	grep -A1 \
		-Ff <(awk '{print $1}' $prereq) \
		$QUERYFASTA \
	| sed '/--/d' \
	| rna2dna \
	> "${target}.build" \
	&& mv "${target}.build" $target

'$SPLIT_STRANDS/(.*)\.(plus|minus).txt':R:	'$BEST_BLAST_ALIGNMENT/\1\.txt'
	set -x
	mkdir -p `dirname "$target"`
	TMPFILE="${target}.build"
	grep  -F "$stem2" $prereq  \
	> "${target}.build" \
	|| test 1 -eq "$?" && true \
	&& mv "${TMPFILE}" "${target}"

$BEST_BLAST_ALIGNMENT/%.txt:	$BLAST_OUTPUT/%.txt
	set -x
	mkdir -p `dirname "$target"`
	choose-best-alignment $prereq \
	> "${target}.build" \
	&& mv "${target}.build" $target

$BLAST_OUTPUT/%.txt:	$INPUT_FILES/%.fa
	set -x
	mkdir -p "$(dirname "${target}")"
	query-sequences \
	| blast-header \
	> "${target}.build" \
	&& mv "${target}.build" "${target}"

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
