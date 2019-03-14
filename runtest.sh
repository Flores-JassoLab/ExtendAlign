#!/bin/bash

## Check that command requirements are reachable from CLI
## then remove test/results dir
## then Run NF
bash test/requirements/dependency_checker.sh \
&& echo -e "======\n Testing NF execution \n======" \
&& rm -rf test/results/ \
&& nextflow run extend_align.nf \
	--query_fasta test/data/query/sample_query.fa \
	--subject_fasta test/data/subject/sample_subject.fa \
	--output_dir test/results/ \
	--blastn_strand both \
	--number_of_hits best \
&& echo -e "======\n Extend Align: Basic pipeline TEST SUCCESSFUL \n======"
