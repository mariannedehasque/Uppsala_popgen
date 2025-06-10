#!/bin/bash -le

#SBATCH -A naiss2025-5-78
#SBATCH --job-name=plotbest
#SBATCH --partition=shared
#SBATCH --cpus-per-task=24
#SBATCH --time=1-00:00:00
#SBATCH --error=slurm-%x-%j-%N-%A.out
#SBATCH --output=slurm-%x-%j-%N-%A.out

module load PDC/23.12 R/4.4.0

# Define the output directory
DIR="/cfs/klemming/projects/supr/sllstore2017093/mammoth/marianne/GIT/data_BCM/ADMIXTOOLS/Chukochya"

compsFile="${DIR}/tests.txt"
rdataFile="${DIR}/tests.txt.Rdata"
outdir="${DIR}/plots"

mkdir -p "$outdir"


# Define the R script to run
PLOTBEST="//cfs/klemming/projects/supr/sllstore2017093/mammoth/marianne/GIT/BCM/ADMIXTOOLS/plotbest.R"

# Run the R script with the specified inputs and outputs
Rscript $PLOTBEST $rdataFile $compsFile $outdir
