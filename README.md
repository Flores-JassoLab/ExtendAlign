ExtendAlign
===========
ExtendAlign is a tool, implemented with Nextflow, that combines the strength of a multi-hit local alignment, 
and also the refinement provided by a query-based end-to-end alignment in reporting accurately the number of m/mm for short queries.

---

## Installation
Download ExtendAlign from Github repository:  
```
$ git clone https://github.com/Flores-JassoLab/ExtendAlign
```

---

## Usage
To run ExtendAlign:

```
$ nextflow run extend_align.nf --query_fasta query.fa --subject_fasta subject.fa [--output_dir path to results ] 
[--number_of_hits all|best] [--blastn_threads int_value] [--blastn_strand both|plus|minus] 
[--blastn_max_target_seqs int_value] [--blastn_evalue real_value]
```

`--query_fasta` DNA or RNA fasta file with query sequences. Accepted extensions are `.fa`, `.fna` and `.fasta`  
`--subject_fasta` DNA or RNA fasta file with subject sequences. Accepted extensions are `.fa`, `.fna` and `.fasta`  

### Optional parameters
`--output_dir` Directory where results, intermediate and log files will be stored. Default: same dir where `--query_fasta resides`.  
`--number_of_hits` Amount of HSe-blastn hits extended by ExtendAlign for each query. Default: **best**  
  * all  = Every hit found by HSe-blastn is extended and reported by ExtendAlign.  
  * best = Only the best HSe-blastn hit (one per query) is extended and reported by ExtendAlign.  
***NOTE.*** Defined using the basic HSe-blastn alignment values, by the following algorithm: 
best hit is the one with higher alignment length, and the lowest number of mismatches and gaps.  

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

## Test


---

## Requirements
* [Bedtools v2.25.0](https://bedtools.readthedocs.io/en/latest/content/installation.html)  
```
$ apt-get install bedtools
```
* [BLAST 2.2.31+](https://www.ncbi.nlm.nih.gov/books/NBK52640/)  

* [NextFlow 19.01](https://www.nextflow.io/docs/latest/getstarted.html)  
```
$ curl -s https://get.nextflow.io | bash
```
* [mk](https://github.com/9fans/plan9port)  
```
$ apt install 9base
```
Add path to `.profile` or `~/.bashrc`:  
```
$ export PATH=$PATH:/path/to/plan9/bin
```

---

## Citation
Flores-Torres, M. *et al.* (2018) ExtendAlign: a computational algorithm for delivering multiple, local end-to-end alignments. 
<https://www.biorxiv.org/content/early/2018/12/08/475707>

---

## Contact
Doubts or comments?
Dr Fabian Flores-Jasso <cfflores@inmegen.gob.mx>

---

## Licence

