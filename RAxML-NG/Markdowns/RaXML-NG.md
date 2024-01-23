RAxML-NG
================
2024-01-17

- [Preparing input files](#preparing-input-files)
- [Running RAxML-NG](#running-raxml-ng)

## Preparing input files

First, the merged and filtered bcf file
(`Mouflon_domesticated.Q30.sorted.G5.D3.noIndel.annot.repma.Fmiss0.2.snps.autos.bcf`)
must be split per sample using following script: `bcftools_samples.sh`.
This will result in one
`Q30.sorted.G5.D3.noIndel.annot.repma.Fmiss0.2.snps.autos.vcf.gz` file
per sample)

Next, the sample file is converted to fasta format. As all samples are
filtered for the same positions, this is effectively the same as doing a
multisample alignment (msa). As I didn’t find a tool that does this
exactly the way I want (i.e. only include positions in the merged and
filtered bcf), I wrote a python script to do the conversion:
`BCF2FASTA.chrom.py`.  

The script does the following:  

- Read a filtered sample `vcf.gz file`  
- Write the information from the vcf.gz file into a consensus fasta file
  with following rules:  
  - Genotype 0/0 gets translated into reference allele  
  - Genotype 0/1 gets translated randomly into either reference or alt
    allele  
  - Genotype 1/1 get translated into alt allele  
  - Missing genotypes get translated as “N”  
- Generate a fasta file per chromosome

Running the script results in a fasta file per chromosome
(e.g. `Corsica-1_NC_056054.1.fasta`). The header of the fasta file will
be the sample name.

Next all samples are merged per chromosome, resulting in one alignment
file per chromosome: `NC_056054.1.concatenated.fasta`. These files are
the input for the RAxML-NG analysis.

Snippet of the fasta file:

``` bash
head Corsican-mouflon-N00_NC_056054.1.fasta 

>Corsican-mouflon-N00
ATCAGGCACGGGGGAACGAANGGTTACTTATTTATGACCTGCCGTGCAAATGATCATACA
GCGCGCCGGCCAGGTCCTAGGATATGATTACGCTGGGNNNNNNNGNNGGCGGGGAAAGCG
GACGAAGCGCAAACGGATGGTAAAGGCCCGCTTCCATGGAGGGTGCGAGGGGCTTTCTCC
TGTGCCAATATTGTTTAACATTCTACTGCCCATTANGCCGAGGCCGCGCNNNGGTATCCT
CGCGCCGATGTACAGCGCANAGCCNGCGAGCATACCAGAGGGNGCTGGCGCCGCGTGCCC
GCAGTACACCNCCGGCGCAGNTTTTGTAGCGCGCTGGCGCCGTCGGACAGCCGTTTATCG
TCCGCGGGCTCGCTCCCACGAGGTCGTGCCCCTGGGTGGNCAGCTGTTGTGAATCGGCGC
CTCGTNTACCGTACCATTCAATTATTTACCCCGACTGTTTTGGTAACGCCTATCCGCTTT
TCACCGCTGCGAGACCAGTCAACTCGAGGTAGGGTTCGGGCGGGGGGCCTATCACGCCCG
```

## Running RAxML-NG

RAxML-NG is a phylogenetic tree inference tool which uses
maximum-likelihood (ML) optimality criterion. Its search heuristic is
based on iteratively performing a series of Subtree Pruning and
Regrafting (SPR) moves, which allows to quickly navigate to the
best-known ML tree. RAxML-NG is a successor of RAxML (Stamatakis 2014)
and leverages the highly optimized likelihood computation implemented in
libpll (Flouri et al. 2014).

RAxML-NG offers improvements in speed, flexibility and user-friendliness
over the previous RAxML versions. It also implements some of the
features previously available in ExaML (Kozlov et al. 2015), including
checkpointing and efficient load balancing for partitioned alignments
(Kobert et al. 2014).
