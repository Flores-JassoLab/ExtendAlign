#mk-bedtools_getfasta
**Author(s):** Israel Aguilar-Ordoñez (iaguilaror@gmail.com)
**Date:** February-2019

## TODO:
 (*iaguilar*) Clean code comments. There is a lot of narrative redundancy, although extensive commentary IS necessary since the module performs several complex tasks. Maybe a `devnotes/` dir and files could be used to explain in extend what code does and the reason of it.
 (*iaguilar*) Create pdf file with images or diagrams explaining the method for fasta extraction, since it makes use of bed intermediates and coordinate correction, which is really not that human friendly to understand even from extensive code comments.

## Module description:
Adds extended nucleotide (nt) sequences to ExtendAlign's `HSe-blastn` results file.

1. Extended nucleotides correspond to the flaking sequences on a `HSe-blastn` reported alignment (*e.g.* for a query of length 12 nt a `HSe-blastn` alignment starts at query's 4th nt and ends at query's 9th nt. We extracted the correct nucleotides from fasta, which are nucleotides 1 to 3 at 5'-end, and 10 to 12 at 3'-end, and add them to the `HSe-blastn` results).
2. Since in a fasta file sequences can be DNA or RNA, and uppercase or lowercase, to enable comparisons in downstream modules, this mkmodule creates intermediate harmonized fasta files for queries and subjects. Harmonized means that U's are changed to T's  and all nucleotides are extracted as uppercase.

    **IMPORTANT!** Do note that when dealing with RNA inputs, extended nucleotides will include T's instead of U's. This is made on purpose to harmonize comparisons between RNA or DNA and every combination. Also, to avoid a bug of bedtools -see issue here: https://github.com/arq5x/bedtools2/issues/682. Since -as of February-2019 version- the output of this module is meant to be an intermediate file in the grand scheme of the pipeline. This voluntary mistake/bug is meant to die when the temporary files are removed after a successful pipeline run. A possible bugfix would be to implement a downstream mkmodule that auto-detects if query or subject sequence was RNA, and formats the final extended table accordingly to restore U nucleotides were needed.

3. Nucleotide extractions are performed for both query and qsbject sequences, accordingly.
4. This module extracts nucleotides correctly even when the `HSe-blastn` hit reports the subject coordinates at the minus strand (thanks to a lot of sweat, code, and tears ...).
5. Extractions are performed in bulk using the `bedtools getfasta` command.
6. In short, extensions are done to a one-column file, each row corresponds to a blastn hit result. Four one-column files are created: 1) query 5'end, 2) query 3'end, 3) subject 5'end, and 4) subject 3'end extensions.
7. Bed coordinates for `getfasta` are temporary modified to avoid a bug were `HSe-blastn` hits with no extension necessary would yield an incomplete number of rows in the results.
8. The multiple one-column files format makes it easy to just paste all the columns into ExtendAlign `HSe-blastn` results to add the extracted nucleotides to their corresponding row.
9. Do remember that a previous module (`mk-get_EA_coordinates`) includes a failsafe to avoid asking for extensions of more nucleotides than can be evenly compared between query and subject extension (*i.e.* if at 5'end, query can be extended 5 nt, but subject can only be extended 3 nt, only 3 nt will be extracted for both, query and subject).

## Module Dependencies:
Bedtools getfasta from [bedtools v2.27.1](https://bedtools.readthedocs.io/en/latest/) (Quinlan AR and Hall IM, 2010. BEDTools: a flexible suite of utilities for comparing genomic features. Bioinformatics. 26, 6, pp. 841–842).

### Developer Notes:
`devnotes/Correct_fasta_extraction_evidence.xlsx` is a file showing proof of correct nucleotide extraction, for plus and minus `HSe-blastn` hits, using results from test data. (It should be replaced by a proper diagram in pdf or png format.)

### Input:
A `HSe-blastn` output (TAB separated file) with `.EAcoordinates.tsv` extension.

Example line(s):
```
qlength qseqid slength sseqid pident length mismatch gaps qstart qend sstart send evalue bitscore sstrand q5end_extension_length q3end_extension_length s5end_extension_length s3end_extension_length overlap5end_extension_length overlap3end_extension_length q5end_extension_start q5end_extension_end q3end_extension_start q3end_extension_end s5end_extension_start s5end_extension_end s3end_extension_start s3end_extension_end strand
  26 hsa-miR-1226-5p.MIMAT0005576 71 mmu-mir-6927.MI0022774 76.923 26 6 0 1 26 1 26 0.039 23.5 plus 0 0 0 45 0 0 1 1 26 26 1 1 26 26 +
  26 hsa-miR-4700-3p.MIMAT0019797 79 mmu-mir-700.MI0004684 69.231 26 8 0 1 26 28 3 2.8 17.3 minus 0 0 51 2 0 0 1 1 26 26 28 28 3 3 -
```

**Note(s):**

* For this example, tabs ware replaced by simple white spaces.
* This type of file is created by the `mk-get_EA_coordinates` module.

### Output:
A `HSe-blastn` output (TAB separated file) with `.extended_nucleotides.tsv` extension.

This extended nucleotides file contains extra columns for the common `HSe-blastn` format and `.EAcoordinates.tsv` format.

Example line(s):
```
qlength qseqid slength sseqid pident length mismatch gaps qstart qend sstart send evalue bitscore sstrand q5end_extension_length q3end_extension_length s5end_extension_length s3end_extension_length overlap5end_extension_length overlap3end_extension_length q5end_extension_start q5end_extension_end q3end_extension_start q3end_extension_end s5end_extension_start s5end_extension_end s3end_extension_start s3end_extension_end strand query_5end_extended_nt query_3end_extended_nt subject_5end_extended_nt subject_3end_extended_nt
  22 hsa-miR-642b-3p.MIMAT0018444 111 mmu-mir-6396.MI0021931 90.909 11 1 0 11 21 76 86 7.2 15.8 plus 10 1 75 25 10 1 1 11 21 22 66 76 86 87 + AGACACATTT C TATCCGGGCA A
```

**Note(s):**

* For this example, tabs ware replaced by simple white spaces.
* Do note the last 4 columns, with the extracted nucleotides.

For Output File Column description: see readme.txt in module `mk-get_EA_coordinates` for previous column description.

New columns are described as follows:

`query_5end_extended_nt`: Query extended nucleotides at the 5'-end, extracted from the upstream flanking position of the blastn alignment.
`query_3end_extended_nt`: Query extended nucleotides at the 3'-end, extracted from the downstream flanking position of the blastn alignment.
`subject_5end_extended_nt`: Query extended nucleotides at the 5'-end.
`subject_3end_extended_nt`: Query extended nucleotides at the 5'-end.


**Note(s):**

* `*extended_nt` columns should contain only ATCG characters; for RNA query of subject sequences you have to take into considerations that T's represent U's, changed for the sake of harmony in downstream comparison.
* `*extended_nt` columns will contain the `.` character when no extension was necessary.
* `*extended_nt` columns will contain the `ERR` value if something went wrong with the extension.

## Temporary files:
`*.query.harmonized.fa.tmp`: Modified input query fasta, with U nucleotides changed to T to enable RNA/DNA comparisons by a downstream module. All nucleotides are changed to uppercase.
`*.query.harmonized.fa.tmp.fai`: Fasta index created by bedtools when accessing `*.query.harmonized.fa.tmp`.
`*.query5end.bed.tmp`: For query 5'-end, modified bed format coordinates taken from the .`EAcoordinates.tsv` input. Modifications consists in shifting 1 nt the bed coordinates to extract an extra nucleotide; this solves a bug when downstream bedtools operates in coordinates where no fasta extension is neccesary.
`*.query5end.bedfasta.tmp`:  For query 5'-end, single column file with the extracted nucleotides. When no extention required = `.` value; faulty extention = `ERR` value. Each row corresponds to the same row number in the `*.EAcoordinates.tsv input`.
`*.query3end.bed.tmp`: For query 3'-end, same as `*.query5end.bed.tmp`.
`*.query3end.bedfasta.tmp`:  For query-3' end, same as `*.query5end.bedfasta.tmp`
`*.subject.harmonized.fa.tmp`: For subject fasta, same as `*.query.harmonized.fa.tmp`.
`*.subject.harmonized.fa.tmp.fai`: Fasta index created by bedtools.
`*.subject3end.bed.tmp`: For subject, same as `*.query5end.bed.tmp`.
`*.subject3end.bedfasta.tmp`: For subject, same as `*.query5end.bedfasta.tmp`.
`*.subject5end.bed.tmp`: For subject, same as `*.query3end.bed.tmp`.
`*.subject5end.bedfasta.tmp`: For subject, same as `*.query3end.bedfasta.tmp`.


## Module Parameters:

Path to the original QUERY FASTA used as input of the ExtendAlign pipeline.
This will be the file where the nucleotides for query extension will be extracted from:

```
QUERY_FASTA="../../test/data/query/hsa-miRNAs22.fa"
```

Path to the original SUBJECT FASTA used as input of the ExtendAlign pipeline.
This where nucleotides for subject extension will be extracted from,

```
SUBJECT_FASTA="../../test/data/subject/mmu-premiRNAs22.fa"
```


# Testing the module:

1. Test this module locally by running,

```
bash testmodule.sh
```

2. `[>>>] Module Test Successful` should be printed in the console...
