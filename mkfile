<| emptyenv s6-envdir config env

001-blastn/%.pre-mat.blastn.txt:	data/%.fa
	set -x
	mkdir -p "$(dirname "${target}")"
	query-sequences \
	| add-header \
	> "${target}.build" \
	&& mv "${target}.build" "${target}"

002-plus-minus/%.realign.txt:	002-plus-minus/%.minus.rev-comp.blastn.txt	002-plus-minus/%.plus.txt
	set -x
	TMPDIR="`dirname ${target}`"
	mkdir -p "${TMPDIR}"
	minus="${TMPDIR}/${stem}.minus.rev-comp.blastn.txt"
	plus="${TMPDIR}/${stem}.plus.txt"
	cat $minus $plus \
	| awk 'BEGIN{FS=OFS="\t"} {print $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12}' \
	> $target'.build' \
	&& mv $target'.build' $target

002-plus-minus/%.minus.rev-comp.blastn.txt:	002-plus-minus/%.minus.rev-comp.fa
	set -x
	mkdir -p `dirname "$target"`
	query-sequences \
	| choose-best-alignment \
	| add-header \
	> $target'.build' \
	&& mv $target'.build' $target

002-plus-minus/%.minus.rev-comp.fa:	002-plus-minus/%.minus.fa
	set -x
	mkdir -p `dirname "$target"`
	fastx_reverse_complement \
		-i $prereq \
		-o /dev/fd/1 \
		> $target'.build' \
		&& mv $target'.build' $target

002-plus-minus/%.minus.fa:	002-plus-minus/%.minus.txt
	set -x
	mkdir -p `dirname "$target"`
	grep -A1 -f <(awk '{print $1}' \
			$prereq) \
		$QUERYFASTA \
	| sed '/--/d' \
	| sed 's/U/T/g' \
	> $target'.build' \
	&& mv $target'.build' $target

'002-plus-minus/(.*)\.(plus|minus).txt':R:	'002-plus-minus/\1.best-alignment.txt'
	set -x
	mkdir -p `dirname "$target"`
	TMPFILE="${target}.build"
	grep "$stem2" $prereq  \
	> "${target}.build" \
	|| test 1 -eq "$?" && true \
	&& mv "${TMPFILE}" "${target}"

002-plus-minus/%.best-alignment.txt:	data/%.txt
	set -x
	mkdir -p `dirname "$target"`
	choose-best-alignment $prereq \
	> $target'.build' \
	&& mv $target'.build' $target
#Añadiendo aquellas secuencias que no alinearon en blastn
002-short-sequences/%.final_mismatch.txt:	002-short-sequences/%.extended_mismatches.debug1.txt
	set -x
	mkdir -p `dirname "$target"`
	{
	echo "#1_bta	2_bta-length	3_pre-hsa	4_pident	5_length	6_mismatch	7_gapopen	8_qstart	9_qend	10_sstart	11_send	12_evalue	13_bitscore	14_QUERYLENGTH	15_SUBJECTLENGTH	16_QUERY5SEQ	17_QUERY3SEQ	18_SUBJECT5SEQ	19_SUBJECT3SEQ	20_COMPLETEQUERYSEQ	21_COMPLETESUBJECTSEQ	22_EXTENDEDMISMATCH	#23_TOTALMISMATCH" | tr '[:upper:]' '[:lower:]'
	join \
		-a 1 \
			<(awk '$0 ~ /^>/ {name=$0; next}; $0 !~ /^>/ {print name "\t" length($0)}' \
			$QUERYFASTA \
			| sort \
			| sed 's/^>//g' \
			| sed -e '1i\#1_bta\t2_bta-length') \
			<(sort $prereq) \
	| sed 's/ /\t/g' \
	| sed '1d' \
	| awk 'BEGIN {FS="\t"; OFS="\t"} \
		{if (!$3) {print $0,"NA","NA","NA","NA","NA","NA","NA","NA","NA","NA","NA","NA","NA","NA","NA","NA","NA","NA","NA","NA", $2} \
		else {print $0}}' \
	| sort -nk 23
	} > $target'.build' \
	&& mv $target'.build' $target

#Solucion temporal a los casos cuando el query alinea en los extremos del subject
002-short-sequences/%.extended_mismatches.debug1.txt:	002-short-sequences/%.extended_mismatches.txt
	set -x
	mkdir -p `dirname "$target"`
	correct-mismatches \
		$prereq \
	| sort -nk 22 \
	> $target'.build' \
	&& mv $target'.build' $target

002-short-sequences/%.extended_mismatches.txt:	002-short-sequences/%.noprocessing.txt	002-short-sequences/%.sequenceadded.txt
	set -x
	mkdir -p `dirname "$target"`
	#sum-mismatches ${prereq} \
	{
	echo "#1_bta	2_pre-hsa	3_pident	4_length	5_mismatch	6_gapopen	7_qstart	8_qend	9_sstart	10_send 11_evalue	12_bitscore	13_QUERYLENGTH	14_SUBJECTLENGTH	15_QUERY5SEQ	16_QUERY3SEQ	17_SUBJECT5SEQ	18_SUBJECT3SEQ	19_COMPLETEQUERYSEQ	20_COMPLETESUBJECTSEQ	21_EXTENDEDMISMATCH	#22_TOTALMISMATCH" | tr '[:upper:]' '[:lower:]'
	cat $prereq \
	| grep -v ">" \
	| awk \
		'BEGIN{FS=OFS="\t"} \
		{print $0, $5+$6+$21}' \
	| awk '!seen[$1]++' \
	| sort -nk 22
	} > $target'.build' \
	&& mv $target'.build' $target

002-short-sequences/%.sequenceadded.txt:	002-short-sequences/%.forprocessing.txt
	set -x
	mkdir -p `dirname "$target"`
	extend-alignment $prereq \
	> $target'.build' \
	&& mv $target'.build' $target

002-short-sequences/%.noprocessing.txt: 002-short-sequences/%.querylength.txt
	set -x
	mkdir -p `dirname "$target"`
        awk 'BEGIN {FS="\t"; OFS="\t"} $4 == $13 {print $0,"NA","NA","NA","NA", "NA", "NA", 0}' $prereq \
        | tr -s "\t" > $target'.build' \
        && mv $target'.build' $target

002-short-sequences/%.forprocessing.txt:	002-short-sequences/%.querylength.txt
	set -x
	mkdir -p `dirname "$target"`
	awk 'BEGIN {FS="\t"; OFS="\t"} $4 < $13 {print $0}' $prereq \
	> $target'.build' \
        && mv $target'.build' $target

002-short-sequences/%.querylength.txt: 002-short-sequences/%.noheader.txt $QUERYFASTA 002-short-sequences/%.subjectlength.txt
	set -x
	mkdir -p `dirname "$target"`
	{
	while read BLAST_RESULT
	do
	##		echo "estoy procesando.."
	##		echo "$BLAST_RESULT"
		MIRNAID=`echo "$BLAST_RESULT" | cut -f1 `
		QUERYSEQUENCE=`grep -A1 "^>$MIRNAID" $QUERYFASTA | tail -n 1`
		QUERYLENGTH=`echo -n $QUERYSEQUENCE | wc -c`
		SUBJECTID=`echo "$BLAST_RESULT" | cut -f2 `
		SUBJECTLENGTH=`grep ^$SUBJECTID 002-short-sequences/$stem.subjectlength.txt | cut -f2`
		echo "$BLAST_RESULT	$QUERYLENGTH	$SUBJECTLENGTH"
	done < 002-short-sequences/$stem.noheader.txt
	} > $target'.build' \
	&& mv $target'.build' $target

002-short-sequences/%.noheader.txt:	data/%.txt
	set -x
	mkdir -p `dirname "$target"`
	tail -n+2 $prereq > $target'.build' \
	&& mv $target'.build' $target

002-short-sequences/%.subjectlength.txt:	$SUBJECTFASTA
	infoseq \
		-name \
		-length \
		-only $prereq \
	| tr -s " " \
	| tr " " "\t" \
	> $target'.build' \
        && mv $target'.build' $target

#Añadiendo aquellas secuencias que no alinearon en blastn
002-short-sequences/%.final_mismatch.txt:	002-short-sequences/%.extended_mismatches.debug1.txt
	set -x
	mkdir -p `dirname "$target"`
	{
	echo "#1_bta	2_bta-length	3_pre-hsa	4_pident	5_length	6_mismatch	7_gapopen	8_qstart	9_qend	10_sstart	11_send	12_evalue	13_bitscore	14_QUERYLENGTH	15_SUBJECTLENGTH	16_QUERY5SEQ	17_QUERY3SEQ	18_SUBJECT5SEQ	19_SUBJECT3SEQ	20_COMPLETEQUERYSEQ	21_COMPLETESUBJECTSEQ	22_EXTENDEDMISMATCH	#23_TOTALMISMATCH" | tr '[:upper:]' '[:lower:]'
	join \
		-a 1 \
			<(awk '$0 ~ /^>/ {name=$0; next}; $0 !~ /^>/ {print name "\t" length($0)}' \
			$QUERYFASTA \
			| sort \
			| sed 's/^>//g' \
			| sed -e '1i\#1_bta\t2_bta-length') \
			<(sort $prereq) \
	| sed 's/ /\t/g' \
	| sed '1d' \
	| awk 'BEGIN {FS="\t"; OFS="\t"} \
		{if (!$3) {print $0,"NA","NA","NA","NA","NA","NA","NA","NA","NA","NA","NA","NA","NA","NA","NA","NA","NA","NA","NA","NA", $2} \
		else {print $0}}' \
	| sort -nk 23
	} > $target'.build' \
	&& mv $target'.build' $target

#Solucion temporal a los casos cuando el query alinea en los extremos del subject
002-short-sequences/%.extended_mismatches.debug1.txt:	002-short-sequences/%.extended_mismatches.txt
	set -x
	mkdir -p `dirname "$target"`
	correct-mismatches \
		$prereq \
	| sort -nk 22 \
	> $target'.build' \
	&& mv $target'.build' $target

002-short-sequences/%.extended_mismatches.txt:	002-short-sequences/%.noprocessing.txt	002-short-sequences/%.sequenceadded.txt
	set -x
	mkdir -p `dirname "$target"`
	#sum-mismatches ${prereq} \
	{
	echo "#1_bta	2_pre-hsa	3_pident	4_length	5_mismatch	6_gapopen	7_qstart	8_qend	9_sstart	10_send 11_evalue	12_bitscore	13_QUERYLENGTH	14_SUBJECTLENGTH	15_QUERY5SEQ	16_QUERY3SEQ	17_SUBJECT5SEQ	18_SUBJECT3SEQ	19_COMPLETEQUERYSEQ	20_COMPLETESUBJECTSEQ	21_EXTENDEDMISMATCH	#22_TOTALMISMATCH" | tr '[:upper:]' '[:lower:]'
	cat $prereq \
	| grep -v ">" \
	| awk \
		'BEGIN{FS=OFS="\t"} \
		{print $0, $5+$6+$21}' \
	| awk '!seen[$1]++' \
	| sort -nk 22
	} > $target'.build' \
	&& mv $target'.build' $target

002-short-sequences/%.sequenceadded.txt:	002-short-sequences/%.forprocessing.txt
	set -x
	mkdir -p `dirname "$target"`
	extend-alignment $prereq \
	> $target'.build' \
	&& mv $target'.build' $target

002-short-sequences/%.noprocessing.txt: 002-short-sequences/%.querylength.txt
	set -x
	mkdir -p `dirname "$target"`
        awk 'BEGIN {FS="\t"; OFS="\t"} $4 == $13 {print $0,"NA","NA","NA","NA", "NA", "NA", 0}' $prereq \
        | tr -s "\t" > $target'.build' \
        && mv $target'.build' $target

002-short-sequences/%.forprocessing.txt:	002-short-sequences/%.querylength.txt
	set -x
	mkdir -p `dirname "$target"`
	awk 'BEGIN {FS="\t"; OFS="\t"} $4 < $13 {print $0}' $prereq \
	> $target'.build' \
        && mv $target'.build' $target

002-short-sequences/%.querylength.txt: 002-short-sequences/%.noheader.txt $QUERYFASTA 002-short-sequences/%.subjectlength.txt
	set -x
	mkdir -p `dirname "$target"`
	{
	while read BLAST_RESULT
	do
	##		echo "estoy procesando.."
	##		echo "$BLAST_RESULT"
		MIRNAID=`echo "$BLAST_RESULT" | cut -f1 `
		QUERYSEQUENCE=`grep -A1 "^>$MIRNAID" $QUERYFASTA | tail -n 1`
		QUERYLENGTH=`echo -n $QUERYSEQUENCE | wc -c`
		SUBJECTID=`echo "$BLAST_RESULT" | cut -f2 `
		SUBJECTLENGTH=`grep ^$SUBJECTID 002-short-sequences/$stem.subjectlength.txt | cut -f2`
		echo "$BLAST_RESULT	$QUERYLENGTH	$SUBJECTLENGTH"
	done < 002-short-sequences/$stem.noheader.txt
	} > $target'.build' \
	&& mv $target'.build' $target

002-short-sequences/%.noheader.txt:	data/%.txt
	set -x
	mkdir -p `dirname "$target"`
	tail -n+2 $prereq > $target'.build' \
	&& mv $target'.build' $target

002-short-sequences/%.subjectlength.txt:	$SUBJECTFASTA
	infoseq \
		-name \
		-length \
		-only $prereq \
	| tr -s " " \
	| tr " " "\t" \
	> $target'.build' \
        && mv $target'.build' $target

## Add a column for: Total mismatches (will be the sum of blastn reported mm + gapopen + extended mismatches)
## Add a column for: extended mismatches (produced by comparing char by char, the concantenated query 5+3 extensions vs the concatenated subject 5+3 extensions )
003-long-sequences-extend-blast/%.total_mismatches.txt:Q: 003-long-sequences-extend-blast/%.extended.txt
	awk ' BEGIN { FS=OFS="\t"}
		NR == 1 {print "total_mismatches(extended+mismatch+gapopen)","extended_mismatches", $0 }
		NR != 1 {
			## concatenate extended nucleotides by query, or by subject
			Q_EXTENSION=$1$2
			S_EXTENSION=$3$4
			## Split the extended nucleotides by character into an array
			split(Q_EXTENSION, Qnucleotides, "")
			split(S_EXTENSION, Snucleotides, "")
			## restart the mismatch variable
			extended_mismatch=0
			## loop trough the nucleotide arrays and compare by position
			for (i=1; i <= length(Q_EXTENSION); i++) {
				if ( Qnucleotides[i] != Snucleotides[i] )
					extended_mismatch++
			}
			total_mismatch=(extended_mismatch + $8 + $9)
			print total_mismatch, extended_mismatch, $0
		} ' $prereq > $target.build \
		&& mv $target.build $target

## Create columns wih the nucleotide sequences of the 5' and 3' extended regions, both for the query sequence and the subject sequence
003-long-sequences-extend-blast/%.extended.txt:Q: 003-long-sequences-extend-blast/%.best_hit.txt
#	echo "extending mismatchs"
	## check if alignment length is equal to query length, then, nothing needs to be recalculated
	## query legnth is column $16
	## Useful nomeclature will be: QHANG_5_start= Query Hang position start at 5' of the alignment, SHANG_5_start same but for subject
	### QHANG_3_start = Query Hang position end at 3' of the alignment, SHANG_3_start, same but for subject
	### ^^^ Correspondingly the same for end positions, 5', 3', query and subject.
	awk -v REFERENCE="$REFERENCE" '
		BEGIN {FS=OFS="\t"}
	## uncomment for debugg ##	NR==1{print "ORDER", $6, $7, $3, "qlength", $12}
		NR==1{ print "qxtended_seq_5", "qxtended_seq_3", "sxtended_seq_5", "sxtended_seq_3", $0 }
	## NR != 1 to not print header
	## if $3 is equal to $16, alignment legth is equal to query legnth, no extension neccesary
		NR!=1 && $3==$16 {print "NA", "NA", "NA", "NA", $3, $16, $12}
	## if $3 and $16 are different, extention needs to be performed
		NR!=1 && $3!=$16 {
		## Check strandness in field 12
			if ( $12=="plus" ) {
			# Define 5 prime overhang
			# query start is column 6
			# check if query start is 1, then overhang is NA
			# else, overhnag can be calculated for query
				if ($6==1) {
					QHANG_5="NA"
					SHANG_5="NA"
				} else {
					QHANG_5_start=1
					QHANG_5_end=$6-1
					## use substring to split column 26 (query fasta seq), into characters, and recover bases from 1 to query end 5 prime extension
					QHANG_5=substr($26,QHANG_5_start,QHANG_5_end)
					## sstart is column 8
					SHANG_5_start=($8 - QHANG_5_end) ## should be sstart - QHANG_5_end
					SHANG_5_end=($8 - 1) ## should be sstart - 1
					##SHANG_5="Shang5_calculated" ## calculating with samtools faidx
					## Reference contig is column 1
					## Build samtools faidx command
					cmd = (" samtools faidx $REFERENCE "$1":"SHANG_5_start"-"SHANG_5_end" | tail -n1 | tr '[:lower:]' '[:upper:]'")
					cmd | getline SHANG_5
					close (cmd)
				}
			# Define 3 prime overhang
			# query end is column 7
			# query legth is column 16
			# check if query ends at query total length, then overhang is NA
			# else, overhang is calculated for query
				if ( $7==$16 ) {
					QHANG_3="NA"
					SHANG_3="NA"
				} else {
					QHANG_3_start=$7+1
					QHANG_3_end=$16
					QHANG_3=substr($26,QHANG_3_start,QHANG_3_end)
					## Calculate Subject 3prime hang
					## Subject end is column 9
					## thus, extension starts at end+1
					SHANG_3_start=$9+1
					## extension ends at subject end + ( QHANG_3_end - QHANG_3_start )
					## alternatively could be equal to subject end + number of characters at QHANG_3
					SHANG_3_end = $9 + length(QHANG_3)
					##SHANG_3="Shang3_calculated" ## calculating with samtools faidx
					## Reference contig is column 1
					## Build samtools faidx command
					cmd = (" samtools faidx $REFERENCE "$1":"SHANG_3_start"-"SHANG_3_end" | tail -n1 | tr '[:lower:]' '[:upper:]'")
					cmd | getline SHANG_3
					close (cmd)
				}
			## uncomment for debugg ## print "calculate someshit, NO STRAND CORRECTION REQUIRED", "seq:"$26, "mismatches:"$4, "gapopen:"$5, "qstart:"$6, "qend:"$7, "aln_len:"$3, "contig:"$1, "substart:"$8, "subend:"$9, "qlen:"$16, $12, "qhang5: "QHANG_5, "qhang3:"QHANG_3, "shang5:"SHANG_5, "shang3:"SHANG_3
			print QHANG_5, QHANG_3, SHANG_5, SHANG_3, $0
			}
			else if ( $12=="minus") {
			## For minus strand, query hangs both 5 and 3, are calculated the same as for plus strand
			## For minus strand, subject extension should be extracted differently... not sure how yet
			# Define 5 prime overhang
				if ($6==1) {
					QHANG_5="NA"
					SHANG_5="NA"
				} else {
					QHANG_5_start=1
					QHANG_5_end=$6-1
					## use substring to split column 26 (query fasta seq), into characters, and recover bases from 1 to query end 5 prime extension
					QHANG_5=substr($26,QHANG_5_start,QHANG_5_end)
				## must get creative with how to extract the correct 5 overhang for subjects in the minus strand
				## The secret is in extracting the reference plus 3overhang, and reverse complement it
				## That makes it comparable to the reported query 5sequence
					#SHANG_5="5hang_calculated"
					## sstart is column 8
					SHANG_5_start=($8 + 1) ## should be sstart + 1 since it is reported in minus strand
					SHANG_5_end=($8 + length(QHANG_5) ) ## should be sstart + the number of nucleotides extracted for the query
					##SHANG_5="Shang5_calculated" ## calculating with samtools faidx
					## Reference contig is column 1
					## Build samtools faidx command
					cmd = (" samtools faidx $REFERENCE "$1":"SHANG_5_start"-"SHANG_5_end" | tail -n1 | tr '[:lower:]' '[:upper:]' | rev | tr 'ATCG' 'TAGC' ")
					cmd | getline SHANG_5
					close (cmd)
				}
			# Define 3 prime overhang
				if ( $7==$16 ) {
					QHANG_3="NA"
					SHANG_3="NA"
				} else {
					QHANG_3_start=$7+1
					QHANG_3_end=$16
					QHANG_3=substr($26,QHANG_3_start,QHANG_3_end)
				## must get creative again to extract subject 3 overhang from the minus strand
				## The secret is in extracting the reference plus 5overhang, and reverse complement it
				## That makes it comparable to the reported query 3sequence
					#SHANG_3="3hang_calculated"
					## Subject end is column 9
					## thus, extension for minus starts at subend - length of QHANG_3
					SHANG_3_start=($9 - length(QHANG_3)  )
					## extension ends at subject end - 1
					SHANG_3_end=($9 - 1)
					##SHANG_3="Shang3_calculated" ## calculating with samtools faidx
					## Reference contig is column 1
					## Build samtools faidx command
					cmd = (" samtools faidx $REFERENCE "$1":"SHANG_3_start"-"SHANG_3_end" | tail -n1 | tr '[:lower:]' '[:upper:]' | rev | tr 'ATCG' 'TAGC' ")
					cmd | getline SHANG_3
					close (cmd)
				}
			## uncomment for debugg ## print "STRAND CORRECTION REQUIRED", "seq:"$26, "mismatches:"$4, "gapopen:"$5, "qstart:"$6, "qend:"$7, "aln_len:"$3, "contig:"$1, "substart:"$8, "subend:"$9, "qlen:"$16, $12, "qhang5: "QHANG_5, "qhang3:"QHANG_3, "shang5:"SHANG_5, "shang3:"SHANG_3
			print QHANG_5, QHANG_3, SHANG_5, SHANG_3, $0
			}
		}
	' $prereq > $target.build \
	&& mv $target.build $target

003-long-sequences-extend-blast/%.best_hit.txt: 003-long-sequences-extend-blast/%.txt
	echo "getting best hits"
	sort -k17,17 $prereq \
	| awk '!seen[$17]++' \
	> $target.build \
	&& mv $target.build $target
MKSHELL=/bash

< config.mk
###ExtendAlign-Long Sequences###
#
#Añadiendo aquellas secuencias que no alinearon en blastn
003-long-sequences/%.final_mismatch.txt:	003-long-sequences/%.extended_mismatches.txt
	set -x
	mkdir -p `dirname "$target"`
	{
	echo "#1_bta	2_bta-length	3_pre-hsa	4_pident	5_length	6_mismatch	7_gapopen	8_qstart	9_qend	10_sstart	11_send	12_evalue	13_bitscore	14_QUERYLENGTH	15_SUBJECTLENGTH	16_QUERY5SEQ	17_QUERY3SEQ	18_SUBJECT5SEQ	19_SUBJECT3SEQ	20_COMPLETEQUERYSEQ	21_COMPLETESUBJECTSEQ	22_EXTENDEDMISMATCH	#23_TOTALMISMATCH" | tr '[:upper:]' '[:lower:]'
	join \
		-a 1 \
			<(awk '$0 ~ /^>/ {name=$0; next}; $0 !~ /^>/ {print name "\t" length($0)}' \
			$QUERYFASTA \
			| sort \
			| sed 's/^>//g' \
			| sed -e '1i\#1_bt1\t2_bta-length') \
			<(sort $prereq) \
	| sed 's/ /\t/g' \
	| sed '1d' \
	| awk 'BEGIN {FS="\t"; OFS="\t"} \
		{if (!$3) {print $0,"NA","NA","NA","NA","NA","NA","NA","NA","NA","NA","NA","NA","NA","NA","NA","NA","NA","NA","NA","NA", $2} \
		else {print $0}}' \
	| sort -nk 23
	} > $target'.build' \
	&& mv $target'.build' $target

003-long-sequences/%.extended_mismatches.txt:	003-long-sequences/%.noprocessing.txt 003-long-sequences/%.sequenceadded.txt
	set -x
	mkdir -p `dirname "$target"`
	#cat $prereq | grep ">" > $target.samtools-failed.txt.build || echo "No errors found" \
	#&& mv $target.samtools-failed.txt.build $target.samtools-failed.txt
	{
	echo "#1_bta	2_pre-hsa	3_pident	4_length	5_mismatch	6_gapopen	7_qstart	8_qend	9_sstart	10_send	11_evalue	12_bitscore	13_QUERYLENGTH	14_SUBJECTLENGTH	15_QUERY5SEQ	16_QUERY3SEQ	17_SUBJECT5SEQ	18_SUBJECT3SEQ	19_COMPLETEQUERYSEQ	20_COMPLETESUBJECTSEQ	21_EXTENDEDMISMATCH	#22_TOTALMISMATCH" | tr '[:upper:]' '[:lower:]'
	cat $prereq | grep -v ">" \
	| awk \
		'BEGIN{FS=OFS="\t"} \
		{print $0, $5+$6+$21}' \
	| awk '!seen[$1]++' \
	| sort -nk 22
	} > $target'.build' \
	&& mv $target'.build' $target

003-long-sequences/%.sequenceadded.txt:	003-long-sequences/%.forprocessing.txt
	set -x
	mkdir -p `dirname "$target"`
	extend-alignment $prereq \
	> $target'.build' \
	&& mv $target'.build' $target

003-long-sequences/%.noprocessing.txt: 003-long-sequences/%.querylength.txt
	set -x
	mkdir -p `dirname "$target"`
        awk 'BEGIN {FS="\t"; OFS="\t"} $4 == $13 {print $0,"NA","NA","NA","NA", "NA", "NA", 0}' $prereq \
        | tr -s "\t" > $target'.build' \
        && mv $target'.build' $target

003-long-sequences/%.forprocessing.txt:	003-long-sequences/%.querylength.txt
	set -x
	mkdir -p `dirname "$target"`
	awk 'BEGIN {FS="\t"; OFS="\t"} $4 < $13 {print $0}' $prereq \
	> $target'.build' \
        && mv $target'.build' $target

003-long-sequences/%.querylength.txt: 003-long-sequences/%.noheader.txt $QUERYFASTA 003-long-sequences/%.subjectlength.txt
	set -x
	mkdir -p `dirname "$target"`
	{
	while read BLAST_RESULT
	do
	##		echo "estoy procesando.."
	##		echo "$BLAST_RESULT"
		MIRNAID=`echo "$BLAST_RESULT" | cut -f1 `
		QUERYSEQUENCE=`grep -A1 "^>$MIRNAID" $QUERYFASTA | tail -n 1`
		QUERYLENGTH=`echo -n $QUERYSEQUENCE | wc -c`
		SUBJECTID=`echo "$BLAST_RESULT" | cut -f2 `
		SUBJECTLENGTH=`grep ^$SUBJECTID 003-long-sequences/$stem.subjectlength.txt | cut -f2`
		echo "$BLAST_RESULT	$QUERYLENGTH	$SUBJECTLENGTH"
	done < 003-long-sequences/$stem.noheader.txt
	} > $target'.build' \
	&& mv $target'.build' $target

003-long-sequences/%.noheader.txt:	data/%.txt
	set -x
	mkdir -p `dirname "$target"`
	tail -n+2 $prereq > $target'.build' \
	&& mv $target'.build' $target

003-long-sequences/%.subjectlength.txt:	$SUBJECTFASTA
	infoseq \
		-name \
		-length \
		-only $prereq \
	| tr -s " " \
	| tr " " "\t" \
	> $target'.build' \
        && mv $target'.build' $target
