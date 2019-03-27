# mk-EA_report  
**Author(s):** Mariana Flores-Torres (mariana.flo.tor@gmail.com), Israel Aguilar-Ordoñez (iaguilaror@gmail.com)  
**Date:** February-2019  

## TODO:
*( iaguilar )* update example lines for output

## Module description:
Generate a summarized ExtendAlign results table.

1. This module parses the complex ExtendAlign `.with_nohits.tsv` with no hits table that contains every calculation performed by ExtendAlign.

2. This module extracts only the columns that are ultimately informative to the user.

3. During this first versions, this sumarized report includes the `HSe-blastn` only calculated `pident`, to make contrast with the Extend Align recalculated `pident`.

## Module Dependencies:
NONE

### Input:
A custom `HSe-blastn` output TAB separated file, with `.with_nohits.tsv` extension.

Example line(s):
```
qlength qseqid slength sseqid pident length mismatch gaps qstart qend sstart send evalue bitscore sstrand qseq sseq qmismatch_in_gap smismatch_in_gap query_mismatch subject_mismatch q5end_extension_length q3end_extension_length s5end_extension_length s3end_extension_length overlap5end_extension_length overlap3end_extension_length q5end_extension_start q5end_extension_end q3end_extension_start q3end_extension_end s5end_extension_start s5end_extension_end s3end_extension_start s3end_extension_end strand query_5end_extended_nt query_3end_extended_nt subject_5end_extended_nt subject_3end_extended_nt extended_5end_mismatch extended_3end_mismatch query_overhang_5end_mismatch query_overhang_3end_mismatch total_mismatch extend_align_pident
26 hsa-miR-1226-5p.MIMAT0005576 71 mmu-mir-6927.MI0022774 76.923 26 6 0 1 26 1 26 0.039 23.5 plus GTGAGGGCATGCAGGCCTGGATGGGG GTGAGGGGATCCAGCCCAGGCTAGGG 0 0 6 6 0 0 0 45 0 0 1 1 26 26 1 1 26 26 + . . . . 0 0 0 0 6 76.9231
. hsa-miR-8083.MIMAT0031010 . NO_HIT . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .
```

**Note(s):**
* For this example, TABs were replaced by white spaces.  
* Do note the difference between the `hsa-miR-1226-5p.MIMAT0005576` hit, and the `hsa-miR-8083.MIMAT0031010` **NO_HIT** line.  

Input File Column Descriptions: see readme.md in `module mk-append_nohits`.

### Output:
An ExtendAlign analysis summary, TAB separated file.

Example line(s):  
```
query_name subject_name query_length EA_alignment_length EA_total_mismatch EA_total_match EA_pident blastn_pident
hsa-miR-1226-5p.MIMAT0005576 mmu-mir-6927.MI0022774 26 26 6 20 76.9231 76.923
hsa-miR-8083.MIMAT0031010 NO_HIT . . . 0 . .
```

**Note(s):**
* For this example, TABs were replaced by simple white spaces.  
* Do note the difference between the `hsa-miR-1226-5p.MIMAT0005576` hit and the `hsa-miR-8083.MIMAT0031010` **NO_HIT** line.  

Output File Column Descriptions:  

`query_name`: Name or ID of the sequence used as query for alignment.  
`subject_name`: Name or ID of the sequence where a hit was found.  
`query_length`: Length of the query.  
`EA_alignment_length`: Number of query nucleotides included in the extended alignment.  
`EA_total_mismatch`: Number of mismatches found in the extended alignment.  
`EA_total_match`: Number of matches found in the extended alignment.  
`EA_pident`: ExtendAlign recalculated percent identity.  
`blastn_pident`: Original `HSe-blastn` percent identity.  


## Module parameters:
NONE

## Testing the module:

1. Test this module locally by running,
```
bash testmodule.sh
```

2. `[>>>] Module Test Successful` should be printed in the console...

## mk-EA_report directory structure

````
mk-EA_report								## Module main directory
├── mkfile								## File in mk format, specifying the rules for building every result requested by runmk.sh
├── readme.md							## This document. General workflow description.
├── runmk.sh								## Script to print every file required by this module
├── test									## Test directory
│   └── data								## Test data directory. Contains input files for testing.
└── testmodule.sh							## Script to test module functunality using test data

````