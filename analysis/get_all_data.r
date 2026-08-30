#This file reads in and does pre-processing on data files
#for the color-concept semantics project.

#Load libraries
library(vegan)
library(lsa)
library(ape)

#Read csv flies
setwd("/Users/kushinm/Documents/Github/semantic_spaces/analysis/")
gpt<- read.csv("../data/gpt3embeddings.csv")
cca <- read.csv("../data/semantic_alignment_data/cc_assoc.csv", row.names=1) #color-concept association matrix
fic <- read.csv("../data/semantic_alignment_data/fic.csv", row.names=1) 	 #fiction word2vec
w2v <- read.csv("../data/semantic_alignment_data/w2v.csv", row.names=1)      #standard word2vec
col3d <- read.csv("../data/semantic_alignment_data/color_salmon.csv", row.names=1) #salmon 3d embedding for color triplets
kind3d <- read.csv("../data/semantic_alignment_data/kind_salmon.csv", row.names=1) #salmon 3d embedding for kind triplets
sym3d <- read.csv("../data/semantic_alignment_data/symbolic_salmon.csv", row.names=1) #salmon 3d embedding for symbol triplets

cdict= read.csv("../data/color_dict_uw58.csv")

#Compute 1 - cosine distances (so small values show small distances)
cccos <- 1 - cosine(t(cca))  #Color-concept association distances
ficcos <- 1 - cosine(t(fic)) #Fiction w2v distances
w2vcos <- 1 - cosine(t(w2v))  #Standard w2v distances
gptcos<- 1 - cosine(t(gpt[, -c(1, ncol(gpt))]))
cold3dcos <- 1 - cosine(t(col3d)) 
kind3dcos <- 1 - cosine(t(kind3d)) 
sym3dcos <- 1 - cosine(t(sym3d)) 
#Compute 3d embeddings
cc3d <- cmdscale(as.dist(cccos), 3) #For color-concept association distances
fic3d <- cmdscale(as.dist(ficcos), 3) #For fiction w2v distances
w2v3d <- cmdscale(as.dist(cccos), 3) #For standard w2v distances
gpt3d<- cmdscale(as.dist(gptcos), 3)
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



pdf(file="../data/gpt_tree.pdf",width=10, height=10)
plot(as.phylo(hclust(as.dist(gptcos))),  type = "unrooted",main = "GPT-3", cex=1.2, show.tip.label = gpt$concept)
dev.off()




### paper procrustes

protest(gpt3d,fic3d)
protest(gpt3d,cc3d )
protest(fic3d,cc3d)

rownames(gpt3d)<-seq(from=1,to=30)
rownames(fic3d)<-seq(from=1,to=30)
rownames(cc3d)<-seq(from=1,to=30)
rownames(cca)<-seq(from=1,to=30)

### holdout reg


###fic
holdout_seq= seq(from=1,to=30,by=5)
c1_results<-{}
c2_results<-{}
c3_results<-{}

for(i in 0:4){
  holdout_rows = holdout_seq+i
  pred_df<-data.frame(fic3d[!(rownames(fic3d)%in%holdout_rows),])
  pred_df$c1<-cc3d[!(rownames(cc3d)%in%holdout_rows),1]
  pred_df$c2<-cc3d[!(rownames(cc3d)%in%holdout_rows),2]
  pred_df$c3<-cc3d[!(rownames(cc3d)%in%holdout_rows),3]
  # pred_df$c1<-cca[!(rownames(cca)%in%holdout_rows),'c1']
  # pred_df$c2<-cca[!(rownames(cca)%in%holdout_rows),'c2']
  # pred_df$c3<-cca[!(rownames(cca)%in%holdout_rows),'c3']
  
  
  c1_model = lm(c1~X1+X2+X3,data=pred_df)
  c2_model = lm(c2~X1+X2+X3,data=pred_df)
  c3_model = lm(c3~X1+X2+X3,data=pred_df)
  
  
  preds = predict(c1_model, newdata = data.frame(fic3d[(rownames(fic3d)%in%holdout_rows),]))
  targets = cc3d[(rownames(cc3d)%in%holdout_rows),1]
  # targets = cca[(rownames(cca)%in%holdout_rows),'c1']
  c1_results<- rbind(c1_results,cbind(preds, targets))
  
  preds = predict(c2_model, newdata = data.frame(fic3d[(rownames(fic3d)%in%holdout_rows),]))
  targets = cc3d[(rownames(cc3d)%in%holdout_rows),2]
  # targets = cca[(rownames(cca)%in%holdout_rows),'c2']
  c2_results<- rbind(c2_results,cbind(preds, targets))
  
  preds = predict(c3_model, newdata = data.frame(fic3d[(rownames(fic3d)%in%holdout_rows),]))
  targets = cc3d[(rownames(cc3d)%in%holdout_rows),3]
  # targets = cca[(rownames(cca)%in%holdout_rows),'c3']
  c3_results<- rbind(c3_results,cbind(preds, targets))
  
  
}

colnames(c1_results)<- c('pred','target')
colnames(c2_results)<- c('pred','target')
colnames(c3_results)<- c('pred','target')
c1_results<- as.data.frame(c1_results)
c2_results<- as.data.frame(c2_results)
c3_results<- as.data.frame(c3_results)

print(paste0('coord 1 correlations:',round(cor(c1_results$pred,c1_results$target),3)))

print(paste0('coord 2 correlations:',round(cor(c2_results$pred,c2_results$target),3)))

print(paste0('coord 3 correlations:',round(cor(c3_results$pred,c3_results$target),3)))

predicted_coords<-data.frame(cbind(concepts = c1_results$concepts, c1_pred= c1_results$pred,c2_pred=  c2_results$pred, c3_pred=c3_results$pred))







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

