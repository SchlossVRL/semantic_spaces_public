#This file reads in and does pre-processing on data files
#for the color-concept semantics project.

#Load libraries
library(vegan)
library(lsa)
library(ape)

#Read csv flies
setwd("/Users/kushin/Documents/vss2022/R")
cca <- read.csv("../data/cc_assoc.csv", row.names=1) #color-concept association matrix
fic <- read.csv("../data/fic.csv", row.names=1) 	 #fiction word2vec
w2v <- read.csv("../data/w2v.csv", row.names=1)      #standard word2vec
col3d <- read.csv("../data/color_salmon.csv", row.names=1) #salmon 3d embedding for color triplets
kind3d <- read.csv("../data/kind_salmon.csv", row.names=1) #salmon 3d embedding for kind triplets
sym3d <- read.csv("../data/symbolic_salmon.csv", row.names=1) #salmon 3d embedding for symbol triplets

cdict= read.csv("../data/color_dict_uw58.csv")

#Compute 1 - cosine distances (so small values show small distances)
cccos <- 1 - cosine(t(cca))  #Color-concept association distances
ficcos <- 1 - cosine(t(fic)) #Fiction w2v distances
w2vcos <- 1 - cosine(t(w2v))  #Standard w2v distances
cold3dcos <- 1 - cosine(t(col3d)) 
kind3dcos <- 1 - cosine(t(kind3d)) 
sym3dcos <- 1 - cosine(t(sym3d)) 
#Compute 3d embeddings
cc3d <- cmdscale(as.dist(cccos), 3) #For color-concept association distances
fic3d <- cmdscale(as.dist(ficcos), 3) #For fiction w2v distances
w2v3d <- cmdscale(as.dist(cccos), 3) #For standard w2v distances

#Visualize cca and fic distances as phylo plot:
tip_cols = cbind(1:nrow(cca), max.col(cca[,4:ncol(cca)], 'first'))
tip_cols

tip_hexs = numeric(30)

for (color in 0:nrow(tip_cols)){
  tip_hexs[color] = cdict[cdict$index == tip_cols[color,2],]$hex
}

par(mfrow = c(1,2), mar = c(1,1,1,1), oma = c(2,2,2,2))
plot(as.phylo(hclust(as.dist(cccos))), type = "unrooted", main = "Color-concept space", show.tip.label=FALSE)
tiplabels(pch=c(2,3,4,5,6))


pdf(file="../data/ficw2v_tree.pdf",width=10, height=10)
par(bg='gray')
plot(as.phylo(hclust(as.dist(ficcos))), type = "unrooted", main = "Fiction w2v space",tip.color=tip_hexs)
dev.off()

pdf(file="../data/cca_tree.pdf",width=10, height=10)
par(bg='gray')
plot(as.phylo(hclust(as.dist(cccos))),  type = "unrooted",main = "Color-concept space",tip.color  =tip_hexs)
dev.off()


pdf(file="../data/col3d_tree.pdf",width=10, height=10)
plot(clear)
plot(as.phylo(hclust(as.dist(cold3dcos))),main = "color judgements", cex=1.2)
  dev.off()

pdf(file="../data/kind3d_tree.pdf",width=10, height=10)
plot(clear)
plot(as.phylo(hclust(as.dist(kind3dcos))),  type = "unrooted",main = "semantic judgements", cex=1.2)
dev.off()

pdf(file="../data/sym3d_tree.pdf",width=10, height=10)
plot(clear)
plot(as.phylo(hclust(as.dist(sym3dcos))),  type = "unrooted",main = "symbolic judgements", cex=1.2)
dev.off()




#Example of computing procrustes correlations between two embeddings:
protest(cc3d, fic3d) #Procrustes correlation between color-concept and fw2v embeddings

#Run models trying to predict CCA coordinates from fic w2v vectors here

#Predicting coordinates in triplet embeddings from ficw2v and cca embeddings:

d <- cbind(col3d, kind3d, sym3d, fic3d, cc3d) #Concatenate data in one matrix

#Give columns useful names:
names(d) <- c("cl1", "cl2","cl3","k1","k2","k3","s1","s2","s3","f1","f2","f3","cc1","cc2","cc3")

#Example model:

m <- lm(cl1 ~ f1+f2+f3+cc1+cc2+cc3, data = d) #Predict color-triplet dimension 1 from fw2v and cca embedding coordinates
#Look at results
summary(m)

