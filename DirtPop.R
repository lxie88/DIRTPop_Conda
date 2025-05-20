#!/usr/bin/env Rscript

# Load required libraries
library(reticulate) 
library(roahd) 
library(optparse)

option_list = list(
  make_option(c("-f", "--file"), type="character", default=NULL, 
              help="dataset file name", metavar="character"),
  make_option(c("-o", "--out"), type="character", default="clustered.csv", 
              help="output file name [default= %default]", metavar="character"),
  make_option(c("-e", "--environment"), default="/opt/conda/envs/DIRTPop", help="conda environment", metavar="character"),
  make_option(c("-n", "--n_trial_kmeans"),  default="100", 
              help="the times of kmeans++ you want to run", metavar=""),
  make_option(c("-m", "--n_trial_kneedle"),  default="100", 
              help="the times of kneedle algorithm  you want to run", metavar=""),
  make_option(c("-k", "--n_cluster"), default="25", 
              help="the range of clusters number you want to test, if you put 25 , then the range is from 1 to 25", metavar="")) 

opt_parser = OptionParser(option_list=option_list)
opt = parse_args(opt_parser)
########################################################
if (is.null(opt$file)){
  print_help(opt_parser)
  stop("At least one argument must be supplied (input file).n", call.=FALSE)
}

# Function to check for the outlier filter
shapemagoutlier <- function(bestrun){
  depth = seq(0.1,0.9, length.out = 9)
  Kmax = max(bestrun[,"cluster_label"])
  Kmin = min(bestrun[,"cluster_label"])
  print(Kmax)
  print(Kmin)
  suppressWarnings({
  outlier_list <- c()
  for (i in seq(Kmin:Kmax)){
    c <- bestrun[bestrun$cluster_label==i,]
    if (nrow(c) > 2) {
      d <- c[, 2:10]
      data <- as.matrix(d, dimnames = NULL)
      fd = fData(depth, data)
      title <- paste0("cluster", i )
      ShapeOutlier <- outliergram(fd, display = F, Fvalue = 1,  main = list(title, "Shape_Outlier_Graph"))
      ShapeOutlier_id <- ShapeOutlier$ID_outliers
      MagOutlier <- fbplot(fd, display = F, adjust=T, main = title , Fvalue=1.50, xlab='Depth', ylab='DS_value')
      MagOutlier_id <- MagOutlier$ID_outliers
      outlier_list <- c(outlier_list,ShapeOutlier_id,MagOutlier_id)}
  }
  outlier_list <- as.numeric(names(outlier_list))
  outlier_list <- outlier_list[!is.na(outlier_list)]
  })
  return(outlier_list)
}


# Use the conda environments
use_condaenv("DirtPop")

# Load Python script
source_python("KmeansKneedle.py")

# Load data
ds <- inputdata_ds(opt$file)
dswithtag <- inputdata_dswithtag(opt$file)
# code to run spectrum pipeline 
# number of kmeans++ you want to run 
n_trial = as.integer(opt$n_trial_kmeans)
# number of kneedle algorithm you want to run 
n_trial_kneedle = as.integer(opt$n_trial_kneedle)
# number of clusters you want to test 
ncluster_test = as.integer(opt$n_cluster)
min_samples_clusters <- min(nrow(ds), ncluster_test)

run <- kmeansplusplus(n_trial, n_trial_kneedle, min_samples_clusters, ds, dswithtag)
i=1

# iteratively delete the outlier clusters 
while (i < 10 ) {
  # Ensure number of clusters does not exceed sample size
  if (length(shapemagoutlier(run)) > 0) {
    run <- run [-shapemagoutlier(run),]
    ds_new <- run[,2:10]
    dswithtag_new <- run [,1:10]
    # Update the kmeansplusplus function with possibly updated number of clusters
    if (nrow(run) < min_samples_clusters) {
      min_samples_clusters <- nrow(run)
    }
    if(min_samples_clusters > 2){
      run <- kmeansplusplus(n_trial, n_trial_kneedle, min_samples_clusters, ds_new, dswithtag_new)
    } else {
      break
    }
  } else {
    break
  }
}

# Clean the result
cleaned_run <- run

# Save the result
write.csv(cleaned_run, opt$out, row.names = FALSE)

