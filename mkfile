<| emptyenv s6-envdir config env

ALIGNED_AND_UNALIGNED=analysis/006-aligned-and-unaligned

$ALIGNED_AND_UNALIGNED/%.final_mismatch.txt:	$CORRECT_MISMATCHES/%.txt
	set -x
	outdir="$(dirname ${target})"
	mkdir -p "${outdir}"
	add-unaligned-sequences "${prereq}" \
	> "${target}.build" \
	&& mv "${target}.build" $target

CORRECT_MISMATCHES=analysis/005-correct-mismatches

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

EXTENDED_ALIGNMENT=analysis/004-extend-alignment

$EXTENDED_ALIGNMENT/%.txt:	$INCORRECT_MISMATCH/%.txt
	set -x
	outdir="$(dirname ${target})"
	mkdir -p "${outdir}"
	extend-alignment $prereq \
	> "${target}.build" \
	&& mv "${target}.build" $target

FULLY_ALIGNED=analysis/003-fully-aligned

$FULLY_ALIGNED/%.txt:	$QUERY_LENGTH/%.txt
	set -x
	outdir="$(dirname ${target})"
	mkdir -p "${outdir}"
	format-fully-aligned-sequences \
		$prereq \
	| fix-malformed-fields \
	> "${target}.build" \
	&& mv "${target}.build" $target

INCORRECT_MISMATCH=analysis/003-incorrect-mismatch

$INCORRECT_MISMATCH/%.txt:	$QUERY_LENGTH/%.txt
	set -x
	outdir="$(dirname ${target})"
	mkdir -p "${outdir}"
	sequences-with-incorrect-mismatch \
		$prereq \
	> "${target}.build" \
	&& mv "${target}.build" $target

QUERYLENGTH=analysis/002-query-length

$QUERY_LENGTH/%.txt:	$NO_HEADER/%.txt	$QUERYFASTA	$SUBJECT_LENGHT/%.subjectlength.txt
	set -x
	outdir="$(dirname ${target})"
	mkdir -p "${outdir}"
	SUBJECT="${outdir}/${stem}.subjectlength.txt"
	SEQUENCES="${outdir}/${stem}.noheader.txt"
	query-and-subject-length "${SUBJECT}" "${SEQUENCES}" \
	> "${target}.build" \
	&& mv "${target}.build" $target

NO_HEADER=analysis/001-noheader

$NO_HEADER/%.txt:	$JOINT_STRANDS/%.txt
	set -x
	outdir="$(dirname ${target})"
	mkdir -p "${outdir}"
	skip-header $prereq \
	> "${target}.build" \
	&& mv "${target}.build" $target

SUBJECT_LENGTH=analysis/subject-length

$SUBJECT_LENGTH/%.txt:	$SUBJECTFASTA
	set -x
	outdir="$(dirname ${target})"
	mkdir -p "${outdir}"
	query-length "${prereq}" \
	> "${target}.build" \
	&& mv "${target}.build" $target

JOINT_STRANDS=analysis/007-joint-strands

$JOINT_STRANDS/%.txt:	$REQUERY_MINUS_STRAND/%.txt	$SPLIT_STRANDS/%.plus.txt
	set -x
	TMPDIR="`dirname ${target}`"
	mkdir -p "${TMPDIR}"
	remove-strand-column \
		${prereq} \
	> "${target}.build" \
	&& mv "${target}.build" $target

REQUERY_MINUS_STRAND=analysis/006-requery-minus

$REQUERY_MINUS_STRAND/%.txt:	$MINUS_STRAND_REVERSE_COMPLEMENT/%.fa
	set -x
	mkdir -p `dirname "$target"`
	query-sequences \
	| choose-best-alignment \
	| blast-header \
	> "${target}.build" \
	&& mv "${target}.build" $target

MINUS_STRAND_REVERSE_COMPLEMENT=analysis/005-minus-complement
$MINUS_STRAND_REVERSE_COMPLEMENT/%.fa:	$MINUS_STRAND_SEQUENCES/%.fa
	set -x
	mkdir -p `dirname "$target"`
	fastx_reverse_complement \
		-i $prereq \
		-o /dev/fd/1 \
	> "${target}.build" \
	&& mv "${target}.build" $target

MINUS_STRAND_SEQUENCES=analysis/004-minus-strand

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

SPLIT_STRANDS=analysis/003-split-strands

'$SPLIT_STRANDS/(.*)\.(plus|minus).txt':R:	'$BEST_BLAST_ALIGNMENT/\1\.txt'
	set -x
	mkdir -p `dirname "$target"`
	TMPFILE="${target}.build"
	grep  -F "$stem2" $prereq  \
	> "${target}.build" \
	|| test 1 -eq "$?" && true \
	&& mv "${TMPFILE}" "${target}"

BEST_BLAST_ALIGNMENT=analysis/002-best-blast-alignment

$BEST_BLAST_ALIGNMENT/%.txt:	$BLAST_OUTPUT/%.txt
	set -x
	mkdir -p `dirname "$target"`
	choose-best-alignment $prereq \
	> "${target}.build" \
	&& mv "${target}.build" $target

INPUT_FILES=data
BLAST_OUTPUT=analysis/001-blast

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
