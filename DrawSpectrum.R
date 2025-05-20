#!/usr/bin/env Rscript
library(tidyr)
library(ggplot2) # version = "3.2.1"
library(ggpubr)

args <- commandArgs(trailingOnly = TRUE)

# function to display help message
help_func <- function() {
  message("Usage: Rscript script.R <input_file> <output_file> <color_palette> <width> <height>")
  message("Arguments:")
  message("  input_file      : The path to the input CSV file.")
  message("  output_file     : The base name for the output files.")
  message("  color_palette   : The color palette to be used for the plot. Available options include 'jco', 'aom', 'aop', 'ucscgb', 'ggb', 'aaas', 'lancet', 'jama', 'nejm', 'npg', 'srj' and 'nature' ")
  message("  width           : Width of the plot.")
  message("  height          : Height of the plot.")
  message("Example:")
  message("  Rscript Step3_DrawSpectrum.R input.csv output 'jco' 12 6")
  quit("no")
}

# check for -h or --help flags
if ("-h" %in% args || "--help" %in% args) {
  help_func()
}

if (length(args)<5) {
  message("Five arguments must be supplied: input file, output file, color palette, width and height.\n")
  help_func()
}

input_file <- args[1]
output_file <- args[2]
palette <- args[3]
width <- as.numeric(args[4])
height <- as.numeric(args[5])

# function to calculate standerror
st.err <- function(x){
  sd(x)/sqrt(length(x))
}
# function to calculate lower confidence interval
lowCI <- function(x){
  mean(x)-qnorm(1-0.05/2)*st.err(x)
}
# function to calculate higher confidence interval
highCI <- function(x){
  mean(x)+qnorm(1-0.05/2)*st.err(x)
}
# Define all required functions within a single function
# function to get basic statistics of clustering result.
get_stats <- function (data_run) {
  dataNew <- data_run %>% gather(attributes, value, DS10:DS90)
  colnames(dataNew) <- c("PlantID","Cluster", "Depth", "DS_Value")
  dataNew$Cluster <- as.factor(dataNew$Cluster)
  data_mean <-aggregate(DS_Value~Cluster+Depth, data=dataNew, FUN="mean")
  data_se <- aggregate(DS_Value~Cluster+Depth, data=dataNew, FUN="st.err")
  data_lowCI <- aggregate(DS_Value~Cluster+Depth, data=dataNew, FUN="lowCI")
  data_highCI <- aggregate(DS_Value~Cluster+Depth, data=dataNew, FUN="highCI")
  data_var <- aggregate(DS_Value~Cluster+Depth, data=dataNew, FUN="var")
  data_sd <- aggregate(DS_Value~Cluster+Depth, data=dataNew, FUN="sd")
  cluster_stat <- data_mean
  cluster_stat["DS_SE"]<- data_se[,3]
  cluster_stat["DS_lowCI"]<-data_lowCI[,3]
  cluster_stat["DS_highCI"] <- data_highCI[,3]
  cluster_stat["DS_var"] <- data_var[,3]
  cluster_stat["DS_SD"] <- data_sd[,3]
  colnames(cluster_stat)[3] <- "DS_Mean"
  return(cluster_stat)
}

# the function to draw spectrum
suppressWarnings({
draw_spec <- function(cluster_stat, data_run){
  dataNew <- data_run %>% gather(attributes, value, DS10:DS90)
  colnames(dataNew) <- c("PlantID","Cluster", "Depth", "DS_Value")
  x <- seq(0.1:0.9,by=0.1)# change lable of axis label
  # the plot with 95% confidence interval
  p <-ggplot(cluster_stat, aes(x=Depth, y=DS_Mean, group=Cluster))+
    geom_line(data=dataNew, aes(x=Depth, y=DS_Value, group=PlantID), color="grey80")+
    geom_line(aes(color=Cluster), size=1.5)+
#   geom_ribbon(aes(ymin=DS_lowCI,ymax=DS_highCI, fill=Cluster),alpha=0.5)+
    facet_wrap(~Cluster, nrow=1)+
    theme_bw()+
    scale_x_discrete(labels=x)+
    ylim(0,5)+
    theme(axis.text=element_text(size=8,face = "bold"),axis.title=element_text(size=10,face="bold"),
          strip.text = element_text(size = 10, face="bold"),
          panel.grid.major = element_blank(),
          panel.grid.minor = element_blank(),
          legend.title = element_blank(),
          legend.position = "none")+
    ylab("DS")+
    xlab("Fraction of Depth")
  return (p)
}})
run <- read.csv(input_file)
x <- get_stats(run)
p <- draw_spec(x, run)
p <- ggpar(p, palette = palette)
ggsave(filename=paste0(output_file,"_spec.png"),plot=p,width=12,height=3)
write.csv(x, file=paste0(output_file,"_clusterstat.csv"))
ggsave(filename=paste0(output_file,"_spec.png"), plot=p, width=width, height=height)