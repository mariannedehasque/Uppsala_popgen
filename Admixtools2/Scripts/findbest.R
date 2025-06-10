# Required libraries
require(reshape2)
require(plotly)
require(admixtools)

# Command-line arguments
args <- commandArgs(trailing=TRUE)
f2sdir <- args[1]
inputList <- args[2]
out <- args[3]
threads <- as.integer(args[4])

# Load f2 data and file list
f2s <- read_f2(f2sdir)
files <- scan(inputList, what='thef')
print(files)
load(files[1])  # Load initial winners and fits

# Initialize all_winners and all_fits
all_winners <- winners
all_fits <- fits

# Load remaining files and combine winners and fits
for (idx in 2:length(files)) {
    load(files[idx])
    all_winners <- rbind(all_winners, winners)
    all_fits <- rbind(all_fits, fits)
}

# Function to calculate number of admixtures
nadmix <- function(x) {
    sum(x$edges$type == "admix") / 2
}

# Reorder all_fits by score and number of admixtures
ord <- order(sapply(all_fits, FUN = function(x) { x$score }))
all_fits <- all_fits[ord]
ord <- order(sapply(all_fits, FUN = function(x) { sum(x$edges$type == "admix") / 2 }), decreasing = TRUE)
all_fits <- all_fits[ord]

# Remove identical topologies
all_igraphs <- lapply(all_fits, FUN = function(x) { edges_to_igraph(x$edges) })
all_hashes <- lapply(all_igraphs, FUN = function(x) { graph_hash(x) })

print(length(all_fits))
all_fits <- all_fits[!duplicated(all_hashes)]
print(length(all_fits))
nopts <- length(all_fits)

# Save all_fits to file
save(all_fits, file = paste0(out, ".Rdata"))

# Extract scores and list of edges
scores <- sapply(all_fits, FUN = function(x) { x$score })
list_of_edges <- lapply(all_fits, FUN = function(x) { x$edges })

# Bootstrap resampling and parallel processing
cat("Starting bootstrap calculations...\n")

nboot <- 100
boo <- boo_list(f2s, nboot = nboot)
#Modified comps function to make more memory efficient
comps <- parallel::mclapply(1:length(list_of_edges), FUN=function(x){
  result <- qpgraph_resample_snps2(boo$boo, list_of_edges[[x]], boo$test, verbose=FALSE)
  return(result$score_test)
}, mc.cores=threads)

cat("Bootstrapping done...\n")

# Initialize list to store comparison data
list_data <- list()
counter <- 1

cat("Compare fits between models...\n")
# Compare fits between all pairs of models
for (idx in 1:(nopts-1)) {
  for (idx2 in (idx+1):nopts) {
    if (idx2 > nopts) {
      next
    }

    a <- compare_fits(comps[[idx]], comps[[idx2]])
    list_data[[counter]] <- c(
      idx, idx2, a$p, a$diff,
      nadmix(all_fits[[idx]]), nadmix(all_fits[[idx2]]),
      all_fits[[idx]]$score, all_fits[[idx2]]$score,
      mean(comps[[idx]]), mean(comps[[idx2]]),
      a$ci_low, a$ci_high
    )
    counter <- counter + 1
  }
}

# Convert list to data frame
df <- as.data.frame(do.call(rbind, list_data))
colnames(df) <- c("idx1", "idx2", "p", "score_diff", "adm1", "adm2", "score1", "score2", "score_test1", "score_test2", "ci_low", "ci_high")

# Save data frame to file
write.table(df, file = out, quote = FALSE, col.names = TRUE, row.names = FALSE)
