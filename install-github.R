#!/usr/bin/env Rscript
library(devtools)
pkgs = commandArgs(trailingOnly=TRUE)
print(pkgs)
devtools::install_github(pkgs)
