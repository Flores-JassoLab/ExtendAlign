<| emptyenv s6-envdir config env

001-blastn/%.pre-mat.blastn.txt:	data/%.fa
	set -x
	mkdir -p "$(dirname "${target}")"
	query-sequences \
	| blast-header \
	> "${target}.build" \
	&& mv "${target}.build" "${target}"

002-plus-minus/%.realign.txt:	002-plus-minus/%.minus.rev-comp.blastn.txt	002-plus-minus/%.plus.txt
	set -x
	TMPDIR="`dirname ${target}`"
	mkdir -p "${TMPDIR}"
	remove-strand-column \
		${prereq} \
	> "${target}.build" \
	&& mv "${target}.build" $target

002-plus-minus/%.minus.rev-comp.blastn.txt:	002-plus-minus/%.minus.rev-comp.fa
	set -x
	mkdir -p `dirname "$target"`
	query-sequences \
	| choose-best-alignment \
	| blast-header \
	> "${target}.build" \
	&& mv "${target}.build" $target

002-plus-minus/%.minus.rev-comp.fa:	002-plus-minus/%.minus.fa
	set -x
	mkdir -p `dirname "$target"`
	fastx_reverse_complement \
		-i $prereq \
		-o /dev/fd/1 \
	> "${target}.build" \
	&& mv "${target}.build" $target

002-plus-minus/%.minus.fa:	002-plus-minus/%.minus.txt
	set -x
	mkdir -p `dirname "$target"`
	grep -A1 \
		-Ff <(awk '{print $1}' $prereq) \
		$QUERYFASTA \
	| sed '/--/d' \
	| rna2dna \
	> "${target}.build" \
	&& mv "${target}.build" $target

'002-plus-minus/(.*)\.(plus|minus).txt':R:	'002-plus-minus/\1.best-alignment.txt'
	set -x
	mkdir -p `dirname "$target"`
	TMPFILE="${target}.build"
	grep  -F "$stem2" $prereq  \
	> "${target}.build" \
	|| test 1 -eq "$?" && true \
	&& mv "${TMPFILE}" "${target}"

002-plus-minus/%.best-alignment.txt:	data/%.txt
	set -x
	mkdir -p `dirname "$target"`
	choose-best-alignment $prereq \
	> "${target}.build" \
	&& mv "${target}.build" $target

#Añadiendo aquellas secuencias que no alinearon en blastn
002-short-sequences/%.final_mismatch.txt:	002-short-sequences/%.extended_mismatches.debug1.txt
	set -x
	mkdir -p `dirname "$target"`
	add-unaligned-sequences "${prereq}" \
	> "${target}.build" \
	&& mv "${target}.build" $target

#Añadiendo aquellas secuencias que no alinearon en blastn
002-short-sequences/%.final_mismatch.txt:	002-short-sequences/%.extended_mismatches.debug1.txt
	set -x
	mkdir -p `dirname "$target"`
	add-unaligned-sequences "${prereq}" \
	> "${target}.build" \
	&& mv "${target}.build" $target

###ExtendAlign-Long Sequences###
#
#Añadiendo aquellas secuencias que no alinearon en blastn
003-long-sequences/%.final_mismatch.txt:	003-long-sequences/%.extended_mismatches.txt
	set -x
	mkdir -p `dirname "$target"`
	add-unaligned-sequences "${prereq}" \
	 > "${target}.build" \
	&& mv "${target}.build" $target

#Solucion temporal a los casos cuando el query alinea en los extremos del subject
002-short-sequences/%.extended_mismatches.debug1.txt:	002-short-sequences/%.extended_mismatches.txt
	set -x
	mkdir -p `dirname "$target"`
	correct-mismatches \
		$prereq \
	| sort-by-least-mismatch \
	> "${target}.build" \
	&& mv "${target}.build" $target

#Solucion temporal a los casos cuando el query alinea en los extremos del subject
002-short-sequences/%.extended_mismatches.debug1.txt:	002-short-sequences/%.extended_mismatches.txt
	set -x
	mkdir -p `dirname "$target"`
	correct-mismatches \
		$prereq \
	| sort-by-least-mismatch \
	> "${target}.build" \
	&& mv "${target}.build" $target

002-short-sequences/%.extended_mismatches.txt:	002-short-sequences/%.noprocessing.txt	002-short-sequences/%.sequenceadded.txt
	set -x
	mkdir -p `dirname "$target"`
	correct-mismatches \
		"${prereq}" \
	| sort-by-least-mismatch \
	| choose-first-query \
	| ea-header
	> "${target}.build" \
	&& mv "${target}.build" $target

002-short-sequences/%.extended_mismatches.txt:	002-short-sequences/%.noprocessing.txt	002-short-sequences/%.sequenceadded.txt
	set -x
	mkdir -p `dirname "$target"`
	correct-mismatches \
		"${prereq}" \
	| sort-by-least-mismatch \
	| choose-first-query \
	| ea-header \
	> "${target}.build" \
	&& mv "${target}.build" $target

003-long-sequences/%.extended_mismatches.txt:	003-long-sequences/%.noprocessing.txt 003-long-sequences/%.sequenceadded.txt
	set -x
	mkdir -p `dirname "$target"`
	correct-mismatches \
		"${prereq}" \
	| sort-by-least-mismatch \
	| choose-first-query \
	| ea-header \
	> "${target}.build" \
	&& mv "${target}.build" $target

EXTEND_ALIGNMENT=analysis/004-extend-alignment

$EXTEND_ALIGNMENT/%.txt:	$INCORRECT_MISMATCH/%.txt
	set -x
	outdir="$(dirname ${target})"
	mkdir -p "${outdir}"
	extend-alignment $prereq \
	> "${target}.build" \
	&& mv "${target}.build" $target

FULLY_ALIGNED=analysis/003-fully-aligned

$FULLY_ALIGNED/%.txt:	$QUERY_LENGTH/%.txt
	set -x
	mkdir -p `dirname "$target"`
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

$NO_HEADER/%.txt:	data/%.txt
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
