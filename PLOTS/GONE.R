#read in the data
files<-list.files("~/Library/CloudStorage/OneDrive-Personal/CTS/Rscripts/GONE", pattern = ".txt", full.names = T)

# Function to read a single file, skipping the first line and using the second line as header
read_file <- function(file) {
  data <- read.table(file, header = TRUE, sep = "\t", skip = 1)
  return(data)
}

# Extract file names without extension
file_names <- tools::file_path_sans_ext(basename(files))

#use lapply to read in all our files at once
data_list <- lapply(setNames(files, file_names), read_file)

# Combine all data frames into a single dataframe
bigData <- do.call(rbind, data_list)

max(bigData$Geometric_mean)


colours<- c( "goldenrod2","deepskyblue3", "#FF6F61", "#BB2649")

png("~/Library/CloudStorage/OneDrive-Personal/CTS/Rscripts/GONE/GONE.png", width = 2000, height = 1500, res = 300)


# Create an empty plot
plot(data_list$Cyprus, type = "n", xlab = "Generation", ylab = "Geometric mean", main = "GONE Results", xlim=c(0,50), log="y")

for (i in seq_along(file_names)){
  current_data <- data_list[[i]]
  lines(current_data$Generation, current_data$Geometric_mean, type="l", lwd=2.5, col=colours[i])
}

legend("topright", legend = names(data_list), col = c(colours), pch = 19, bty = "n")

dev.off()
  