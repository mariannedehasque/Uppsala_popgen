library(scales)

#######################
#### Small dataset ####
#######################

data <- samples <- read.table("~/OneDrive/CTS/Rscripts/DSUITE/Dsuite_results.txt", header=TRUE)

#par(pty="s") #Makes plot square


png("~/Library/CloudStorage/OneDrive-Personal/CTS/Rscripts/DSUITE/Dsuite.png", width = 2500, height = 2500, res = 300)
par(mar=c(4,8,2,8))
plot(data$Dstatistic,c(1,2,3,4), xlim=c(0,0.008),xlab="D-statistic", yaxt='n', ylab="", cex=2.5, pch=21,bg=c("#CEAB07","#643B9F","#C8A4D4","#CEAB07"))
legend("topleft",legend=c("Nerasheep", "Corsican Mouflon", "Sardinian Mouflon"), pch=16, col=c("#CEAB07","#C8A4D4","#643B9F"), cex=1)
axis(side = 2, at=c(1,2,3,4), labels=c("Sardasheep", "Corsican Mouflon", "Sardinian Mouflon", "Sardasheep"), las=1)
axis(side = 4, at=c(4,3,2,1), labels=c("Sardinian Mouflon", "Sardasheep", "Nerasheep", "Corsican Mouflon"), las=1)

dev.off()

#######################
##### Full dataset ####
#######################

data <-Dsuite_results_ALL <- read_excel("~/Library/CloudStorage/OneDrive-Personal/CTS/Rscripts/DSUITE/Dsuite_results_ALL.xlsx")
data$TOTAL <- (data$ABBA+data$BABA)

breeds=(unique(data$P3))
colour_palette=c("grey80","#DDDD77","#CEAB07","#C8A4D4","#114477","grey80","#88CCAA","#77AADD","grey80","#AA7744","grey80","#777711","grey80","grey80","grey80","grey80","grey80","grey80","grey80","grey80","#117744","#643B9F","grey80","#AA4455","grey80","grey80","grey80","grey80","#771122")

colour_df<-data.frame(breed=breeds, colour=colour_palette)
# To use unique colours per sample: bg=sheep_df[sheep_df$breed==sample,]$sheep_color

#################################################################
############### Introgression into Sarda #######################
#################################################################

data_sarda<-data[data$P2=="DOM_SARDA",]
samples<-unique(data_sarda$P3)

##################
### First plot ###
##################

plot((data_sarda$TOTAL), data_sarda$Dstatistic,
     xlab="number of ABBA+BABA sites", ylab = "D-statistic", pch=21, bg="grey80", main="(P1, Sarda, P3, Argali)")

for (i in seq_along(samples)){
  sample<-samples[i]
  current_data<-data_sarda[data_sarda$P3==sample,]
  points((current_data$TOTAL), current_data$Dstatistic,
         pch=21, bg=colours[i], cex=1.2)
}

colours_legend<-sheep_df[sheep_df$breed %in% samples,]
legend("topleft", title="P3", title.font = 2,legend = colours_legend$breed, col = colours_legend$sheep_color, pch = 19, bty = "n", cex=0.8)

###################
### Second plot ###
###################

#### Determine optimal ylimits ####

limit=0
ylimit=0

for (i in seq_along(samples)){
  sample<-samples[i]
  current_data<-data_sarda[data_sarda$P3==sample,]
  meanD<-mean(as.numeric(current_data$Dstatistic))
  if (limit < meanD) {
    limit=meanD
    ylimit= meanD + sd(as.numeric(current_data$Dstatistic))/3
  }
}

### Actual plot ####

png("~/Library/CloudStorage/OneDrive-Personal/CTS/Rscripts/DSUITE/Dsuite_SardaSheep.png", width = 1500, height = 2500, res = 300)

plot(1,meanD, xaxt='n', xlab="", ylab="Mean D-statistic",ylim=c(0,ylimit), col="white",main="(P1, Sardasheep, P3, Argali)")

for (i in seq_along(samples)){
  sample<-samples[i]
  current_data<-data_sarda[data_sarda$P3==sample,]
  meanD<-mean(as.numeric(current_data$Dstatistic))
  points(jitter(1,0.25),meanD, xaxt='n', xlab="", ylab="", ylim=c(0,ylimit), yaxt='n',
         pch=21, bg=sheep_df[sheep_df$breed==sample,]$sheep_color, cex=1.2 )
}

colours_legend<-sheep_df[sheep_df$breed %in% samples,]
legend("topleft", title="P3", title.font = 2,legend = colours_legend$breed, col = colours_legend$sheep_color, pch = 19, bty = "n", cex=0.8)

dev.off()

###################################################################################
############### Introgression into Sarda - increasing order #######################
###################################################################################

#Load in data
data_sarda<-data[data$P2=="DOM_SARDA",]
samples<-unique(data_sarda$P3)

#Determine ylimit for plots
limit=0
ylimit=0

for (i in seq_along(samples)){
  sample<-samples[i]
  current_data<-data_sarda[data_sarda$P3==sample,]
  meanD<-mean(as.numeric(current_data$Dstatistic))
  if (limit < meanD) {
    limit=meanD
    ylimit= meanD + sd(as.numeric(current_data$Dstatistic))/3
  }
}

xlimit=length(samples)

# Create an empty dataframe to store meanD and se
mean_se_df <- data.frame(sample=numeric(length(samples)),
                        meanD = numeric(length(samples)),
                        se = numeric(length(samples)))

# Loop through samples
for (i in seq_along(samples)) {
  sample <- samples[i]
  current_data <- data_sarda[data_sarda$P3 == sample, ]
  
  # Calculate meanD and se
  meanD <- mean(as.numeric(current_data$Dstatistic))
  sdD <- sd(as.numeric(current_data$Dstatistic))
  se <- sdD / sqrt(length(as.numeric(current_data$Dstatistic)))
  
  # Store meanD and se in the dataframe
  mean_se_df[i,"sample"] <- sample
  mean_se_df[i, "meanD"] <- meanD
  mean_se_df[i, "se"] <- se
}

# Order mean_se_df by meanD
mean_se_df <- mean_se_df[order(mean_se_df$meanD), ]

#Plot
png("~/Library/CloudStorage/OneDrive-Personal/CTS/Rscripts/DSUITE/Dsuite_SardaSheep_SD.png", width = 2000, height = 1500, res = 300)


plot(mean_se_df$meanD, xlim=c(0, xlimit), xaxt='n', xlab='', ylab='Mean D-statistic', 
     ylim=c(0, ylimit), col="white", main='(P1, Sardasheep, P3, Argali)', cex=1.4)
arrows(x0 = seq(1,xlimit), y0 = mean_se_df$meanD - mean_se_df$se, x1 = seq(1,xlimit), y1 = mean_se_df$meanD + mean_se_df$se, 
       angle = 90, code = 3, length = 0.1, col = "black")
points(mean_se_df$meanD, xlim=c(0, xlim), xaxt='n', xlab='', ylab='Mean D-statistic', 
       ylim=c(0, ylimit), pch=21, bg="grey40", cex=1.4)
axis(side=1, at=seq(1, xlimit), labels=mean_se_df$sample, las=2, cex.axis=0.5)

dev.off()

###################################################################################
############### Introgression into Nera - increasing order #######################
###################################################################################

#Load in data
data_nera<-data[data$P2=="DOM_NERA",]
samples<-unique(data_nera$P3)

#Determine ylimit for plots
limit=0
ylimit=0

for (i in seq_along(samples)){
  sample<-samples[i]
  current_data<-data_nera[data_nera$P3==sample,]
  meanD<-mean(as.numeric(current_data$Dstatistic))
  if (limit < meanD) {
    limit=meanD
    ylimit= meanD + sd(as.numeric(current_data$Dstatistic))/3
  }
}

xlimit=length(samples)

# Create an empty dataframe to store meanD and se
mean_se_df <- data.frame(sample=numeric(length(samples)),
                         meanD = numeric(length(samples)),
                         se = numeric(length(samples)))

# Loop through samples
for (i in seq_along(samples)) {
  sample <- samples[i]
  current_data <- data_nera[data_nera$P3 == sample, ]
  
  # Calculate meanD and se
  meanD <- mean(as.numeric(current_data$Dstatistic))
  sdD <- sd(as.numeric(current_data$Dstatistic))
  se <- sdD / sqrt(length(as.numeric(current_data$Dstatistic)))
  
  # Store meanD and se in the dataframe
  mean_se_df[i,"sample"] <- sample
  mean_se_df[i, "meanD"] <- meanD
  mean_se_df[i, "se"] <- se
}

# Order mean_se_df by meanD
mean_se_df <- mean_se_df[order(mean_se_df$meanD), ]

#Plot

png("~/Library/CloudStorage/OneDrive-Personal/CTS/Rscripts/DSUITE/Dsuite_NeraSheep_SD.png", width = 2000, height = 1500, res = 300)

plot(mean_se_df$meanD, xlim=c(0, xlimit), xaxt='n', xlab='P3', ylab='Mean D-statistic', 
     ylim=c(0, ylimit), col="white", main='(P1, Nerasheep, P3, Argali)', cex=1.4)
arrows(x0 = seq(1,xlimit), y0 = mean_se_df$meanD - mean_se_df$se, x1 = seq(1,xlimit), y1 = mean_se_df$meanD + mean_se_df$se, 
       angle = 90, code = 3, length = 0.1, col = "black")
points(mean_se_df$meanD, xlim=c(0, xlim), xaxt='n', xlab='', ylab='Mean D-statistic', 
       ylim=c(0, ylimit), pch=21, bg="grey40", cex=1.4)
axis(side=1, at=seq(1, xlimit), labels=mean_se_df$sample, las=2, cex.axis=0.5)

dev.off()


