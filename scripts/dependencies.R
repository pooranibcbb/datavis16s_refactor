#!/usr/bin/env Rscript

## Nephele is using R 3.4.x. The following script only works with this version!
if (as.numeric(version$major) > 3 || as.numeric(version$minor) >= 5) stop("This package only works with R version 3.4.x.  The version you are using is not compatible.")

options(repos=c(CRAN="https://cran.rstudio.com/"))

## Bioconductor 3.6
if (!"BiocInstaller" %in% installed.packages() || packageVersion("BiocInstaller") != "1.28.0") install.packages("BiocInstaller", repos="http://bioconductor.org/packages/3.6/bioc")
library(BiocInstaller)
if (!"biomformat" %in% installed.packages() || packageVersion("biomformat") != "1.6.0" ) biocLite('biomformat')


## devtools
if (!"devtools" %in% installed.packages()) install.packages("devtools")
library(devtools)
install_github('cmap/morpheus.R', ref="7ce5f6a3fdb947dba9014115b4c324fcd7ec7f5d",dependencies=T)
install_github("MadsAlbertsen/ampvis2", dependencies=TRUE, ref="66dec692dccc28d25a034f7f6eab8ca16bfd9165")
install_github("homerhanumat/bpexploder", ref="ae46f7f3753728795c857c37f2608eb7ea3a92df", dependencies=TRUE)
## change directory path
install_local("/Users/subramanianp4/git/nephele2/pipelines/datavis16s", dependencies=c("Depends", "Imports"), force=T)


