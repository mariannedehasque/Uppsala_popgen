ml bioinfo-tools plink/1.90b4.9

INDIR=/cfs/klemming/projects/supr/sllstore2017093/mammoth/marianne/GIT/data_BCM/ANGSD/haplo/
OUTDIR=/cfs/klemming/projects/supr/sllstore2017093/mammoth/marianne/GIT/data_BCM/ADMIXTOOLS/Chukochya

#autosomes
plink -bfile $INDIR/BCM.SampleID.snps.NewChr.autos.Orient.LDprune --update-ids $OUTDIR/SUBSET.txt --make-bed --allow-extra-chr --chr-set 27 --out $OUTDIR/BCM.SampleID.snps.NewChr.autos.Orient.LDprune.SUBSET
