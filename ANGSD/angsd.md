angsd
================
2024-01-17

## Genotype Likelihoods

``` bash
angsd -bam $INPUTFILE \
  -GL 1 \
  -nThreads 16 \
  -doGlf 2 \
  -doMajorMinor 1 \
  -SNP_pval 1e-6 \
  -doMaf 1 \
  -minMapQ 30 -minQ 30 \
  -uniqueOnly 1 -remove_bads 1 \
  -sites $SITESFILE \
    -ref $REFERENCE \
    -out $DIR/$INPUT
```
