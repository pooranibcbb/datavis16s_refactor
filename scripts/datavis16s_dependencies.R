#!/usr/bin/env Rscript


## CRAN packages
install.packages(c('BiocManager', 'import', 'ggplot2', 'remotes', 'RColorBrewer', 'scales', 'vegan', 'jsonlite', 'htmltools', 'htmlwidgets', 'plotly', 'docopt'), repos = c(CRAN = 'https://mran.microsoft.com/snapshot/2023-03-06/'))

BiocManager::install('biomformat')

## GitHub packages
remotes::install_github('cmap/morpheus.R', ref="2fd4f942423494f80103634682607af557dea228",dependencies=T)
remotes::install_github("MadsAlbertsen/ampvis2", dependencies=TRUE, ref="67e89d17228f91a1f6a9697097396d26584c2636" )
