ExtendAlign
============

A computational algorithm for delivering multiple global alignment results originated from local alignments.


Usage
=====

ExtendAlign has three flavors (branches):

  - **best-hit:** Performs sense/antisense alignemnts and reports the number of match/mismatch of the best alignment for each query.
  - **all-hits:** Performs sense/antisense alignments and does not select the best alignent, reports all hits given by HSe-blastn.
  - **plus-strand:** Performs only sense alignments and reports the number of match/mismatch for the best alignment for each query.

To **download** the code use:

```
$ YOUR_FLAVOR_CHOICE=best-hit
$ git clone https://github.com/Flores-JassoLab/ExtendAlign --branch $YOUR_FLAVOR_CHOICE
```

For any version, place the sequences to be aligned (query) in fasta format into the `data/query` directory.

Place the sequences to be used as reference (subject) in fasta format into the `data/subject` directory and execute:

```
$ bin/make-config
$ bin/activate
$ targets | xargs mk
```

Your results will be on `reports/` when the process ends.

The reports consist on a table containing the following information, separated by tabs:

```
query_name, subj_name, query_length, complete_query_seq, complete_subj_seq, total_match, total_mismatch
```

If the process is too slow for you, `split` the query files before using ExtendAlign.


Test data set
=============

A test dataset is included at ` test/data/query/hsa-miRNAs22.fa` `test/data/subject/mmu-premiRNAs22.fa`:

To test if the scripts are working as expected.

```
$ mk test
```

You can confirm our results are reproducible,
using branch `all-hits`:

```
$ mk our-paper-results
```


Options
=======

`NPROC` environment variable can be specified to run multiple processes simultaneously.

```
$ targets | xargs env NPROC=$(grep proc /proc/cpuinfo | wc -l ) mk
```


Requirements
============

  - [`blast`](https://blast.ncbi.nlm.nih.gov/Blast.cgi?CMD=Web&PAGE_TYPE=BlastDocs&DOC_TYPE=Download)
  - [`coreutils`](https://www.gnu.org/software/coreutils/coreutils.html "Basic file, shell and text manipulation utilities of the GNU operating system.")
  - [`execline`](http://www.skarnet.org/software/execline/ "execline is a (non-interactive) scripting language")
  - [`findutils`](https://www.gnu.org/software/findutils/ "Basic directory searching utilities of the GNU operating system.")
  - [`mk`](http://doc.cat-v.org/bell_labs/mk/mk.pdf "A successor for `make`.")
  - [`samtools`](http://www.htslib.org/download/ "Utilities for interacting with and post-processing short DNA sequence read alignments")


To install requirements:
#### Install instructions for Debian/Ubuntu systems.

To solve dependencies, execute: 

```
sudo apt update
sudo apt install blast2 coreutils findutils 9base s6
```

To finish the `mk` configuration, execute:

```
echo 'export PATH=$PATH:/usr/lib/plan9/bin' >> ~/.bashrc
```

For [`samtools`](http://www.htslib.org/download/) and its dependencies [`htslib`](http://www.htslib.org/download/), and [`execline`](http://skarnet.org/software/execline/) and its dependencies [`skalibs`](http://skarnet.org/software/skalibs/) and [`s6`](http://skarnet.org/software/s6/), you have to download the source packages, decompress, change to decompressed folder and execute these three commands for each one:

```
./configure
make
sudo make install
```

The source package can be download from:

  - [`htslib`](http://www.htslib.org/download/)
  - [`skalibs`](http://skarnet.org/software/skalibs/)
  - [`s6`](http://skarnet.org/software/s6/)
  - [`samtools`](http://www.htslib.org/download/)
  - [`execline`](http://skarnet.org/software/execline/)


References
==========

Please cite as «Flores-Torres, M. *et al.* (2018) ExtendAlign: a computational algorithm for delivering multiple global alignment results originated from local alignments». [bioRxiv](https://www.biorxiv.org/content/early/2018/11/23/475707)


Contact
=======

Doubts or comments?

Dr Fabian Flores-Jasso <cfflores@inmegen.gob.mx>
