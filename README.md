ExtendAlign
===========

![EA-image](dev_notes/ExtendAlign-image.jpeg)

---

ExtendAlign is a tool, implemented with Nextflow, that combines the strength of a multi-hit local alignment,
and also the refinement provided by a query-based end-to-end alignment in reporting accurately the number of matches and mismatches.

---

### Workflow overview
![General Workflow](dev_notes/Workflow.png)

---

#### Features
**- v 0.2.3**

* ExtandAlign supports DNA, RNA, or DNA  vs RNA alignments.
* Results include information about unaligned queries.
* ExtendAlign percent identity recalculation is reported relative to query length.
* Easy integration with SGE or Condor Cluster environments.
* Scalability and reproducibility via a Nextflow-based framework.
* Final EA process creates a donut plot summarizing changes in pident

---

## Requirements
#### Compatible OS*:
* [Ubuntu 16.04 LTS](http://releases.ubuntu.com/16.04/)
* [Ubuntu 18.04 LTS](http://releases.ubuntu.com/18.04/)
* [Ubuntu 20.04 LTS](http://releases.ubuntu.com/20.04/)

\* ExtendAlign may run in other UNIX based OS and versions, but testing is required.

#### Software:
| Requirement | Version  | Required Commands * |
|:---------:|:--------:|:-------------------:|
| [Bedtools](https://bedtools.readthedocs.io/en/latest/content/installation.html) | v2.30.0 | bedtools |
| [BLAST](https://www.ncbi.nlm.nih.gov/books/NBK52640/) | 2.9.0+ | makeblastdb , blastn |
| [Nextflow](https://www.nextflow.io/docs/latest/getstarted.html) | 21.04.1.5556 | nextflow |
| [Plan9 port](https://github.com/9fans/plan9port) | Latest (as of July 2021 ) | mk \** |
| [Seqkit](https://github.com/shenwei356/seqkit) | v2.0.0 | seqkit |

\* These commands must be accessible from your `$PATH` (*i.e.* you should be able to invoke them from your command line).  

\** Plan9 port builds many binaries, but you ONLY need the `mk` utility to be accessible from your command line.

---

### Installation
Download ExtendAlign from Github repository:  
```
git clone https://github.com/Flores-JassoLab/ExtendAlign
```

---

#### Test
To test if requirements are installed and ExtendAlign's execution using test data, run:
```
./runtest.sh
```

If requirements are correctly installed, your console should print the Nextflow log for the run, once every process has been submitted,
the following message will appear:
```
======
 Extend Align: Basic pipeline TEST SUCCESSFUL
======
```

ExtendAlign results for test data should be in the following file:
```
test/results/Extend_Align_results/sample_query_EA_report.tsv
```

---

### Usage
To run ExtendAlign go to the pipeline directory and execute:
```
nextflow run extend_align.nf --query_fasta <path to input 1> --subject_fasta <path to input 2> [--output_dir path to results ]
[--number_of_hits all|best] [--blastn_threads int_value] [--blastn_strand both|plus|minus]
[--blastn_max_target_seqs int_value] [--blastn_evalue real_value] [-profile sge|condor] [-resume]
```

For information about options and parameters, run:
```
nextflow run extend_align.nf --help
```

---

### Cluster integration
For scalability, this pipeline uses the executor component from Nextflow, as described [here](https://www.nextflow.io/docs/latest/executor.html);
especifically, we use the [SGE](https://www.nextflow.io/docs/latest/executor.html#sge) and [HTCondor](https://www.nextflow.io/docs/latest/executor.html#htcondor)
integration capabilities to manage process distribution and computational resources.

The _config_profiles/sge.config_ and/or _config_profiles/condor.config_ must be properly configured before launching cluster runs.
This configuration files define variables regarding queue, parallelization environments and resources requested by every process in the pipeline.  

For information about the `-profile sge|condor` option, run:
```
nextflow run extend_align.nf --help
```

---

### Pipeline Inputs
1. A query fasta file with `.fa`, `.fna` or `.fasta` extension.  

Example line(s):
```
>hsa-let-7a-5p.MIMAT0000062
UGAGGUAGUAGGUUGUAUAGUU
```

2. A subject fasta file with `.fa`, `.fna` or `.fasta` extension.  

Example line(s):
```
>mmu-let-7a-1.MI0000556
UUCACUGUGGGAUGAGGUAGUAGGUUGUAUAGUUUUAGGGUCACACCCACCACUGGGAGAUAACUAUACAAUCUACUGUCUUUCCUAAGGUGAU
```

### Pipeline Results
1. An ExtendAlign analysis summary, in TSV format.  

Example line(s):
```
query_name subject_name query_length EA_alignment_length EA_total_mismatch EA_total_match EA_pident blastn_pident
hsa-miR-1226-5p.MIMAT0005576 mmu-mir-6927.MI0022774 26 26 6 20 76.9231 76.923
hsa-miR-8083.MIMAT0031010 NO_HIT . . . 0 . .
```

**Note(s):**
* For this example, TABs were replaced with white spaces.
* Do note the difference between the `hsa-miR-1226-5p.MIMAT0005576` hit and the `hsa-miR-8083.MIMAT0031010` **NO_HIT** line.

#### Output File Column Descriptions:
`query_name`: Name or ID of the sequence used as query for alignment.  
`subject_name`: Name or ID of the sequence where a hit was found.  
`query_length`: Length of the query.  
`EA_alignment_length`: Number of query nucleotides included in the extended alignment.  
`EA_total_mismatch`: Number of mismatches found in the extended alignment.  
`EA_total_match`: Number of matches found in the extended alignment.  
`EA_pident`: ExtendAlign recalculated percent identity.  
`blastn_pident`: Original `HSe-blastn` percent identity.  

---

### ExtendAlign directory structure
````
ExtendAlign						## Pipeline main directory.
├── config_profiles					## Directory for cluster configuration files of this pipeline.
│   ├── condor.config				## Configuration file  HTCcondor cluster configuration
│   └── sge.config					## Configuration file for SGE cluster configuration.
├── dev_notes					## Developers notes directory
│   └── Workflow.png				## Flow diagram
├── extend_align.nf				## Flow control script of this pipeline.
├── mkmodules					## Directory for submodule organization
│   ├── mk-append_nohits			## Submodule to add rows with information for querys that had no hit in ExtendAlign
│   ├── mk-bedtools_getfasta		## Submodule to add extended nucleotide sequences to ExtendAlign
│   ├── mk-create_blastdb			## Submodule to create a blastn database from an ExtendAlign fasta file
│   ├── mk-create_EAfasta			## Submodule to transform a fasta file into an ExtendAlign fasta file
│   ├── mk-EA_report				## Submodule to generate a summarized ExtendAlign results table
│   ├── mk-get_best_hit				## Submodule to extract the best hit for every query in ExtendAlign results
│   ├── mk-get_EA_coordinates		## Submodule to add sequence coordinates to ExtendAlign results
│   ├── mk-HSe-blastn				## Submodule to run Blastn in High Sensitivity mode
│   ├── mk-mismatch_recalculation	## Submodule to add recalculated ExtendAlign percent identity
│   └── mk-recalculate_ngap			## Submodule to add number of mismatched nucleotides due to gaps introduced to query and subject sequences.
├── nextflow.config				## Configuration file for this pipeline.
├── README.md					## This document. General workflow description
├── runtest.sh					## Execution script for pipeline testing.
└── test							## Test directory.
    ├── data						## Test data directory
    │   ├── query					## Query directory
    │   └── subject					## Subject directory
    └── requirements				## Directory to test pipeline dependencies
        ├── bedtools					## Directory to test bedtools correct installation
        ├── blastn					## Directory to test blastn correct installation
        ├── dependency_checker.sh 		## Script to verify dependencies installation
        ├── makeblastdb				## Directory to test makeblastdb correct installation
        ├── mk						## Directory to test mk correct installation
        └── nextflow					## Directory to test nextflow correct installation

````

### Citation
If you find ExtendAlign helpful for your research, please include the following citation in your work:  

* Flores-Torres, M., Romero-Gomez, L., Haase-Hernandez, J.I., Aguilar-Ordoñez, I., Tovar, H., Avendano-Vazquez, S.E., Flores-Jasso, C.F. (2019)
ExtendAlign: the post-analysis tool to correct and improve the alignment of dissimilar short sequences.  

Preprint version can be found at:
<https://www.biorxiv.org/content/10.1101/475707v4>   

#### References
Under the hood ExtendAlign implements some widely known tools. Please include the following ciations in your work:

* Camacho, C., Coulouris, G., Avagyan, V., Ma, N., Papadopoulos, J., Bealer, K., & Madden, T. L. (2009). BLAST+: architecture and applications. BMC bioinformatics, 10(1), 421.
* Quinlan, A. R., & Hall, I. M. (2010). BEDTools: a flexible suite of utilities for comparing genomic features. Bioinformatics, 26(6), 841-842.
* Di Tommaso, P., Chatzou, M., Floden, E. W., Barja, P. P., Palumbo, E., & Notredame, C. (2017). Nextflow enables reproducible computational workflows. Nature biotechnology, 35(4), 316.

---

### Contact
If you have questions, requests, or bugs to report, please open an [issue](https://github.com/Flores-JassoLab/ExtendAlign/issues), or email <cfflores@inmegen.gob.mx>, <mflores@inmegen.edu.mx>, <iaguilar@inmegen.edu.mx>  

#### Dev Team
Israel Aguilar-Ordonez <iaguilar@inmegen.edu.mx>   
Mariana Flores-Torres <mflores@inmegen.edu.mx>  
Joshua I. Haase-Hernández <jihaase@inmegen.gob.mx>  
Karla Lozano-Gonzalez <klg1219sh@gmail.com>   
Fabian Flores-Jasso <cfflores@inmegen.gob.mx>  
