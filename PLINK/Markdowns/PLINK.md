PLINK
================
2024-04-09

- [Basic commands in PLINK](#basic-commands-in-plink)
  - [Preparing the data](#preparing-the-data)
  - [Converting to and from PLINK file
    format](#converting-to-and-from-plink-file-format)
  - [Pruning data](#pruning-data)
  - [Extracting a subset of samples](#extracting-a-subset-of-samples)
  - [Other input filtering](#other-input-filtering)
- [Analyses](#analyses)
  - [PCA](#pca)
  - [PCA with projection](#pca-with-projection)
  - [ROH](#roh)

PLINK - yet another file format to represent genotypes.

The PLINK framework can be used to filter data, generate PCA plots,
estimate ROHs, etc. In addition, the PLINK format is used for many other
analyses such as Treemix.

Note that PLINK was developed with the human reference genome in mind.
Therefore additional steps are necessary when processing non-human
datasets. This document was written based on the sheep reference genome.

# Basic commands in PLINK

## Preparing the data

Before converting BCF (or other formats) to PLINK, some preliminary
steps might be necessary.

- Many softwares based on PLINK expect chromosome names to be labelled
  as numbers. Converting chromosome names might therefore be useful.
- PLINK does not like underscores in sample names. Conversion, again,
  might be necessary.

Here’s my short script I use to prepare BCF files:

``` r
#Change underscores in sample names with dashes

bcftools query -l ${FILE}.bcf | sed 's/_/-/g' > NewHeader.txt
bcftools reheader -s NewHeader.txt ${FILE}.bcf -o ${FILE}.NewHeader.bcf

#Rename chromosome names

bcftools view ${FILE}.NewHeader.bcf | awk '{gsub(/NC_056061.1/, "8"); gsub(/NC_056056.1/, "3"); gsub(/NC_056058.1/, "5"); gsub(/NC_056067.1/, "14"); gsub(/NC_056063.1/, "10"); gsub(/NC_056068.1/, "15"); gsub(/NC_056060.1/, "7"); gsub(/NC_056054.1/, "1"); gsub(/NC_056062.1/, "9"); gsub(/NC_056059.1/, "6"); gsub(/NC_056055.1/, "2"); gsub(/NC_056064.1/, "11"); gsub(/NC_056066.1/, "13"); gsub(/NC_056065.1/, "12"); gsub(/NC_056057.1/, "4"); gsub(/NC_056069.1/, "16"); gsub(/NC_056072.1/, "19"); gsub(/NC_056075.1/, "22"); gsub(/NC_056070.1/, "17"); gsub(/NC_056073.1/, "20"); gsub(/NC_056076.1/, "23"); gsub(/NC_056071.1/, "18"); gsub(/NC_056074.1/, "21"); gsub(/NC_056077.1/, "24"); gsub(/NC_056078.1/, "25"); gsub(/NC_056079.1/, "26"); print;}' | bgzip -c > ${FILE}.NewHeader.NewChr.vcf.gz
tabix ${FILE}.NewHeader.NewChr.vcf.gz
```

## Converting to and from PLINK file format

To convert a BCF/VCF file to PLINK

``` r
plink --vcf ${FILE}.vcf.gz --make-bed --allow-extra-chr --chr-set 26 --missing-genotype 0 --keep-allele-order  --set-missing-var-ids @:# --out ${FILE}
```

- make-bed generates binary_fileset.bed + .bim + .fam files
- allow-extra-chr flags that more chromosomes than in the human
  reference will be used
- chr-set 26 flags that our dataset includes 26 chromosomes
- set-missing-var-ids will give all SNPs a new name in the format
  chr:position (as opposed to human-annotated SNPs that have a format
  similar to rsxxxxx)
- keep-allele-order preserves the major/minor allele (or, in the sheep
  case, the REF/ALT order) This is rather important when converting
  between VCF and PLINK.

To convert a PLINK BED file to another file format

``` r
plink --bfile ${FILE} --recode  --keep-allele-order --out ${FILE}
```

This generates a new_text_fileset.ped and new_text_fileset.map from the
data in binary_fileset.bed + .bim + .fam, while

``` r
plink --bfile ${FILE} --recode vcf-iid --keep-allele-order --out ${FILE}
```

generates new_vcf.vcf from the same data, removing family IDs in the
process.

## Pruning data

``` r
plink --bfile ${FILE} --missing-genotype 0 --allow-extra-chr --chr-set 26 --indep-pairwise 50 5 0.5 --out ${FILE}
plink --bfile ${FILE} --extract ${FILE}.subset.prune.in --make-bed --chr-set 26 --allow-extra-chr --out ${FILE}.LDprune
```

## Extracting a subset of samples

If you want to perform an analysis on a subset of samples, you can
subset your PLINK file. To specify the samples you want to keep in your
subset, you can modify the .fam or .nosex file. Simply make a copy of
these files and remove the samples you don’t want to include.

``` r
plink --bfile ${FILE} --keep ${SUBSETFILE}.txt --keep-allele-order  --allow-extra-chr --chr-set 26 --out ${FILE}.subset
```

## Other input filtering

For a comprehensive list, the PLINK documentation is best:
<https://www.cog-genomics.org/plink/1.9/filter>

Some interesting parameters are:

Missing genotype rates:

- –geno (maximum per variant)
- –mind (maximum per sample)

Frequency filters:

- –maf (minimum frequency)
- –mac (minimum count)

# Analyses

## PCA

``` r
plink --vcf ${FILE}.vcf.gz --make-bed --allow-extra-chr --chr-set 26 --set-missing-var-ids @:# --out ${FILE}

plink --bfile ${FILE} --missing-genotype 0 --allow-extra-chr --chr-set 26 --indep-pairwise 50 5 0.5 --out ${FILE}
plink --bfile ${FILE} --extract ${FILE}.prune.in --make-bed --chr-set 26 --allow-extra-chr --out ${FILE}.LDprune

#Change --pca based on number of samples. Default is 20, I think.
plink --bfile ${FILE}.LDprune --missing-genotype 0 --allow-extra-chr --chr-set 26 --pca 20 --out ${FILE}.LDprune
```

## PCA with projection

Projection can be done by loading a cluster file (via –within), and
using –pca-cluster-names/–pca-clusters to specify the clusters you want
to include in the PC calculation. You’ll probably also want to use
–read-freq to set the MAFs used in the relationship matrix calculation
(otherwise they’ll be based on the entire dataset, which is probably not
what you want). So if you don’t have precomputed MAFs ready, this is a
two step process:

1.  plink –bfile \[fileset\] –within \[cluster file\]
    –keep-cluster-names \[names of clusters to compute PCs on\] –freqx  
2.  plink –bfile \[fileset\] –within \[cluster file\] –pca-cluster-names
    \[same cluster names\] –read-freq plink.frqx –maf-succ –pca

``` r
plink --bfile $OUTDIR/${FILE}.LDprune \
--within $OUTDIR/domestic_projection_custom.txt --keep-cluster-names A \
--missing-genotype 0 --allow-extra-chr --chr-set 26 \
--keep $OUTDIR/domestic_projection_custom.txt  \
--freqx

plink --bfile $OUTDIR/${FILE}.LDprune \
--within $OUTDIR/domestic_projection_custom.txt  --read-freq plink.frqx --maf-succ --pca-cluster-names A \
--missing-genotype 0 --allow-extra-chr --chr-set 26 \
--pca 111 \
--keep $OUTDIR/domestic_projection_custom.txt \
--out $OUTDIR/${FILE}.LDprune.domestic.projection.custom
```

## ROH

``` r
plink --bcf $indir/${bfile}.bcf --make-bed --allow-extra-chr --set-missing-var-ids @:# --out $outdir/$bfile

plink --bfile $outdir/$bfile \
--homozyg \
--homozyg-window-snp 100 \
--homozyg-window-het 1 \
--homozyg-gap 1000 \
--homozyg-kb 100 \
--homozyg-window-threshold 0.05 \
--homozyg-het 100 \
--homozyg-density 50 \
--homozyg-snp 50 \
--allow-extra-chr \
--out $outdir/${bfile}.homsnp50.homwinsnp100.homwinhet1.homkb100.gap1000


#["homozyg-snp"],  # Min SNP count per ROH.
#["homozyg-kb"],  # Min length of ROH, with min SNP count.
#["homozyg-window-snp"],  # Scanning window size.
#["homozyg-window-het"],  # Max hets in scanning window hit.
#["homozyg-window-missing"],  # Max missing calls in scanning window hit.
#["homozyg-het"],  # By default, a ROH can contain an unlimited number of heterozygous calls; you can impose a limit with --homozyg-het. (This flag was silently ignored by PLINK 1.07.)
```
