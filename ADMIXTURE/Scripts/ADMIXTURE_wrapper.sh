#!/bin/bash -l

#set variables
RUNNUMBER=${1}
OUT="/proj/snic2020-2-10/private/Analyses/marianne/PROJECTS/Mouflon/ADMIXTURE/all/run${RUNNUMBER}" #keep the run$1 part, for it will save your results in one folder per run
seed=$RANDOM



mkdir -p $OUT #uncomment if it is the first time you run it
echo $seed > $OUT/seed.txt

cd $OUT

#run admixture in several Ks
for K in {1..15}; do sbatch /proj/snic2020-2-10/private/Analyses/marianne/PROJECTS/Mouflon/SCRIPTS/ADMIXTURE.sh $seed $K $OUT;done


#for run in {1..20}; do bash /proj/snic2020-2-10/private/Analyses/marianne/PROJECTS/EuropeanMouflon/SCRIPTS/ADMIXTURE_wrapper.sh $run; done
