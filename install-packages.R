#!/usr/bin/env Rscript
pkgs = commandArgs(trailingOnly=TRUE)
print(pkgs)
install.packages(pkgs)
