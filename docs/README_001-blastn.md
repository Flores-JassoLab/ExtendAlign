---
**Date:** Marzo 2018
**Author:** Mariana Flores-Torres
**Objective:** Alinear los miRNAs de bovino a los pre-miRNAs de humano.
**Location:** `/labs/crve-fabian/mirna_vaca/miRNAs-mismatches/unicos-compartidos/bta-hsa/blastnBta-Hg38`
---

#001-blastn

blastn: 2.2.31+

Generar referencia para blastn se uso la lista de pre-miRNAs de
humano de miRBase (v.21).

reference/

```
$ makeblastdb -in [SECUENCIAS.db.fna] -parse_seqids -dbtype nucl
```

```
data/  *.fa
results/  *.blastn.txt
```


Probar mkfile:

```
$ bin/targets | head -n 1 | xargs mk
```

Mandar trabajo a condor

```
$ condor submit
```
