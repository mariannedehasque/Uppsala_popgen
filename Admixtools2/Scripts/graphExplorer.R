library(admixtools)
require(tidyverse)
library(igraph)


whereDir <- function(){
    # function to get directory where scripts are, so accompanying functions can be sourced even if the script is run from outside
    # made by krishang
    cmdArgs <- commandArgs(trailingOnly = FALSE)
    needle <- "--file"
    match <- grep(needle, cmdArgs)
    tf <- unlist(strsplit(cmdArgs[match], "="))[2]
    d <- dirname(tf)
    return(d)
}

d <- whereDir()

source(paste(d, "argReaderqpgraph.R", sep="/"))
source(paste(d, "qpgraphRfuns.R", sep="/"))

args <- commandArgs(trailingOnly=T)
pars <- readArgs(args)

# read input data
f2s <- read_f2(pars$f2dir)
outprefix <- pars$outprefix

# subset data if subset of pops has been specified
pops <- NULL
if(!is.null(pars$usepops) & (pars$usepops != "all")){
    pops <- strsplit(pars$usepops, split=",")[[1]]
    f2s <- f2s[pops,pops,]
}

# set population to be used as outgroup
outpop <- pars$outpop

if(!is.null(outpop) & !(outpop%in%pops))
    stop("Outgroup population (--outpop) needs to be included in list of pops to use (--usepops)")


winners <- list()
fits <- list()

# run nruns optimizations and save best graph for each run and fit it
ncores <- pars$threads
nruns <- 1:pars$nruns
all_pops = parallel::mclapply(nruns, FUN=function(x){find_graphs(f2s, numadmix=pars$nadmix, outpop=pars$outpop)}, mc.cores=ncores)
winners <- lapply(all_pops, function(x){x %>% slice_min(score, with_ties = FALSE)})
fits <- lapply(1:length(winners), function(x){qpgraph(f2s, winners[[x]]$graph[[1]], return_fstats=TRUE)})

winners <- do.call("rbind", winners)

# save results for each runs
outall <- paste0(outprefix, "_allOptimRuns.Rdata")
save(winners,fits, file=outall)

# make list of best likelihood for each run. good to check if seems converged.
outlikes <- paste0(outprefix, "_allOptimScores.txt")
write.table(winners$score, outlikes, quote=F, col.names=F, row.names=F)

# select run with best likelihood
whichbest <- which.min(winners$score)
bestgraph <- fits[[whichbest]]

# save results for run with bestlikelihood
outdir <- dirname(outprefix)
graphname <- paste0(basename(outprefix), "_bestgraph")
save_qpgraph_output(bestgraph, graphname, popord=pops, outdir=outdir)
