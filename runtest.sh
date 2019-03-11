#!/bin/bash

nextflow run extend_align.nf \
	--query_fasta test/data/query/hsa-miRNAs22.fa \
	--subject_fasta test/data/subject/sample_subject.fa \
	--output_dir test/results/ \
	--blastn_strand both \
	--number_of_hits best \
&& echo -e "======\n Extend Align: Basic pipeline TEST SUCCESSFUL \n======"
