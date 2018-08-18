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
	| sed 's/U/T/g' \
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
	handle-unaligned "${prereq}" \
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
	| choose-first-query \
	| sort-by-least-mismatch \
	| ea-header
	> "${target}.build" \
	&& mv "${target}.build" $target

002-short-sequences/%.sequenceadded.txt:	002-short-sequences/%.forprocessing.txt
	set -x
	mkdir -p `dirname "$target"`
	extend-alignment $prereq \
	> "${target}.build" \
	&& mv "${target}.build" $target

002-short-sequences/%.noprocessing.txt: 002-short-sequences/%.querylength.txt
	set -x
	mkdir -p `dirname "$target"`
        awk 'BEGIN {FS="\t"; OFS="\t"} $4 == $13 {print $0,"NA","NA","NA","NA", "NA", "NA", 0}' $prereq \
        | tr -s "\t" > "${target}.build" \
        && mv "${target}.build" $target

002-short-sequences/%.forprocessing.txt:	002-short-sequences/%.querylength.txt
	set -x
	mkdir -p `dirname "$target"`
	sequences-with-incorrect-mismatch \
		$prereq \
	> "${target}.build" \
        && mv "${target}.build" $target

002-short-sequences/%.querylength.txt: 002-short-sequences/%.noheader.txt $QUERYFASTA 002-short-sequences/%.subjectlength.txt
	set -x
	mkdir -p `dirname "$target"`
	SUBJECT="002-short-sequences/${stem}.subjectlength.txt"
	SEQUENCES="002-short-sequences/${stem}.noheader.txt"
	query-and-subject-length "${SUBJECT}" "${SEQUENCES}" \
	> "${target}.build" \
	&& mv "${target}.build" $target

002-short-sequences/%.noheader.txt:	data/%.txt
	set -x
	mkdir -p `dirname "$target"`
	skip-header ${prereq} \
	> "${target}.build" \
	&& mv "${target}.build" $target

002-short-sequences/%.subjectlength.txt:	$SUBJECTFASTA
	query-length ${prereq} \
	> "${target}.build" \
        && mv "${target}.build" $target

#Añadiendo aquellas secuencias que no alinearon en blastn
002-short-sequences/%.final_mismatch.txt:	002-short-sequences/%.extended_mismatches.debug1.txt
	set -x
	mkdir -p `dirname "$target"`
	handle-unaligned "${prereq}" \
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
	| ea-header \
	> "${target}.build" \
	&& mv "${target}.build" $target

002-short-sequences/%.sequenceadded.txt:	002-short-sequences/%.forprocessing.txt
	set -x
	mkdir -p `dirname "$target"`
	extend-alignment $prereq \
	> "${target}.build" \
	&& mv "${target}.build" $target

002-short-sequences/%.noprocessing.txt: 002-short-sequences/%.querylength.txt
	set -x
	mkdir -p `dirname "$target"`
        awk 'BEGIN {FS="\t"; OFS="\t"} $4 == $13 {print $0,"NA","NA","NA","NA", "NA", "NA", 0}' $prereq \
        | tr -s "\t" > "${target}.build" \
        && mv "${target}.build" $target

002-short-sequences/%.forprocessing.txt:	002-short-sequences/%.querylength.txt
	set -x
	mkdir -p `dirname "$target"`
	sequences-with-incorrect-mismatch \
		$prereq \
	> "${target}.build" \
        && mv "${target}.build" $target

002-short-sequences/%.querylength.txt: 002-short-sequences/%.noheader.txt $QUERYFASTA 002-short-sequences/%.subjectlength.txt
	set -x
	mkdir -p `dirname "$target"`
	SUBJECT="002-short-sequences/${stem}.subjectlength.txt"
	SEQUENCES="002-short-sequences/${stem}.noheader.txt"
	query-and-subject-length "${SUBJECT}" "${SEQUENCES}" \
	> "${target}.build" \
	&& mv "${target}.build" $target

002-short-sequences/%.noheader.txt:	data/%.txt
	set -x
	mkdir -p `dirname "$target"`
	skip-header ${prereq} \
	> "${target}.build" \
	&& mv "${target}.build" $target

002-short-sequences/%.subjectlength.txt:	$SUBJECTFASTA
	query-length "${prereq}" \
	> "${target}.build" \
        && mv "${target}.build" $target

###ExtendAlign-Long Sequences###
#
#Añadiendo aquellas secuencias que no alinearon en blastn
003-long-sequences/%.final_mismatch.txt:	003-long-sequences/%.extended_mismatches.txt
	set -x
	mkdir -p `dirname "$target"`
	handle-unaligned "${prereq}" \
	 > "${target}.build" \
	&& mv "${target}.build" $target

003-long-sequences/%.extended_mismatches.txt:	003-long-sequences/%.noprocessing.txt 003-long-sequences/%.sequenceadded.txt
	set -x
	mkdir -p `dirname "$target"`
	correct-mismatches \
		"${prereq}" \
	| choose-first-query \
	| sort-by-least-mismatch \
	| ea-header
	} > "${target}.build" \
	&& mv "${target}.build" $target

003-long-sequences/%.sequenceadded.txt:	003-long-sequences/%.forprocessing.txt
	set -x
	mkdir -p `dirname "$target"`
	extend-alignment $prereq \
	> "${target}.build" \
	&& mv "${target}.build" $target

003-long-sequences/%.noprocessing.txt: 003-long-sequences/%.querylength.txt
	set -x
	mkdir -p `dirname "$target"`
        awk 'BEGIN {FS="\t"; OFS="\t"} $4 == $13 {print $0,"NA","NA","NA","NA", "NA", "NA", 0}' $prereq \
        | tr -s "\t" > "${target}.build" \
        && mv "${target}.build" $target

003-long-sequences/%.forprocessing.txt:	003-long-sequences/%.querylength.txt
	set -x
	mkdir -p `dirname "$target"`
	sequences-with-incorrect-mismatch \
		$prereq \
	> "${target}.build" \
        && mv "${target}.build" $target

003-long-sequences/%.querylength.txt: 003-long-sequences/%.noheader.txt $QUERYFASTA 003-long-sequences/%.subjectlength.txt
	set -x
	mkdir -p `dirname "$target"`
	SUBJECT="003-long-sequences/${stem}.subjectlength.txt"
	SEQUENCES="003-long-sequences/${stem}.noheader.txt"
	query-and-subject-length "${SUBJECT}" "${SEQUENCES}" \
	> "${target}.build" \
	&& mv "${target}.build" $target

003-long-sequences/%.noheader.txt:	data/%.txt
	set -x
	mkdir -p `dirname "$target"`
	skip-header $prereq \
	> "${target}.build" \
	&& mv "${target}.build" $target

003-long-sequences/%.subjectlength.txt:	$SUBJECTFASTA
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
