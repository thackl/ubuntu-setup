#!/usr/bin/env Rscript
pkgs = commandArgs(trailingOnly=TRUE)
mis <- c();
for(pkg in pkgs)
  if(! require(pkg, character.only=T)) mis <- c(mis, pkg)

writeLines(mis)
