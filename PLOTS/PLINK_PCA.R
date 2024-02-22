samples <- read.table("~/OneDrive/CTS/Rscripts/PCA/Mouflon_domestic.sampleinfo2.txt", header=TRUE) #Already contains colours

eigenvec <- read.table("~/OneDrive/CTS/Rscripts/PCA/Mouflon_domestic_argali.Q30.sorted.G5.D3.noIndel.annot.repma.snps.autos.Fmiss0.1.NoPrivate.NewChr.LDprune.mouflon.domestic.eigenvec", quote="\"", comment.char="")
eigenval <- read.table("~/OneDrive/CTS/Rscripts/PCA/Mouflon_domestic_argali.Q30.sorted.G5.D3.noIndel.annot.repma.snps.autos.Fmiss0.1.NoPrivate.NewChr.LDprune.mouflon.domestic.eigenval", quote="\"", comment.char="")

PC1_load <- (eigenval[1,]/sum(eigenval))*100
PC2_load <- (eigenval[2,]/sum(eigenval))*100
PC3_load <- (eigenval[3,]/sum(eigenval))*100
PC4_load <- (eigenval[4,]/sum(eigenval))*100
PC5_load <- (eigenval[5,]/sum(eigenval))*100
PC6_load <- (eigenval[6,]/sum(eigenval))*100
PC7_load <- (eigenval[7,]/sum(eigenval))*100
PC8_load <- (eigenval[8,]/sum(eigenval))*100

all<-cbind(samples,eigenvec)

##### SPLIT data into DOM and mouflon/Sarda/Nera #####

dom_groups <- all[grepl("^DOM", all$Group), ]
non_dom_groups <- all[!grepl("^DOM", all$Group), ]

png("~/Library/CloudStorage/OneDrive-Personal/CTS/Rscripts/PCA/PRESENTATION2_PCA.png", width = 2500, height = 2500, res = 300)

plot.new()
layout(matrix(1:4, 2, 2, byrow = TRUE), respect = TRUE)

##############################################################
###################### PC1 and PC2 ###########################
##############################################################

par(pty="s") #Makes plot square
par(mar=c(4,5,1,1))

# Calculate y and x limits
y_lim_min <- as.numeric(min(all$V4) - sd(all$V4)/3)
y_lim_max <- as.numeric(max(all$V4) + sd(all$V4)/3)
x_lim_min <- as.numeric(min(all$V3) - sd(all$V3)/3)
x_lim_max <- as.numeric(max(all$V3) + sd(all$V3)/3)

plot(jitter(dom_groups$V3,1000), jitter(dom_groups$V4,100),xlab="",ylab="", col=alpha(dom_groups$colour,0.5),pch=16,cex=1.2,ylim=c(y_lim_min, y_lim_max), xlim=c(x_lim_min, x_lim_max))
points(jitter(non_dom_groups$V3,500), jitter(non_dom_groups$V4,500),xlab="",ylab="", bg=non_dom_groups$colour,pch=21,cex=1.3,ylim=c(y_lim_min, y_lim_max), xlim=c(x_lim_min, x_lim_max))
legend("topleft",legend=unique(all$Group), pch=16, col=c(unique(all$colour)), cex=0.65)
mtext(paste0("PC2 ", round(PC2_load,1), "%"), side =2, line=2.8, cex=1, font=2)
mtext(paste0("PC1 ", round(PC1_load,1), "%"), side =1, line=2.8, cex=1, font=2)

##############################################################
###################### PC3 and PC4 ###########################
##############################################################

# Calculate y and x limits
y_lim_min <- min(all$V6) - sd(all$V6) / 3
y_lim_max <- max(all$V6) + sd(all$V6) / 3
x_lim_min <- min(all$V5) - sd(all$V5) / 3
x_lim_max <- max(all$V5) + sd(all$V5) / 3

# Plot dom_groups
plot(dom_groups$V5, dom_groups$V6, xlab = "", ylab = "", col = alpha(dom_groups$colour, 0.5), pch = 16, cex = 1.2, ylim = c(y_lim_min, y_lim_max), xlim = c(x_lim_min, x_lim_max))
points(jitter(non_dom_groups$V5,500), jitter(non_dom_groups$V6,500), xlab = "", ylab = "", bg = non_dom_groups$colour, pch = 21, cex = 1.3, ylim = c(y_lim_min, y_lim_max), xlim = c(x_lim_min, x_lim_max))

mtext(paste0("PC3 ", round(PC3_load,1), "%"), side =1, line=2.8, cex=1, font=2)
mtext(paste0("PC4 ", round(PC4_load,1), "%"), side =2, line=2.8, cex=1, font=2)

##############################################################
###################### PC5 and PC6 ###########################
##############################################################

# Calculate y and x limits
y_lim_min <- min(all$V8) - sd(all$V8) / 3
y_lim_max <- max(all$V8) + sd(all$V8) / 3
x_lim_min <- min(all$V7) - sd(all$V7) / 3
x_lim_max <- max(all$V7) + sd(all$V7) / 3

# Plot dom_groups
plot(dom_groups$V7, dom_groups$V8, xlab = "", ylab = "", col = alpha(dom_groups$colour, 0.5), pch = 16, cex = 1.2, ylim = c(y_lim_min, y_lim_max), xlim = c(x_lim_min, x_lim_max))
points(jitter(non_dom_groups$V7,500), jitter(non_dom_groups$V8,500), xlab = "", ylab = "", bg = non_dom_groups$colour, pch = 21, cex = 1.3, ylim = c(y_lim_min, y_lim_max), xlim = c(x_lim_min, x_lim_max))
text(-0.24,0.22,"Ouessant")
text(0.07,-0.16, "Gotland")

mtext(paste0("PC5 ", round(PC5_load,1), "%"), side =1, line=2.8, cex=1, font=2)
mtext(paste0("PC6 ", round(PC6_load,1), "%"), side =2, line=2.8, cex=1, font=2)

##############################################################
###################### PC7 and PC8 ###########################
##############################################################

# Calculate y and x limits
y_lim_min <- min(all$V10) - sd(all$V10) / 3
y_lim_max <- max(all$V10) + sd(all$V10) / 3
x_lim_min <- min(all$V9) - sd(all$V9) / 3
x_lim_max <- max(all$V9) + sd(all$V9) / 3

plot(dom_groups$V9, dom_groups$V10, xlab = "", ylab = "", col = alpha(dom_groups$colour, 0.5), pch = 16, cex = 1.2, ylim = c(y_lim_min, y_lim_max), xlim = c(x_lim_min, x_lim_max))
points(jitter(non_dom_groups$V9,500), jitter(non_dom_groups$V10,500), xlab = "", ylab = "", bg = non_dom_groups$colour, pch = 21, cex = 1.3, ylim = c(y_lim_min, y_lim_max), xlim = c(x_lim_min, x_lim_max))

mtext(paste0("PC7 ", round(PC5_load,1), "%"), side =1, line=2.8, cex=1, font=2)
mtext(paste0("PC8 ", round(PC6_load,1), "%"), side =2, line=2.8, cex=1, font=2)

dev.off()
