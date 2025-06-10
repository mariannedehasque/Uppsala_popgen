#!/bin/bash -le

#SBATCH -A naiss2025-5-78
#SBATCH --job-name=findbest
#SBATCH -p main
#SBATCH --time=1-00:00:00
#SBATCH --error=slurm-%x-%j-%N-%A.out
#SBATCH --output=slurm-%x-%j-%N-%A.out

module load PDC/23.12 R/4.4.0

# Define the output directory
DIR="/cfs/klemming/projects/supr/sllstore2017093/mammoth/marianne/GIT/data_BCM/ADMIXTOOLS/Chukochya"


f2dir="$DIR/f2_statistics/"
inputList="${DIR}/graphs/Rdata.txt"
out="${DIR}/tests.txt"

threads=96

# Define the R script to run
FINDBEST="/cfs/klemming/projects/supr/sllstore2017093/mammoth/marianne/GIT/BCM/ADMIXTOOLS/findbest.R"

# Run the R script with the specified inputs and outputs
Rscript $FINDBEST $f2dir $inputList $out $threads
