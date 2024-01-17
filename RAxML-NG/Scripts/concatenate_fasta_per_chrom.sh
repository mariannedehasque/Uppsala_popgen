#!/bin/bash -l
#SBATCH -A snic2022-5-27
#SBATCH -p core -n 1
#SBATCH -J concatenate_fasta
#SBATCH -t 1-00:00:00

##################################
###### For the command line ######
##################################

#for chrom in NC_056054.1 NC_056055.1 NC_056056.1 NC_056057.1 NC_056058.1 NC_056059.1 NC_056060.1 NC_056061.1 NC_056062.1 NC_056063.1 NC_056064.1 NC_056065.1 NC_056066.1 NC_056067.1 NC_056068.1 NC_056069.1 NC_056070.1 NC_056071.1 NC_056072.1 NC_056073.1 NC_056074.1 NC_056075.1 NC_056076.1 NC_056077.1 NC_056078.1 NC_056079.1
#do
#  bash concatenate_fasta_per_chrom.sh $chrom
#done

fasta_dir="/proj/snic2020-2-10/private/Data/Non-Human/Animals/sheep/BAM_files/ARS-UI_Ramb_v2.0/VCF_PANELS/bcftools_mpileup/merged/Mouflon_goat.Q30.sorted.G5.D3.noIndel.annot.repma.Fmiss0.2.snps.autos"
concat_dir="/proj/snic2020-2-10/private/Data/Non-Human/Animals/sheep/BAM_files/ARS-UI_Ramb_v2.0/VCF_PANELS/bcftools_mpileup/merged/Mouflon_goat.Q30.sorted.G5.D3.noIndel.annot.repma.Fmiss0.2.snps.autos/concatenated"

cd ${fasta_dir}/${1}

for file in *.fasta
do
  cat $file >> ${concat_dir}/${1}.concatenated.fasta
done


#for chrom in NC_056055.1 NC_056056.1 NC_056057.1 NC_056058.1 NC_056059.1 NC_056060.1 NC_056061.1 NC_056062.1 NC_056063.1 NC_056064.1 NC_056065.1 NC_056066.1 NC_056067.1 NC_056068.1 NC_056069.1 NC_056070.1 NC_056071.1 NC_056072.1 NC_056073.1 NC_056074.1 NC_056075.1 NC_056076.1 NC_056077.1 NC_056078.1 NC_056079.1
#do
#  bash concatenate_fasta_per_chunk.sh $chrom
#done
