ADMIXTOOLS-QPGRAPH
================
2025-06-10

- [BACKGROUND](#background)
- [PREREQUISITES](#prerequisites)
  - [Softwares](#softwares)
  - [Data](#data)
- [RUNNING ADMIXTOOLS/QPRAPH](#running-admixtoolsqpraph)
  - [Preparing inputfiles](#preparing-inputfiles)

## BACKGROUND

Admixtools is a software package for the analysis of population
structure and admixture. This folder contains scripts to run QpGraph in
Admixtools2, which is an R friendly version of the original Admixtools.
Note that this is still different from admixr, which is another
R-adapted admixtools package (although results will be practically the
same).The documentation for Admixtools2 can be found
[here](https://uqrmaie1.github.io/admixtools/articles/admixtools.html)

To run QpGraph, follow the scripts under Admixtools2/Scripts. Scripts
were modified from
<https://github.com/popgenDK/seqAfrica_wildebeest/tree/main/qpGraph>.

## PREREQUISITES

### Softwares

- plink/1.90b4.9
- R with following packages installed: “admixtools”, “reshape2”,
  “plotly”, “tidyverse”, “igraph”

### Data

- filtered BCF file containing all populations/individuals of interest
- pruning is not strictly necessary, as stats will be calculated in
  block sizes. However, pruning or subsampling may drastically increase
  speed when working with large datasets.

## RUNNING ADMIXTOOLS/QPRAPH

### Preparing inputfiles

**0_prepare_input.sh**

This script is used to update ID’s to group individuals of the same
population/species and requires a *SUBSET.txt* file.

To prepare this file:

1.  copy the .fam file.
2.  Modify the first column with the new ID’s.

E.g. this is what my SUBSET.txt file looks like (minus the header):

| Population  | Sample ID              | Col3 | Col4 | Col5 | Col6 |
|-------------|------------------------|------|------|------|------|
| Mouflon_IRA | 266                    | 0    | 0    | 0    | -9   |
| Mouflon_IRA | 267                    | 0    | 0    | 0    | -9   |
| Mouflon_IRA | 271                    | 0    | 0    | 0    | -9   |
| Mouflon_IRA | 272                    | 0    | 0    | 0    | -9   |
| DOM_ALT     | Altamurana-SRR12396902 | 0    | 0    | 0    | -9   |
| DOM_ALT     | Altamurana-SRR12396903 | 0    | 0    | 0    | -9   |
| Argali      | ARG2-1                 | 0    | 0    | 0    | -9   |
| Argali      | ARG3-1                 | 0    | 0    | 0    | -9   |
| Argali      | ARG8-2                 | 0    | 0    | 0    | -9   |
| Argali      | ARG10-4                | 0    | 0    | 0    | -9   |
| Argali      | ARG19                  | 0    | 0    | 0    | -9   |
| Argali      | ARG20                  | 0    | 0    | 0    | -9   |
