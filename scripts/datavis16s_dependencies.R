#!/usr/bin/env Rscript

## fix the CRAN repo to most recent MRAN snapshot
options(repos = c(CRAN = 'https://mran.microsoft.com/snapshot/2023-03-06/'))
## CRAN packages
install.packages(c('BiocManager', 'import', 'ggplot2', 'remotes', 'RColorBrewer', 'scales', 'vegan', 'jsonlite', 'htmltools', 'htmlwidgets', 'plotly', 'docopt'), Ncpus=8)

BiocManager::install('biomformat', update=FALSE, Ncpus=8)

## GitHub packages
remotes::install_github('cmap/morpheus.R', ref="2fd4f942423494f80103634682607af557dea228",dependencies=c('Depends', 'Imports', 'LinkingTo'), Ncpus=8, upgrade='never')
remotes::install_github("MadsAlbertsen/ampvis2", dependencies=c('Depends', 'Imports', 'LinkingTo'), ref="67e89d17228f91a1f6a9697097396d26584c2636", Ncpus=8, upgrade='never')
