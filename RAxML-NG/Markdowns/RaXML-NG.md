RAxML-NG
================
2024-01-17

- [Build phylogenetic tree per
  chromosome](#build-phylogenetic-tree-per-chromosome)
  - [Preparing input files](#preparing-input-files)
- [Build phylogenetic tree for randomly sampled
  SNPs](#build-phylogenetic-tree-for-randomly-sampled-snps)
  - [Preparing input files](#preparing-input-files-1)
- [Running RAxML-NG](#running-raxml-ng)

## Build phylogenetic tree per chromosome

### Preparing input files

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

To run the script for e.g. sample ARG10-4:

``` bash
python BCF2FASTA.all.py ARG10-4.Q30.sorted.G5.D3.noIndel.annot.repma.snps.autos.Fmiss0.1.subset2M.1.vcf.gz ARG10-4
```

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

## Build phylogenetic tree for randomly sampled SNPs

### Preparing input files

If runnning per chromosome takes too long, subsampling a set of SNPs
could be an alternative strategy.

First, subsample SNPs using script `vcflib_subset.sh`. This script is
run multiple times, to test for potentil biases introduced by
subsampling.

``` bash
bcftools view ${INDIR}/${FILE}.bcf | vcfrandomsample -r 0.035087719 > $TMPDIR/${FILE}.subset2M.${1}.vcf
bcftools view -Oz -o ${OUTDIR}/${FILE}.subset2M.${1}.vcf.gz $TMPDIR/${FILE}.subset2M.${1}.vcf
bcftools index ${OUTDIR}/${FILE}.subset2M.${1}.vcf.gz
```

Next up, the subsampled file is split per file as described above. To
convert the `vcf.gz` file to fasta the following script is used:
`BCF2FASTA.all.py`. This script does exactly the same as the other
script mentioned above, but does not split the `vcf.gz` file into
different chromosomes.

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

Perform an all-in-one analysis (ML tree search + non-parametric
bootstrap) (20 tree searches using 10 random and 10 parsimony-based
starting trees, GTR+GAMMA with default parameters, 100 bootstrap
replicates):

``` bash
#!/bin/bash -l
#SBATCH -A uppmax2023-2-31 -M snowy
#SBATCH -p core -n 8
#SBATCH -J RAxML-NG
#SBATCH -t 10-00:00:00

module load bioinfo-tools
module load RAxML-NG

CHROM=${1}

#for chrom in NC_056054.1 NC_056055.1 NC_056056.1 NC_056057.1 NC_056058.1 NC_056059.1 NC_056060.1 NC_056061.1 NC_056062.1 NC_056063.1 NC_056064.1 NC_056065.1 NC_056066.1 NC_056067.1 NC_056068.1 NC_056069.1 NC_056070.1 NC_056071.1 NC_056072.1 NC_056073.1 NC_056074.1 NC_056075.1 NC_056076.1 NC_056077.1 NC_056078.1 NC_056079.1
#do
#  sbatch RAxML-NG.sh $chrom
#done


#MSA format check
#raxml-ng --check --msa NC_056078.1.concatenated.fasta --model GTR+G --prefix T1

#Format check for larger files
#raxml-ng --parse --msa NC_056078.1.concatenated.fasta --model GTR+G --prefix T2

#--tree: File starting tree random{N}, parimony{N}

raxml-ng --msa ../${CHROM}.concatenated.fasta --all --bs-trees 100 -model GTR+G --prefix ${CHROM} --outgroup BAT_IOSW_r1 --threads 8 --seed 2
```
