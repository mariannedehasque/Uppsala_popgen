setwd("/cfs/klemming/projects/supr/sllstore2017093/mammoth/marianne/GIT/data_BCM/ADMIXTOOLS/Chukochya")

library(admixtools)
library(ggplot2)
#library(gridExtra)

DIR="/cfs/klemming/projects/supr/sllstore2017093/mammoth/marianne/GIT/data_BCM/ADMIXTOOLS/Chukochya/f2_statistics"

population_subset<-c("Krestovka", "Siberia", "MCol_Wyoming", "Lafricana", "Mprim_Wyoming","Mprim_Alaska", "BC25.3K", "BC34.7K", "Chukochya")

extract_f2("/cfs/klemming/projects/supr/sllstore2017093/mammoth/marianne/GIT/data_BCM/ADMIXTOOLS/Chukochya/BCM.SampleID.snps.NewChr.autos.Orient.LDprune.SUBSET",
           DIR,pops=population_subset, overwrite=TRUE,auto_only = FALSE,qpfstats = TRUE)


f2_blocks = f2_from_precomp(DIR)
