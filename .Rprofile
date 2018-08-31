options(repos=structure(c(CRAN="http://lib.stat.cmu.edu/R/CRAN/")))
# default X11() setting
setHook(
    packageEvent("grDevices", "onLoad"),
    function(...) grDevices::X11.options(type = "cairo"))
