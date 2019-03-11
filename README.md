ExtendAlign
===========
ExtendAlign is a tool, implemented with Nextflow, that combines the strength of a multi-hit local alignment,
and also the refinement provided by a query-based end-to-end alignment in reporting accurately the number of m/mm for short queries.

---
## Features

**- v 0.2.2**

* Supports DNA, RNA, or DNA  vs RNA alignments

* Results report include info about queries with no alignment hits

* Extend Align percent identity recalculation is reported relative to query length

* Easy integration with SGE or Condor Cluster environments

* Guaranteed scalability and reproducibility via a Nextflow-based framework

---

## Requirements

| Req.      | Version  | Required Commands * |
|:---------:|--------:|:-------------------:|
| [Bedtools](https://bedtools.readthedocs.io/en/latest/content/installation.html) | v2.25.0 | bedtools |
| [BLAST](https://www.ncbi.nlm.nih.gov/books/NBK52640/) | 2.2.31+ | makeblastdb , blastn |
| [NextFlow](https://www.nextflow.io/docs/latest/getstarted.html) | 19.01 | nextflow |
| [Seqkit](https://github.com/shenwei356/seqkit) | v0.10.0 | seqkit |
| [plan9 port](https://github.com/9fans/plan9port) | latest (as of 10/10/2019 ) | mk ** |

\* These commands must be accessible from your $PATH (i.e. you should be able to invoke them from your command line).  

\** plan9 port builds many binaries, but you ONLY need the `mk` utility to be accessible from your command line.

---

## Installation
Download ExtendAlign from Github repository:  
```
$ git clone https://github.com/Flores-JassoLab/ExtendAlign
```

---

## Test

To run the basic pipeline test:

Execute:

```
./runtest.sh
```

Your console will be filled with the Nextflow log for the run; after every process has been submitted, the following message will appear:

```
======
 Extend Align: Basic pipeline TEST SUCCESSFUL
======
```

The ExtendAlign results for the test data will be crated at the following file:

```
test/results/Extend_Align_results/hsa-miRNAs22.fa_EA_report.tsv
```

---

## Usage

To run ExtendAlign go to the pipeline directory and execute the following:

```
nextflow run extend_align.nf --query_fasta query.fa --subject_fasta subject.fa [--output_dir path to results ]
[--number_of_hits all|best] [--blastn_threads int_value] [--blastn_strand both|plus|minus]
[--blastn_max_target_seqs int_value] [--blastn_evalue real_value]
```

`--query_fasta` DNA or RNA fasta file with query sequences. Accepted extensions are `.fa`, `.fna` and `.fasta`  

`--subject_fasta` DNA or RNA fasta file with subject sequences. Accepted extensions are `.fa`, `.fna` and `.fasta`  

### Options

`--output_dir` Directory where results, intermediate and log files will be stored. Default: same dir where `--query_fasta resides`.  

`--number_of_hits` Amount of HSe-blastn hits extended by ExtendAlign for each query. Default: **best**  
  * all  = Every hit found by HSe-blastn is extended and reported by ExtendAlign.  
  * best = Only the best HSe-blastn hit (one per query) is extended and reported by ExtendAlign.  
  ***NOTE.*** Defined using the basic HSe-blastn alignment values, by the following algorithm: best hit is the one with higher alignment length, and the lowest number of mismatches (including mismatched query nucleotides due to subject gaps).  

`--blastn_threads` Number of threads to use in blastn search. Default: **1**  

`--blastn_strand` Subject strand to align against during blastn. Default: **both**  

  * plus  = Report hits found in subject's plus strand.  
  * minus = Report hits found in subject's minus strand.  
  * both  = Reports plus and minus alignments.  

`--blastn_max_target_seqs` Number of aligned sequences to keep. Default: **100**  

`--blastn_evalue` Expect value (E) for saving hits. Default: **10**  

`--help` Pipeline information.  
`--version` ExtendAlign version.  

---

## Cluster integration

TODO: (iaguilar) explain `-profile sge / -profile condor` usage

---

## Inputs and results

TODO: (iaguilar) explain input / results file formats

---

## Citation

If you find Extend Align helpful for your research, please include the following citation in your work:

Flores-Torres, M. *et al.* (2018) ExtendAlign: a computational algorithm for delivering multiple, local end-to-end alignments.


* Preprint version can be found at:
<https://www.biorxiv.org/content/early/2018/12/08/475707>

---

## Dev Team

- Bioinformatics Development   
 Israel Aguilar-Ordonez <iaguilaror@gmail>   
 Mariana Flores-Torres <mflores@inmegen.edu.mx>  
 Joshua I. Haase-Hernández <jihaase@inmegen.gob.mx>  
 Fabian Flores-Jasso <cfflores@inmegen.gob.mx>  

- Nextflow Port   
 Israel Aguilar-Ordonez <iaguilaror@gmail>   
 Karla Lozano-Gonzalez <klg1219sh@gmail.com>

---

## Contact
If you have questions, requests, or bugs to report, please open an [issue](https://github.com/Flores-JassoLab/ExtendAlign/issues), or email
<iaguilaror@gmail.com>
