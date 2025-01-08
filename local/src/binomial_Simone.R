#!/usr/bin/env Rscript

args <- commandArgs(trailingOnly = T)
infile <- args[1]
outfile <- args[2]

data <- read.table(infile, header=TRUE, stringsAsFactors=FALSE, sep="\t")

rbinom <- function(mut) {
  refreads <- as.integer(mut[8])
  mutreads <- as.integer(mut[9])
  cn <- as.integer(mut[11])
  tot <- refreads+mutreads
  s <- 1/cn
  sqrt_1_s <- (1-s)**(1/2)
  sqrt_s <- (s)**(1/2)
  sqrt_n <- (tot)**(1/2)
  if (cn==0) {
    return(0)
  }
  #print(paste0('Cn= ', cn))
  #print(paste0('refreads= ', refreads))
  #print(paste0('mutreads= ', mutreads))
  #s - (sqrt(1-s)*sqrt(s))/(sqrt(n)  < x < s + (sqrt(1-s)*sqrt(s))/(sqrt(n)
  if (mutreads/tot >  s - ((sqrt_1_s*sqrt_s)/sqrt_n) && mutreads/tot <  s + ((sqrt_1_s*sqrt_s)/sqrt_n)) {
    return(1)
  } else {
    return(0)
  }
}
new_binom <- apply(data, 1, rbinom)
data$binomp <- new_binom

write.table(data, gzfile(outfile), sep="\t", quote=FALSE, col.names=TRUE, row.names=TRUE)
