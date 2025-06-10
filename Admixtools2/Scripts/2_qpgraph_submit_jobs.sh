#!/bin/bash

# Define the ranges for nadmix and nrun
nadmix_values=(0 1 2 3 4 5)
nrun_values=($(seq 3 100))

# Loop over each combination of nadmix and nrun and submit a job
for nadmix in "${nadmix_values[@]}"; do
    for nrun in "${nrun_values[@]}"; do
        sbatch run_qpgraph.sh $nadmix $nrun
    done
done
