Module:	mk-bedtools_getfasta
Author(s): Israel Aguilar (iaguilaror@gmail.com)
Date: FEB 2019

TODO:
	(iaguilar) Clean code comments; there is a lot of narrative redundancy;
              ^^although extensive commentary IS necessary since the module performs several complex tasks;
              ^^maybe a devnotes/ dir and files could be used to explain at length what code does and why
  (iaguilar) Create pdf file with images or diagrams explaining the method for fasta extraction,
              ^^since it makes use of bed intermediates and coordinate correction,
              ^^which is really not that human friendly to understand even from extensive code comments

Module description: Adds extended nucleotide sequences to a custom EA blastn results file
	a. extended nucleotides correspond to the flaking sequences on a blastn reported alignment
      ^^(e.g. for a query of length 12 a blastn alignment began at query 4th nt and ended at query 9th nt,
        we extract the correct nucleotides from fasta, which are nucleotides 1 to 3 at 5end, and 10 to 12 at 3'end,
        and add them to the blastn results)
  b. Since in fasta file format sequences can be DNA or RNA, and uppercase or lowercase,
      ^^to enable DNA/RNA and lowercase vs uppercase comparisons in downstream modules,
      ^^this mkmodule creates intermediate harmonized fasta files for queries and subjects;
      ^^harmonized means that U's are changed to T's, and that all nucleotides are extracted as uppercase
      ^^!!IMPORTANT: Do note that when dealing with RNA inputs, extended nucleotides will include T's instead of U's
      ^^  This is made on purpose to harmonize comparison between RNA or DNA and every combination
      ^^  Also, to avoid a bug of bedtools -see issue here: https://github.com/arq5x/bedtools2/issues/682)
      ^^  Since -as of FEB 2019 version- the output of this module is meant to be an intermediate file in the grand scheme of the pipeline
      ^^  this voluntary mistake/bug is meant to die when the temporary files are removed after a successful pipeline run
      ^^  a proposed bugfix would be to implement a downstream mkmodule that auto-detects if query or subject sequence was RNA, and formats the final extended table accordingly to restore U nucleotides were needed
  c. Nucleotide extraction is performed for Query and Subject sequences, accordingly
  d. This module correctly extracts nucleotides even when the blastn hit reports the subject coordinates in the minus strand
      (thanks to a lot of sweat, code, and tears ...)
  e. Extraction is performed in bulk using `bedtools getfasta` command
  f. In short, extensions are extracted to a one-column file, each row corresponds to a blastn hit result
      ^^ 4 one-column files are created, one for query 5'end, one for query 3'end, one for subject 5'end, and one for subject 3'end extensions
  g. bed coordinates for getfasta are temporary modified to avoid a bug were blastn hits with no extension necessary would yield an incomplete number of rows in the results
  h. The multiple on-column file format makes it easy to just paste all the columns into the custom EA blastn results to add the extracted nucleotides to their corresponding row
  i. Do remember that a previous module (mk-get_EA_coordinates) included a failsafe to avoid asking for extension of more nucleotides than can be evenly compared between query and subject extension
      ^^(i.e. if at 5'end, query can be extended 5 nt, but subject can only be extended 3 nt, only 3 nt will be extracted for both, query and subject)

Module Dependencies:
	bedtools getfasta from bedtools v2.27.1 - https://bedtools.readthedocs.io/en/latest/

	Citations:
	Quinlan AR and Hall IM, 2010. BEDTools: a flexible suite of utilities for comparing genomic features. Bioinformatics. 26, 6, pp. 841–842.

Developer Notes:
  devnotes/Correct_fasta_extraction_evidence.xlsx is a file showing proof of correct nucleotide extraction, for plus and minus blastn hits, using results from test data.
    ^^It should be replaced by a proper diagram in pdf or png format.

Input:
  A custom blastn output TAB separated file, with .EAcoordinates.tsv extension.
  Example line(s):
  ````
  qlength qseqid slength sseqid pident length mismatch gaps qstart qend sstart send evalue bitscore sstrand q5end_extension_length q3end_extension_length s5end_extension_length s3end_extension_length overlap5end_extension_length overlap3end_extension_length q5end_extension_start q5end_extension_end q3end_extension_start q3end_extension_end s5end_extension_start s5end_extension_end s3end_extension_start s3end_extension_end strand
  26 hsa-miR-1226-5p.MIMAT0005576 71 mmu-mir-6927.MI0022774 76.923 26 6 0 1 26 1 26 0.039 23.5 plus 0 0 0 45 0 0 1 1 26 26 1 1 26 26 +
  26 hsa-miR-4700-3p.MIMAT0019797 79 mmu-mir-700.MI0004684 69.231 26 8 0 1 26 28 3 2.8 17.3 minus 0 0 51 2 0 0 1 1 26 26 28 28 3 3 -
  ````
  Note(s):
    - For this example, tabs ware replaced by simple white spaces
    - This type of file is created by the mk-get_EA_coordinates module

Output:
  A custom blastn output TAB separated file, with .extended_nucleotides.tsv extension.
  This extended nucleotides file contains extra columns for the EAblastn format and .EAcoordinates.tsv format
  Example line(s):
  ````
  qlength qseqid slength sseqid pident length mismatch gaps qstart qend sstart send evalue bitscore sstrand q5end_extension_length q3end_extension_length s5end_extension_length s3end_extension_length overlap5end_extension_length overlap3end_extension_length q5end_extension_start q5end_extension_end q3end_extension_start q3end_extension_end s5end_extension_start s5end_extension_end s3end_extension_start s3end_extension_end strand query_5end_extended_nt query_3end_extended_nt subject_5end_extended_nt subject_3end_extended_nt
  22 hsa-miR-642b-3p.MIMAT0018444 111 mmu-mir-6396.MI0021931 90.909 11 1 0 11 21 76 86 7.2 15.8 plus 10 1 75 25 10 1 1 11 21 22 66 76 86 87 + AGACACATTT C TATCCGGGCA A
  ````
  Note(s):
    - For this example, tabs ware replaced by simple white spaces
    - Do note the last 4 columns, with the extracted nucleotides

  Output File Column Descriptions: see readme.txt in module mk-get_EA_coordinates for previous column description;
  new columns are described as follows:
  """"
  query_5end_extended_nt: Query extended nucleotides at the 5' end, extracted from the upstream flanking position of the blastn alignment
  query_3end_extended_nt: Query extended nucleotides at the 3' end, extracted from the downstream flanking position of the blastn alignment
  subject_5end_extended_nt: Query extended nucleotides at the 5' end
  subject_3end_extended_nt: Query extended nucleotides at the 5' end
  """"
  Note(s):
    - *extended_nt columns should contain only ATCG characters; for RNA query of subject sequences you have to take into consideration that T's represent U's, changed for the sake of harmony in downstream comparison
    - *extended_nt columns will contain the "." character when no extension was necessary
    - *extended_nt columns will contain the "ERR" value if something went wrong with the extension

Temporary files:

  """"
  *.query.harmonized.fa.tmp : Modified input QUERY FASTA, with "U" nucleotides changed to "T" to enable RNA/DNA comparisons by a downstream module;
                              also, all nucleotides are changed to uppercase.
  *.query.harmonized.fa.tmp.fai : Fasta index created by bedtools when accessing *.query.harmonized.fa.tmp
  *.query5end.bed.tmp : For Query 5' end, modified bed format coordinates taken from the .EAcoordinates.tsv input;
                        modification consists in shifting 1nt the bed coordinates to extract an extra nucleotide;
                        this solves a bug when downstream bedtools operates in coordinates where no fasta extension is neccesary
  *.query5end.bedfasta.tmp :  For Query 5' end, single column file with the extracted nucleotides;
                              no extraction required = "." value; faulty extraction = "ERR" value;
                              each row corresponds to the same row number in the .EAcoordinates.tsv input
  *.query3end.bed.tmp : For Query 3' end, same as *.query5end.bed.tmp
  *.query3end.bedfasta.tmp :  For Query 3' end, same as *.query5end.bedfasta.tmp

  *.subject.harmonized.fa.tmp : For SUBJECT FASTA, same as *.query.harmonized.fa.tmp
  *.subject.harmonized.fa.tmp.fai : Fasta index created by bedtools
  *.subject3end.bed.tmp : For Subject, same as *.query5end.bed.tmp
  *.subject3end.bedfasta.tmp : For Subject, same as *.query5end.bedfasta.tmp
  *.subject5end.bed.tmp : For Subject, same as *.query3end.bed.tmp
  *.subject5end.bedfasta.tmp : For Subject, same as *.query3end.bedfasta.tmp

  """"
Module parameters:

## Path to the original QUERY FASTA used as input of the EA pipeline
# This will be the file where the nucleotides for query extension will be extracted from
QUERY_FASTA="../../test/data/query/hsa-miRNAs22.fa"

## Path to the original SUBJECT FASTA used as input of the EA pipeline
# This will be the file where the nucleotides for subject extension will be extracted from
SUBJECT_FASTA="../../test/data/subject/mmu-premiRNAs22.fa"

Testing the module:

1. Locally test this module by running

	````
	bash testmodule.sh
	````

2. "[>>>] Module Test Successful" should be printed in the console...
