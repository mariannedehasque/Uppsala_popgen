#!/bin/bash -le

#SBATCH -A naiss2025-5-78
#SBATCH --job-name=qpgraph
#SBATCH --partition=shared
#SBATCH --cpus-per-task=24
#SBATCH --time=1-00:00:00
#SBATCH --error=slurm-%x-%j-%N-%A.out
#SBATCH --output=slurm-%x-%j-%N-%A.out

SEARCHER=/cfs/klemming/projects/supr/sllstore2017093/mammoth/marianne/GIT/BCM/ADMIXTOOLS/graphExplorer.R

usepops=Krestovka,Siberia,MCol_Wyoming,Lafricana,Mprim_Wyoming,Mprim_Alaska,BC25.3K,BC34.7K,Chukochya

f2dir=/cfs/klemming/projects/supr/sllstore2017093/mammoth/marianne/GIT/data_BCM/ADMIXTOOLS/Chukochya/f2_statistics
nruns=50
outpop=Lafricana
ncores=24
nadmix=$1
nrun=$2

module load PDC/23.12 R/4.4.0

outpre=/cfs/klemming/projects/supr/sllstore2017093/mammoth/marianne/GIT/data_BCM/ADMIXTOOLS/Chukochya/graphs/nrun${nrun}_nadmix${nadmix}
Rscript $SEARCHER --f2dir $f2dir --outprefix $outpre --outpop $outpop --usepops $usepops --nruns $nruns --nadmix $nadmix --threads $ncores
