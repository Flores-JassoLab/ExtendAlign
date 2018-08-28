**Location:** `/labs/crve-fabian/mirna_vaca/miRNAs-mismatches/unicos-compartidos/bta-hsa/blastnBta-Hg38`

---
#ExtendAlign
`ExtendAlign` is a tool for end-to-end pairwise alignments usig blastn as a 

## Loading Query and Subject Sequences
Sequecnes to be aligned (query), in fasta format, should be load into the `data/query/` directory.

Sequeces used as a reference (subject), in fasta format, should be load into the `data/subject/` directory.

## Build BLASTn database
```
$ mk data/subject/subject.fa.nhr
```

##


## Send jobs to condor environment
```
$ condor submit
```

## Requirements
- BLAST v.2.2.31+
- Samtools v.1.5
- Infoseq EMBOSS:6.6.0.0
- 9base / plan9port
- Execline
