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
- [PONG analysis](#pong-analysis)

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

``` bash
for sample in ARG10-4 ARG19 ARG20 ARG2-1 ARG3-1 ARG8-2 Corsica-11 Corsica-7 Corsica-F1 Corsica-M1 Corsican-mouflon-N00 Corsican-Mouflon-N43 Corsican-mouflon-N47 Corsican-mouflon-N76 Corsican-mouflon-N77 Corsican-mouflon-N83 Corsican-mouflon-N85 Corsican-mouflon-N90 Corsican-mouflon-N96 Corsican-mouflon-N97 cym002 cym003 cym004 cym006 cym007 cym008 cym009 cym011 cym012 Montes-1 Montes-2 Montes-3 Montes-4 Montes-5 Montes-6 Ogliastra-11 Ogliastra-12 Ogliastra-13 Ogliastra-14 Ogliastra-15 Ogliastra-18 Ogliastra-19 Ogliastra-1 Ogliastra-3 Ogliastra-4 Ogliastra-6 Ogliastra-9 MUF1 MUF2-1 MUF3-1 OGA018 KR15 SH20 YZ.11 BAT_IOSW_r1 Ogliastra-17 Altamurana_SRR12396902 Altamurana_SRR12396903 Awassi_SRR11657624 Awassi_SRR501872 Awassi_SRR501890 Awassi_SRR501893 Bighorn_SRR16036485 Bighorn_SRR16036486 Bighorn_SRR16036488 Bighorn_SRR16036489 Bighorn_SRR16036516 Bighorn_SRR2418288 Castellana_SRR501883 Castellana_SRR501904 Churra_SRR501848 Churra_SRR501909 Dman_ERR277069 Dman_ERR277070 Dman_ERR277072 Dman_ERR283423 Dman_ERR283429 Dman_ERR318904 Dorset_SRR19144758 Finnsheep_SRR11657546 Finnsheep_SRR11657547 Finnsheep_SRR11657549 Finnsheep_SRR11657550 Finnsheep_SRR11657551 Finnsheep_SRR11657552 Gotland_SRR11657694 Gotland_SRR11657695 Gotland_SRR11657696 Gotland_SRR11657698 Gotland_SRR11657699 Gotland_SRR11657700 Karakas_SRR501849 Karakas_SRR501886 Laucane_SRR501850 Laucane_SRR501851 Merino_SRR11657662 Merino_SRR11657672 Merino_SRR5991165 Merino_SRR5991255 Merino_SRR5991344 Merino_SRR5991463 Norduz_SRR501869 Norduz_SRR501888 Ojalada_SRR501900 Ojalada_SRR501911 Ossimi_SRR12396862 Ossimi_SRR12396863 Ouessant_SRR11657536 Ouessant_SRR11657540 Ouessant_SRR11657541 Ouessant_SRR11657720 Ouessant_SRR11657722 PagIsland_SRR12396860 PagIsland_SRR12396864 PagIsland_SRR12396915 Rambouillet_SRR6305143 Romney_SRR12396925 Romney_SRR12396992 Romney_SRR19144935 Romney_SRR19144964 Romney_SRR501859 Sakiz_SRR501843 Sakiz_SRR501878 Salz_SRR501841 Salz_SRR501842 ScottishBlackface_ERR9577158 ScottishBlackface_ERR9577159 ScottishBlackface_ERR9577160 ScottishBlackface_ERR9616773 ScottishBlackface_ERR9616779 ScottishBlackface_SRR501844 Texel_ERR9577152 Texel_ERR9577161 Texel_ERR9577162 Texel_ERR9577163 Texel_SRR19144927 Timahdite_ERR234302 Timahdite_ERR234303 Timahdite_ERR234313 Timahdite_ERR234317 Timahdite_ERR246146 Timahdite_ERR246150 SuffolkBlackface_SAMN05216769 SuffolkBlackface_SAMN05216770 SuffolkBlackface_SAMN05216771 SuffolkBlackface_SAMN05216772 SuffolkBlackface_SAMN05216773 SuffolkBlackface_SAMN05216776 Dorset_SAMN05216720 Dorset_SAMN05216721 Dorset_SAMN05216724 Dorset_SAMN05216725 Dorset_SAMN05216728 Rambouillet_SAMN05216750 Rambouillet_SAMN05216751 Rambouillet_SAMN05216753 Rambouillet_SAMN05216755 Rambouillet_SAMN05216757 266 267 271 272 NeraSheep-183-F NeraSheep-227-D NeraSheep-227-F NeraSheep-435-F NeraSheep-450-F NeraSheep-450-SO NeraSheep-ISEDDU-SO NeraSheep-P252 NeraSheep-P435 SardaSheep-1 SardaSheep-2 SardaSheep-3 SardaSheep-4 SardaSheep-5 SardaSheep-6; do sbatch /proj/snic2020-2-10/private/Analyses/marianne/PROJECTS/EuropeanMouflon/SCRIPTS/bcftools_sample.sh $sample 1; done
```

Next up, the subsampled file is split per file as described above. To
convert the `vcf.gz` file to fasta the following script is used:
`BCF2FASTA.all.py`. This script does exactly the same as the other
script mentioned above, but does not split the `vcf.gz` file into
different chromosomes.

Individual files are concatenated again to generate a msa file.

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

