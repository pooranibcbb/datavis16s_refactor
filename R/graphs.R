#' Subset and rarefy OTU table.
#'
#' @description Subset and/or rarefy OTU table.
#'
#' @param amp  ampvis2 object
#' @param sampdepth  sampling depth.  See details.
#' @param rarefy  rarefy the OTU table in addition to subsetting
#' @param ... other parameters to pass to amp_subset_samples
#'
#' @details \code{sampdepth} will be used to filter out samples with fewer than this number of reads.  If
#' rarefy is TRUE, then it will also be used as the depth at which to subsample using vegan function
#' rrarefy.
#'
#' @return ampvis2 object
#'
#' @importFrom vegan rrarefy
#'
subsetamp <- function(amp, sampdepth, rarefy=FALSE, ...) {
  if (rarefy & !is.null(sampdepth)) {
    cmnd <- 'otu <- rrarefy(t(amp$abund), sampdepth)'
    logoutput(cmnd)
    eval(parse(text=cmnd))
    amp$abund <- as.data.frame(t(otu))
  }

  cmnd <- 'amp <- amp_subset_samples(amp, minreads = sampdepth, ...)'
  logoutput(cmnd)
  eval(parse(text=cmnd))

  ampvis2:::print.ampvis2(amp)
  writeLines('')
  return(amp)
}

#' Read in data
#'
#' @param mapfile  full path to mapfile.  must contain SampleID, TreatmentGroup, and Description columns
#' @param datafile  full path to input data file.  must be either biom file or tab delimited text file
#' OTU table with 7 level taxonomy.
#' @param tsvfile  Logical.  Is datafile a tab-delimited text file? See details.
#' @param mincount  minimum number of reads
#' @return ampvis2 object
#'
#' @details datafile may be either biom file or text file.  If text file, it should have ampvis2 OTU table
#' format \url{https://madsalbertsen.github.io/ampvis2/reference/amp_load.html#the-otu-table}. If the
#' number of reads is less than mincount, the function will give an error, as we cannot make graphs
#' with so few counts.
#'
#' @export
#'
#' @importFrom biomformat read_biom biom_data observation_metadata
#'
readindata <- function(mapfile, datafile, tsvfile=FALSE, mincount=10) {
  logoutput(paste("Reading in map file", mapfile))
  map <- read.delim(mapfile, check.names = FALSE, colClasses = "character",  na.strings = '', comment.char = '')
  colnames(map) <- gsub("^\\#SampleID$", "SampleID", colnames(map))
  map$BarcodeSequence <- NULL
  map$LinkerPrimerSequence <- NULL

  if (!all(c("SampleID", "TreatmentGroup", "Description") %in% colnames(map))) {
    stop("Map file missing necessary columns.")
  }

  logoutput(paste("Reading in data file", datafile))
  if ((tsvfile)) {
    otu <- read.delim(datafile, check.names = FALSE, na.strings = '', row.names = 1)
  } else {
    biom <- read_biom(datafile)
    otu <- as.data.frame(as.matrix(biom_data(biom)))
    tax <- observation_metadata(biom)

    ## qiime biom file
    if (class(tax) == "list") {
      tax <- t(sapply(tax, "[", i=1:7))
    }

    ## Check if tax has 7 columns
    if (ncol(tax) != 7) {
      stop("taxonomy does not have 7 levels.")
    }
    colnames(tax) <- c("Kingdom", "Phylum", "Class", "Order", "Family", "Genus", "Species")
    ## greengenes
    tax <- apply(tax, 2, function(x) { v <- grep("_unclassified$", x); x[v] <- NA; x })
    tax <- apply(tax, 2, function(x) { gsub("^[kpcofgs]__", "", x) })
    tax[which(tax %in% c("", "none"))] <- NA
    otu <- cbind(otu, tax)
  }

  cmnd <- 'amp <- amp_load(otu, map)'
  logoutput(cmnd)
  eval(parse(text=cmnd))
  ampvis2:::print.ampvis2(amp)
  writeLines('')

  if (sum(amp$abund) < mincount) {
    stop(paste0("Not enough counts in OTU table to make any graphs. At least ", mincount, " are needed."))
  }

  return(amp)

}


#' Make rarefaction curve graph
#'
#' @param mapfile  full path mapping file
#' @param datafile full path to OTU file
#' @param outdir full path to output directory
#' @param amp  (Optional) ampvis2 object. may be specified instead of mapfile and datafile
#' @param colors (Optional) color vector - length equal to number of TreatmentGroups in mapfile
#' @param ... parameters to pass to \code{\link{readindata}}
#'
#' @return Saves rarefaction curve plot to output directory.
#' @export
#'
#' @importFrom plotly ggplotly plotly_data
#' @importFrom ggplot2 scale_color_manual
#'
rarefactioncurve <- function(mapfile, datafile, outdir, amp, colors=NULL, ...) {
  if (missing(amp)) {
    cmnd <- 'amp <- readindata(mapfile=mapfile, datafile=datafile, ...)'
    logoutput(cmnd)
    eval(parse(text=cmnd))
  }
  rarecurve <- amp_rarecurve(amp, color_by = "TreatmentGroup")

  on.exit(graphics.off())

  if (!is.null(colors)) rarecurve <- rarecurve + scale_color_manual(values=colors)

  ## suppress ggplotly warning to install dev version of ggplot2, as it is out of date
  withCallingHandlers({
    rarecurve <- ggplotly(rarecurve, tooltip = c("SampleID"))
  }, message=function(c) {
    if (startsWith(conditionMessage(c), "We recommend that you use the dev version of ggplot2"))
      invokeRestart("muffleMessage")
  })

  df <- plotly_data(rarecurve)
  df_new <- split(df, df$SampleID)
  tg <- which(colnames(df) == "TreatmentGroup")
  desc <-  which(colnames(df) == "Description")
  n <- ncol(df)

  df_new <- lapply(df_new, function(x) {x <- data.frame(x); y <- unlist(c(rep(NA, tg-1), x[1,tg:desc], rep(NA,(n- desc)))); names(y) <- colnames(x); rbind(x,y)   })
  df_new <- do.call(rbind.data.frame, df_new)
  plotlyGrid(rarecurve, file.path(outdir, "rarecurve.html"), data = df_new)
  logoutput(paste0('Saving rarefaction curve table to ', file.path(outdir, 'rarecurve.txt') ))
  write.table(df_new, file.path(outdir, 'rarecurve.txt'), quote=FALSE, sep='\t', row.names=FALSE, na="")
}


#' PCoA plots
#'
#' @param mapfile  full path to map file
#' @param datafile full path to input OTU file
#' @param outdir  full path to output directory
#' @param amp  ampvis2 object. may be specified instead of mapfile and datafile
#' @param sampdepth  sampling depth
#' @param distm  distance measure for PCoA.  any that are supported by \link[ampvis2]{amp_ordinate}
#' except for unifrac, wunifrac, and none.
#' @param filter_species Remove low abundant OTU's across all samples below this threshold in percent.
#' Setting this to 0 may drastically increase computation time.
#' @param rarefy Logical. Should the OTU table be rarefied to the sampling depth?  See details.
#' @param colors (Optional) color vector - length equal to number of TreatmentGroups in mapfile
#' @param ... parameters to pass to  \code{\link{readindata}}
#'
#' @return Saves pcoa plots to outdir.
#'
#' @importFrom ggplot2 scale_color_manual ggtitle
#'
#' @export
#'
pcoaplot <- function(mapfile, datafile, outdir, amp, sampdepth = NULL, distm="binomial", filter_species=0.1, rarefy=FALSE, colors=NULL, ...) {
  if (missing(amp)) {
    amp <- readindata(mapfile=mapfile, datafile=datafile, ...)
  }

  if (!is.null(sampdepth)) {
    cmnd <- paste0('amp <- subsetamp(amp, sampdepth = ', sampdepth,', rarefy=',rarefy, ')')
    logoutput(cmnd)
    eval(parse(text=cmnd))
  }

  on.exit(graphics.off())

#  for (distm in distmeasures) {
#    graphics.off()

    cmnd <- paste0('pcoa <- amp_ordinate(amp, filter_species =', filter_species, ',type="PCOA", distmeasure ="', distm, '",sample_color_by = "TreatmentGroup", detailed_output = TRUE, transform="none")')
    logoutput(cmnd)
    eval(parse(text=cmnd))
    if (!is.null(colors)) pcoa$plot <- pcoa$plot + scale_color_manual(values=colors) + ggtitle(paste("PCoA with", distm, "distance"))

    outfile <- file.path(outdir, paste0("pcoa_", distm, ".html"))
    plotlyGrid(pcoa$plot, outfile, data=pcoa$dsites)
    tabletsv <- gsub('.html$', '.txt', outfile)
    logoutput(paste0('Saving ', distm, ' PCoA table to ', tabletsv))
    write.table(pcoa$dsites, tabletsv, quote=FALSE, sep='\t', row.names=FALSE, na="")
##  }
}


#' Morpheus heatmap
#'
#' @description Creates heatmaps using Morpheus R API \url{https://software.broadinstitute.org/morpheus/}.  The heatmaps are made
#' using relative abundances.
#'
#' @param mapfile full path to mapping file
#' @param datafile  full path to input OTU file
#' @param outdir  full path to output directory
#' @param amp  (Optional) ampvis2 object. may be specified instead of mapfile and datafile
#' @param sampdepth sampling depth
#' @param rarefy Logical. Rarefy the OTU table if sampdepth is specified.
#' @param filter_level minimum abundance to show in the heatmap
#' @param taxlevel vector of taxonomic levels to graph.  must be subset of
#' c("Kingdom", "Phylum", "Class", "Order", "Family", "Genus", "Species", "seq").  See Details.
#' @param ...  parameters to pass to  \code{\link{readindata}}
#'
#' @return  Saves heatmaps to outdir.
#' @export
#'
#' @details For the \code{taxlevel} parameter, each level is made into a separate heatmap.  "seq" makes
#'  the heatmap with no collapsing of taxonomic levels.
#'
#' @importFrom morpheus morpheus
#' @importFrom htmlwidgets saveWidget appendContent
#'
#' @examples
#' \dontrun{
#'  morphheatmap(mapfile="mapfile.txt", datafile="OTU_table.txt", outdir="outputs/graphs",
#'  sampdepth = 25000, taxlevel = c("Family", "seq"), tsvfile=TRUE)
#' }
#'
#'
morphheatmap <- function(mapfile, datafile, outdir, amp, sampdepth = NULL, rarefy=FALSE, filter_level = 0.1, taxlevel=c("seq"), ...) {
  if (missing(amp)) {
    amp <- readindata(mapfile=mapfile, datafile=datafile, ...)
  }

  if (!is.null(sampdepth)) {
    cmnd <- 'amp <- subsetamp(amp, sampdepth = sampdepth, rarefy=rarefy)'
    logoutput(cmnd, 1)
    eval(parse(text=cmnd))
  }

  cmnd <- 'amp <- amp_subset_samples(amp, normalise = TRUE)'
  logoutput(cmnd)
  eval(parse(text=cmnd))

  if (!all(nrow(amp$abund) > 1, ncol(amp$abund) > 1)) {
    stop("OTU table must be at least 2x2 for heatmap.")
  }


  tg <- which(colnames(amp$metadata) == "TreatmentGroup")
  desc <-  which(colnames(amp$metadata) == "Description") - 1
  colors <- rev(colorRampPalette( RColorBrewer::brewer.pal(11, "RdYlBu"), bias=1)(100))

  makeheatmap <- function(tl, amp) {
    if (tl != "seq") {
      amptax <- highertax(amp, taxlevel=tl)
    } else {
      amptax <- amp
    }

    amptax <- filterlowabund(amptax, level = filter_level)
    sntax <- ifelse(tl == "seq", "Species", tl)
    sn <- shortnames(amptax$tax, taxa=sntax)
    sn <- paste(amptax$tax$OTU, sn)

    mm <- max(amptax$abund)
    values <-  expm1(seq(log1p(0), log1p(mm), length.out=100))
    mat <- amptax$abund
    row.names(mat) <- sn
    mat <- mat[,amptax$metadata$SampleID]
    heatmap <- morpheus(mat,colorScheme = list(scalingMode="fixed", values=values, colors=colors, stepped=FALSE), Rowv=nrow(mat):1, columnAnnotations = amptax$metadata[,tg:desc])

    outdir <- tools:::file_path_as_absolute(outdir)
    outfile <- file.path(outdir, paste0(tl, "_heatmap.html"))
    logoutput(paste("Saving plot to", outfile))
    heatmap$width = '100%'
    heatmap$height = '90%'
    tt <- tags$div(heatmap, style="position: absolute; top: 10px; right: 40px; bottom: 40px; left: 40px;")
    save_fillhtml(tt, file=outfile, bodystyle = 'height:100%; width:100%;overflow:hidden;')
  }

  for (t in taxlevel) {
    cmnd <- paste0('makeheatmap("', t, '", amp)')
    logoutput(cmnd)
    if (inherits(try(eval(parse(text=cmnd))), "try-error")){
      warning(paste("Heatmap at ", t, " level failed."))
    }
  }

}

#' Alpha diversity boxplot
#'
#' Plots exploding boxplot of shannon diversity and Chao species richness.  If sampling depth is NULL,
#' rarefies OTU table to the minimum readcount of any sample.  If this is low, then the plot will fail.
#'
#' @param mapfile  full path to map file
#' @param datafile full path to input OTU file
#' @param outdir  full path to output directory
#' @param amp  ampvis2 object. may be specified instead of mapfile and datafile
#' @param sampdepth  sampling depth
#' @param colors colors to use for plots
#' @param ... other parameters to pass to \link{readindata}
#'
#' @return Save alpha diversity boxplots to outdir.
#' @export
#'
#' @importFrom bpexploder bpexploder
#'
adivboxplot <- function(mapfile, datafile, outdir, amp, sampdepth = NULL, colors = NULL, ...) {
  if (missing(amp)) {
    amp <- readindata(mapfile=mapfile, datafile=datafile, ...)
  }

  if (is.null(sampdepth)) sampdepth <-  min(colSums(amp$abund))

  cmnd <- paste0('alphadiv <- amp_alphadiv(amp, measure="shannon", richness = TRUE, rarefy = ', sampdepth, ')')
  logoutput(cmnd)
  eval(parse(text=cmnd))

  logoutput(paste0('Saving alpha diversity table to ', file.path(outdir, 'alphadiv.txt') ))
  write.table(alphadiv, file.path(outdir, 'alphadiv.txt'), quote=FALSE, sep='\t', row.names=FALSE, na="")

  tg <- which(colnames(amp$metadata) == "TreatmentGroup")
  desc <- which(colnames(amp$metadata) == "Description") - 1

  divplots <- function(adiv, col, colors) {
    if (col == "TreatmentGroup") {
      lc <- colors
    } else {
      lc <- NULL
    }
    shannon <-  bpexploder(alphadiv, settings=list(groupVar=col, yVar="Shannon", tipText = list(SampleID = "SampleID", Shannon = "Shannon Index", Description = "Desc"), relativeWidth=0.8, levelColors = lc))
    chao1 <- bpexploder(alphadiv, settings=list(groupVar=col, yVar="Chao1", tipText = list(SampleID = "SampleID", Chao1 = "Species Richness", Description = "Desc"), relativeWidth=0.8, levelColors = lc))
    return(list(shannon, chao1))
  }

  divwidget <- unlist(lapply(colnames(amp$metadata)[tg:desc], function(x) divplots(alphadiv, x, colors)), recursive = FALSE)
  tt <- tags$div(
    style = "display: grid; grid-template-columns: 1fr 1fr;",
    lapply(divwidget, function(x) { x$width = '90%'; x$height='100%'; tags$div(x) })
  )

  htmlGrid(tt, file=file.path(outdir, "alphadiv.html"),  data=alphadiv, title="species diversity", jquery = TRUE)

}

#' Pipeline function
#'
#' @description Make all 4 types of graphs
#'
#' @param mapfile  full path to map file
#' @param datafile full path to input OTU file
#' @param outdir  full path to output directory
#' @param sampdepth  sampling depth
#' @param ... other parameters to pass to \link{readindata}
#'
#' @return graphs are saved to outdir
#' @export
#'
allgraphs <- function(mapfile, datafile, outdir, sampdepth = NULL, ...) {
  amp <- readindata(mapfile=mapfile, datafile=datafile, ...)

  ## Choose colors
  numtg <- length(unique(amp$metadata$TreatmentGroup))
  if (numtg <= 18){
    allcols <- c(RColorBrewer::brewer.pal(7, "Set2"), RColorBrewer::brewer.pal(12, "Set3"))[c(1:8, 10:15, 9,17:19)]
    st <- round(runif(1, min=1, 18))
    st <- ((st:(st+(numtg - 1)) - 1) %% 18) + 1
    allcols <- allcols[st]
  } else {
    allcols <- NULL
  }

  ## Rarefaction curve
  logoutput('Rarefaction curve', 1)
  cmnd <- 'rarefactioncurve(outdir = outdir, amp = amp, colors = allcols)'
  logoutput(cmnd)
  try(eval(parse(text=cmnd)))

  ## Heatmap
  logoutput('Relative abundance Heatmap', 1)
  cmnd <- 'morphheatmap(outdir = outdir, amp = amp, taxlevel = c("Family", "seq"))'
  logoutput(cmnd)
  try(eval(parse(text=cmnd)))

  ## Filter out low count samples
  logoutput(paste0('Filter samples below ', sampdepth, ' reads'), 1)
  ampsub <- subsetamp(amp, sampdepth=sampdepth)

  if (nrow(ampsub$metadata) < 3) {
    stop("At least 3 samples are needed in order to produce the remaining plots.")
  }

 ## Alpha diversity
  logoutput('Alpha diversity boxplot', 1)
  cmnd <- 'adivboxplot(outdir = outdir, amp = ampsub, sampdepth = sampdepth,colors = allcols)'
  logoutput(cmnd)
  try(eval(parse(text=cmnd)))


  ## binomial PCoA
  logoutput('PCoA plots', 1)
  cmnd <- paste0('pcoaplot(outdir = outdir, amp = ampsub, distm = "binomial", colors = allcols)')
  logoutput(cmnd)
  try(eval(parse(text=cmnd)))

  if (!is.null(sampdepth)) {
    ## Rarefy table
    logoutput(paste('Rarefying OTU Table to', sampdepth, 'reads, and normalizing to 100.'))
    amp <- subsetamp(amp, sampdepth = sampdepth, rarefy = TRUE, normalise=TRUE)
  }

  ## bray-curtis PCoA
  cmnd <- 'pcoaplot(outdir = outdir, amp = amp, distm = "bray", colors = allcols)'
  logoutput(cmnd)
  try(eval(parse(text=cmnd)))

}

#' Wrapper for any graph function
#'
#' @description This is a wrapper for any of the graph functions meant to be called using rpy2 in python.
#'
#' @param mapfile full path to map file
#' @param datafile full path input OTU file
#' @param outdir  output directory for graphs
#' @param FUN function you would like to run
#' @param logfilename logfilename
#' @param info print sessionInfo to logfile
#' @param ...  parameters needed to pass to FUN
#'
#' @return Returns 0 if FUN succeeds and 1 if it returns an error.
#' @export
#'
#' @examples
#'
#' \dontrun{
#' trygraphwrapper("/path/to/inputs/mapfile.txt","/path/to/job_id/outputs/out.biom",
#' "/path/to/job_id/outputs/", allgraphs)
#' # example with no optional arguments for running allgraphs
#' }
#'
#' \dontrun{
#' # example with optional argument sampdepth
#' trygraphwrapper("/path/to/inputs/mapfile.txt","/path/to/outputs/out.biom",
#' "/path/to/job_id/outputs/", allgraphs, sampdepth = 30000)
#'
#' # example of making heatmap with optional arguments
#' trygraphwrapper("mapfile.txt", "taxa_species.biom", "outputs/graphs", morphheatmap, sampdepth = 30000,
#' filter_level=0.01, taxlevel=c("Family", "seq"))
#' }
#'
#'
trygraphwrapper <- function(mapfile, datafile, outdir, FUN, logfilename="logfile.txt", info = TRUE, ... ) {
  ## open log file
  logfile <- file(logfilename, open = "at")
  sink(file = logfile, type="output")
  sink(file = logfile, type= "message")

  ## create output directory
  outdir <- file.path(outdir, "graphs")
  dir.create(outdir, showWarnings = FALSE)


  ## print sessionInfo
  if (info) writeLines(capture.output(sessionInfo()))

  ## make function command
  cmnd <- paste0(deparse(substitute(FUN)), '(mapfile="', mapfile, '", datafile="', datafile, '", outdir="', outdir, '", ', ' ...)')
  logoutput(cmnd, 1)
  FUN <- match.fun(FUN)

  ## run command
  if (inherits(try(eval(parse(text=cmnd))), "try-error")) {
    retvalue <- as.integer(1)
  } else {
    retvalue <- as.integer(0)
  }

  ## close logfile
  sink(type="output")
  sink(type="message")
  return(retvalue)

}

