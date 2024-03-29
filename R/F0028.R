#' Find marker genes for each cluster
#'
#' This function takes an object of class iCellR and performs differential expression (DE) analysis to find marker genes for each cluster.
#' @param x An object of class iCellR.
#' @param data.type Choose from "main", "atac", "atac.imputed" and "imputed", default = "main"
#' @param fold.change A number that designates the minimum fold change for out put, default = 2.
#' @param pval.test Choose from "t.test", "wilcox.test", default = "t.test".
#' @param p.adjust.method Correction method. Choose from "holm", "hochberg", "hommel", "bonferroni", "BH", "BY","fdr", "none", default = "hochberg".
#' @param padjval Minimum adjusted p value for out put, default = 0.1.
#' @param low.cell.filt filter out clusters with low number of cells, default = 5.
#' @param Inf.FCs If set to FALSE the infinite fold changes would be filtered from out put, default = FALSE.
#' @param uniq If set to TRUE only genes that are a marker for only one cluster would be in the out put, default = FALSE.
#' @param positive If set to FALSE both the up regulated (positive) and down regulated (negative) markers would be in the out put, default = TRUE.
#' @return An object of class iCellR
#' @export
findMarkers <- function (x = NULL,
          data.type = "main",
          pval.test = "t.test",
          p.adjust.method = "hochberg",
          fold.change = 2,
          padjval = 0.1,
          low.cell.filt = 5,
          Inf.FCs = FALSE,
          uniq = FALSE,
          positive = TRUE) {
  if ("iCellR" != class(x)[1]) {
    stop("x should be an object of class iCellR")
  }
  ###########
#  x <- clust.avg.exp(x)
#  dat <- x@main.data
  ## get main data
  if (data.type == "main") {
    dat <- x@main.data
  }
  if (data.type == "imputed") {
    dat <- x@imputed.data
  }
  if (data.type == "atac") {
    dat <- x@atac.main
  }
  if (data.type == "atac.imputed") {
    dat <- x@atac.imputed
  }
  # get cluster data
  # get avrages
    x <- clust.avg.exp(x, data.type = data.type, low.cell.filt = low.cell.filt)
##########
  DATA <- x@best.clust
  if(!is.numeric(DATA$clusters)){
    stop("Cluster names have to be numeric")
  }
  ############## set wich clusters you want as condition 1 and 2
  MyClusts <- as.numeric(unique(DATA$clusters))
  MyClusts <- sort(MyClusts)
############################### loop start
  for (i in MyClusts) {
    message(paste(" Finding markers for cluster:",i,"..."))
    Noi <- MyClusts[-which((MyClusts) %in% i)]
    Table=DATA
    Cluster0 <- row.names(subset(Table, Table$clusters %in% i))
    Cluster1 <- row.names(subset(Table, Table$clusters %in% Noi))
    ############## Filter
#    cond1 <- dat[,Cluster0]
#    cond2 <- dat[,Cluster1]
    cond1 <- dat[ , which(names(dat) %in% Cluster0)]
    cond2 <- dat[ , which(names(dat) %in% Cluster1)]
    ### merge both for pval length not matching error
    mrgd <- cbind(cond1,cond2)
#    mrgd <- merge(cond1, cond2, by="row.names")
#    row.names(mrgd) <- mrgd$Row.names
#    mrgd <- mrgd[,-1]
    mrgd <- data.matrix(mrgd)
    # mean
    meansCond1 <- apply(cond1, 1, function(cond1) {mean(cond1)})
    meansCond2 <- apply(cond2, 1, function(cond2) {mean(cond2)})
    baseMean <- apply(mrgd, 1, function(mrgd) {mean(mrgd)})
    baseSD <- apply(mrgd, 1, function(mrgd) {sd(mrgd)})
    # FC
    FC <- meansCond1/meansCond2
    FC.log2 <- log2(FC)
    # dims
    Cond1_Start <- 1
    Cond1_End <- dim(cond1)[2]
    Cond2_Start <- dim(cond1)[2] + 1
    Cond2_End <- dim(cond1)[2] + dim(cond2)[2]
    # filter
    if (positive == TRUE) {
      FiltData <- subset(FC.log2, FC.log2 > log2(fold.change))
    } else {
      FiltData <- subset(FC.log2, FC.log2 < -log2(fold.change) | FC.log2 > log2(fold.change))
    }
    mrgd <- subset(mrgd, row.names(mrgd) %in% row.names(as.data.frame(FiltData)))
    # pval
    if (pval.test == "t.test") {
      Pval <- apply(mrgd, 1, function(mrgd) {
        t.test(x = mrgd[Cond1_Start:Cond1_End], y = mrgd[Cond2_Start:Cond2_End])$p.value
      })
    }
    ############
    if (pval.test == "wilcox.test") {
      Pval <- apply(mrgd, 1, function(mrgd) {
        wilcox.test(x = mrgd[Cond1_Start:Cond1_End], y = mrgd[Cond2_Start:Cond2_End])$p.value
      })
    }
    # padj
    FDR <- p.adjust(Pval, method = p.adjust.method)
    # combine
    Stats <- cbind(
      baseMean = baseMean,
      baseSD = baseSD,
      MeanCond1 = meansCond1,
      MeanCond2 = meansCond2,
      FC=FC,
      FC.log2=FC.log2)
    colnames(Stats) <- c("baseMean","baseSD","AvExpInCluster", "AvExpInOtherClusters","foldChange","log2FoldChange")
    # cbind pvals
    clusters <- rep(i,length(FDR))
    # make cluster names
    Stats1 <- cbind(
      pval = Pval,
      padj = FDR,
      clusters = clusters)
    # filter
    Stats <- as.data.frame(Stats)
    Stats1 <- as.data.frame(Stats1)
    Stats1 <- subset(Stats1, Stats1$padj < padjval)
    # merge both pvals and stats
    mrgdall <- merge(Stats, Stats1, by="row.names")
    row.names(mrgdall) <- mrgdall$Row.names
    mrgdall <- mrgdall[,-1]
    ############################# get avrage data
#    if (add.avg == TRUE) {
      AvData <- x@clust.avg
      row.names(AvData) <- AvData$gene
      mrgdall <- merge(mrgdall, AvData, by="row.names")
      row.names(mrgdall) <- mrgdall$Row.names
      mrgdall <- mrgdall[,-1]
#    }
    # make it an object
    DatNmaes=paste("DATAcluster",i,sep="_")
    eval(call("<-", as.name(DatNmaes), mrgdall))
  }
############################### loop end
# merge all
  filenames <- ls(pattern="DATAcluster_")
  datalist <- mget(filenames)
  df <- do.call("rbind", datalist)
  row.names(df) <- make.names(df$gene, unique=TRUE)
  df <- subset(df, gene != "NA")
####
  if (uniq == TRUE) {
    data <- (as.data.frame(table(df$gene)))
  ###########
    ToSort <- data$Freq
    datanew <- as.matrix(data)
    datanew <- (datanew[order(ToSort, decreasing = TRUE),])
    datanew <- as.data.frame(data)
    datanew <- subset(datanew, datanew$Freq == 1)
    datanew <- as.character(datanew$Var1)
    myDATA = df
    myDATA <- subset(myDATA, myDATA$gene %in% datanew)
    df <- myDATA
  }
  if (Inf.FCs == FALSE) {
    df <- subset(df, log2FoldChange != Inf)
    df <- subset(df, log2FoldChange != Inf & log2FoldChange != -Inf)
  }
  ########
#### old
#  df <- df[order(df$log2FoldChange,decreasing = TRUE),]
#  df <- df[order(df$clusters,decreasing = FALSE),]
#### new
  myFC <- df$log2FoldChange
  dfm <- as.matrix(df)
  dfm <- dfm[order(myFC, decreasing = TRUE),]
  #
  dfm <- as.data.frame(dfm)
  myClustOrd <- dfm$clusters
  dfm <- as.matrix(dfm)
  dfm <- dfm[order(myClustOrd, decreasing = FALSE),]
  df <- as.data.frame(dfm)
  #######
  df$clusters <- as.numeric(as.character(df$clusters))
  df$baseMean <- as.numeric(as.character(df$baseMean))
######
  message("All done!")
  return(df)
}
