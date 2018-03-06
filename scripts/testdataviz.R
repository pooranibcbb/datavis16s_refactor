options(warn = 1)
rmall()
library(ampvis2)
library(plotly)
library(htmlwidgets)
library(htmltools)
library(jsonlite)
source("~/git/nephele2/pipelines/dataviz16s/R/plotlyGrid.R")
source("scripts/taxonomy.R")
#dir <- "/Users/subramanianp4/HF/graphs"

sampdepth <- 25000

otu <- read.delim("test/OTU_table.txt", check.names = FALSE, na.strings = '', row.names = 1)

map <- read.delim("test/vanessa_HF_mapfile.txt", check.names = FALSE)
colnames(map) <- gsub("^\\#SampleID$", "SampleID", colnames(map))
map$BarcodeSequence <- NULL
map$LinkerPrimerSequence <- NULL
amp <- amp_load(otu, map)
amp
stop()
## rarefaction curve
amp <- amp_subset_samples(amp, minreads = sampdepth)
rarecurve <- ggplotly(amp_rarecurve(amp, color_by = "TreatmentGroup"), tooltip = c("SampleID"))
df <- plotly_data(rarecurve)
df_new <- split(df, df$SampleID)
tg <- which(colnames(df) == "TreatmentGroup")
desc <-  which(colnames(df) == "Description")
n <- ncol(df)
df_new <- lapply(df_new, function(x) {x <- data.frame(x); y <- unlist(c(rep(NA, tg-1), x[1,tg:desc], rep(NA,(n- desc)))); names(y) <- colnames(x); rbind(x,y)   })
df_new <- do.call(rbind.data.frame, df_new)
plotlyGrid(rarecurve, file.path(dir, "rarecurve.html"), data = df_new)

## PCoA
pcoa <- amp_ordinate(amp, filter_species = 0.01, type="PCOA", distmeasure = "binomial", transform = "none", sample_color_by = "TreatmentGroup", sample_colorframe = TRUE, detailed_output = TRUE)
plotlyGrid(pcoa$plot, file.path(dir, "pcoa_binomial.html"), data=pcoa$dsites)
pcoa_bc <- amp_ordinate(amp, filter_species = 0.01, type="PCOA", distmeasure = "bray", transform = "hellinger", sample_color_by = "TreatmentGroup", sample_colorframe = TRUE, detailed_output = TRUE)
plotlyGrid(pcoa_bc$plot, file.path(dir, "pcoa_braycurtis.html"), data=pcoa_bc$dsites)

## heatmap

amprel <- amp_subset_samples(amp, minreads = sampdepth, normalise = TRUE)
amprel <- filterlowabund(amprel, level = 0.1)
sn <- shortnames(amprel$tax)
sn <- paste(amprel$tax$OTU, sn)
colors <- rev(colorRampPalette( RColorBrewer::brewer.pal(11, "RdYlBu"), bias=1)(100))
mm <- max(amprel$abund)
values <-  expm1(seq(log1p(0), log1p(mm), length.out=100))
mat <- amprel$abund
row.names(mat) <- sn
tg <- which(colnames(amprel$metadata) == "TreatmentGroup")
desc <-  which(colnames(amprel$metadata) == "Description") - 1
mat <- mat[,amprel$metadata$SampleID]
heatmap <- morpheus::morpheus(mat,colorScheme = list(scalingMode="fixed", values=values, colors=colors, stepped=FALSE), Rowv=nrow(mat):1, columnAnnotations = amprel$metadata[,tg:desc])
saveWidget(heatmap, file = file.path(dir, "seq_heatmap.html"), selfcontained = FALSE)

ampfamily <- highertax(amprel, taxlevel="Family")
mm <- max(ampfamily$abund)
values <-  expm1(seq(log1p(0), log1p(mm), length.out=100))
mat <- ampfamily$abund
mat <- mat[,ampfamily$metadata$SampleID]
famheatmap <- morpheus::morpheus(mat,colorScheme = list(scalingMode="fixed", values=values, colors=colors, stepped=FALSE), Rowv=nrow(mat):1, columnAnnotations = ampfamily$metadata[,tg:desc])
saveWidget(famheatmap, file = file.path(dir, "family_heatmap.html"), selfcontained = FALSE, title="family heatmap")

## alpha diversity
alphadiv <- amp_alphadiv(amp, measure="shannon", richness = TRUE, rarefy = min(colSums(amp$abund)) )

divplots <- function(adiv, col) {
  shannon <-  bpexploder::bpexploder(alphadiv, settings=list(groupVar=col, yVar="Shannon", tipText = list(SampleID = "SampleID", Shannon = "Shannon Index", Description = "Desc"), relativeWidth=0.9))
  chao1 <- bpexploder::bpexploder(alphadiv, settings=list(groupVar=col, yVar="Chao1", tipText = list(SampleID = "SampleID", Chao1 = "Species Richness", Description = "Desc"), relativeWidth=0.9))
  return(list(shannon, chao1))
}

divwidget <- unlist(lapply(colnames(amp$metadata)[tg:desc], function(x) divplots(alphadiv, x)), recursive = FALSE)
combo <- manipulateWidget::combineWidgets(list=divwidget, byrow = FALSE)
nonplotlyGrid(combo, file.path(dir, "species_diversity.html"), data=alphadiv, title="species diversity", jquery = TRUE)
