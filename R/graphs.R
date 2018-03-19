#' Subset and rarefy OTU table.
#'
#' @description Subset and/or rarefy OTU table.
#' @source [graphs.R](../R/graphs.R)
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
subsetamp <- function(amp, sampdepth = NULL, rarefy=FALSE, ...) {
  if (rarefy & !is.null(sampdepth)) {
    cmnd <- 'otu <- rrarefy(t(amp$abund), sampdepth)'
    logoutput(cmnd)
    eval(parse(text=cmnd))
    amp$abund <- as.data.frame(t(otu))
  }

  if(is.null(sampdepth)) sampdepth <- 0
  cmnd <- 'amp <- amp_subset_samples(amp, minreads = sampdepth, ...)'
  logoutput(cmnd)
  eval(parse(text=cmnd))

  print_ampvis2(amp)
  writeLines('')
  return(amp)
}

#' Read in data
#'
#' @param mapfile  full path to mapfile.  must contain SampleID, TreatmentGroup, and Description columns
#' @param datafile  full path to input data file.  must be either biom file or tab delimited text file.
#' See details.
#' @param tsvfile  Logical.  Is datafile a tab-delimited text file? See details.
#' @param mincount  minimum number of reads
#' @return ampvis2 object
#'
#' @details datafile may be either biom file or text file.  If text file, it should have ampvis2 OTU table
#' format \url{https://madsalbertsen.github.io/ampvis2/reference/amp_load.html#the-otu-table}. If the
#' number of reads is less than mincount, the function will give an error, as we cannot make graphs
#' with so few counts.
#'
#' @source [graphs.R](../R/graphs.R)
#'
#' @export
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

  logoutput(paste("Reading in OTU file", datafile))
  if ((tsvfile)) {
    cmnd <- "otu <- read.delim(datafile, check.names = FALSE, na.strings = '', row.names = 1)"
    logoutput(cmnd)
    eval(parse(text = cmnd))
  } else {

    cmnd <- 'biom <- biomformat::read_biom(datafile)'
    logoutput(cmnd)
    eval(parse(text = cmnd))

    cmnd <- 'otu <- as.data.frame(as.matrix(biomformat::biom_data(biom)))'
    logoutput(cmnd)
    eval(parse(text = cmnd))

    cmnd <- 'tax <- biomformat::observation_metadata(biom)'
    logoutput(cmnd)
    eval(parse(text = cmnd))

    ## qiime biom file
    if (class(tax) == "list") {
      cmnd <- 'tax <- t(sapply(tax, "[", i=1:7))'
      logoutput(cmnd)
      eval(parse(text = cmnd))
    }

    ## Check if tax has 7 columns
    if (ncol(tax) != 7) {
      stop("taxonomy does not have 7 levels.")
    }

    colnames(tax) <- c("Kingdom", "Phylum", "Class", "Order", "Family", "Genus", "Species")


    cmnd <- 'otu <- cbind(otu, tax)'
    logoutput(cmnd)
    eval(parse(text = cmnd))
  }

  cmnd <- 'amp <- amp_load(otu, map)'
  logoutput(cmnd)
  eval(parse(text = cmnd))
  print_ampvis2(amp)
  writeLines('')

  if (sum(amp$abund) < mincount) {
    stop(paste0("Not enough counts in OTU table to make any graphs. At least ", mincount, " are needed."))
  }

  return(amp)

}


#' Make rarefaction curve graph
#'
#' @param mapfile  full path mapping file
#' @param datafile full path to input OTU file (biom or see \link{readindata})
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
#' @source [graphs.R](../R/graphs.R)
#'
rarefactioncurve <- function(mapfile, datafile, outdir, amp = NULL, colors=NULL, ...) {
  if (is.null(amp)) {
    cmnd <- 'amp <- readindata(mapfile=mapfile, datafile=datafile, ...)'
    logoutput(cmnd)
    eval(parse(text = cmnd))
  }
  rarecurve <- amp_rarecurve(amp, color_by = "TreatmentGroup")

  on.exit(graphics.off())

  if (!is.null(colors)) rarecurve <- rarecurve + scale_color_manual(values = colors)

  ## suppress ggplotly warning to install dev version of ggplot2, as it is out of date
  withCallingHandlers({
    rarecurve <- ggplotly(rarecurve, tooltip = c("SampleID"))
  }, message = function(c) {
    if (startsWith(conditionMessage(c), "We recommend that you use the dev version of ggplot2"))
      invokeRestart("muffleMessage")
  })

  df <- plotly_data(rarecurve)
  df_new <- split(df, df$SampleID)
  tg <- which(colnames(df) == "TreatmentGroup")
  desc <-  which(colnames(df) == "Description")
  n <- ncol(df)

  df_new <- lapply(df_new, function(x) {x <- data.frame(x); y <- unlist(c(rep(NA, tg - 1), x[1,tg:desc], rep(NA,(n - desc)))); names(y) <- colnames(x); rbind(x,y)   })
  df_new <- do.call(rbind.data.frame, df_new)
  plotlyGrid(rarecurve, file.path(outdir, "rarecurve.html"), data = df_new)
  logoutput(paste0('Saving rarefaction curve table to ', file.path(outdir, 'rarecurve.txt') ))
  write.table(df_new, file.path(outdir, 'rarecurve.txt'), quote = FALSE, sep = '\t', row.names = FALSE, na = "")
}


#' PCoA plots
#'
#' @param mapfile  full path to map file
#' @param datafile full path to input OTU file (biom or see \link{readindata})
#' @param outdir  full path to output directory
#' @param amp  ampvis2 object. may be specified instead of mapfile and datafile
#' @param sampdepth  sampling depth
#' @param distm  distance measure for PCoA.  any that are supported by
#' \href{https://madsalbertsen.github.io/ampvis2/reference/amp_ordinate.html}{amp_ordinate} except for unifrac, wunifrac, and none.
#' @param filter_species Remove low abundant OTU's across all samples below this threshold in percent.
#' Setting this to 0 may drastically increase computation time.
#' @param rarefy Logical. Rarefy the OTU table if sampdepth is specified.
#' @param colors (Optional) color vector - length equal to number of TreatmentGroups in mapfile
#' @param ... parameters to pass to  \code{\link{readindata}}
#'
#' @return Saves pcoa plots to outdir.
#'
#' @importFrom ggplot2 scale_color_manual ggtitle
#'
#' @source [graphs.R](../R/graphs.R)
#'
#' @export
#'
pcoaplot <- function(mapfile, datafile, outdir, amp=NULL, sampdepth = NULL, distm="binomial", filter_species=0.1, rarefy=FALSE, colors=NULL, ...) {
  if (is.null(amp)) {
    amp <- readindata(mapfile=mapfile, datafile=datafile, ...)
  }
  if (!is.null(sampdepth)) {
    cmnd <- paste0('amp <- subsetamp(amp, sampdepth = ', sampdepth,', rarefy=',rarefy, ')')
    logoutput(cmnd)
    eval(parse(text=cmnd))
  }

    on.exit(graphics.off())

    cmnd <- paste0('pcoa <- amp_ordinate(amp, filter_species =', filter_species, ',type="PCOA", distmeasure ="', distm, '",sample_color_by = "TreatmentGroup", sample_colorframe = TRUE, detailed_output = TRUE, transform="none")')

    logoutput(cmnd)
    eval(parse(text = cmnd))
    if (!is.null(colors)) pcoa$plot <- pcoa$plot + scale_color_manual(values = colors) + ggtitle(paste("PCoA with", distm, "distance"))

    outfile <- file.path(outdir, paste0("pcoa_", distm, ".html"))
    plotlyGrid(pcoa$plot, outfile, data = pcoa$dsites)
    tabletsv <- gsub('.html$', '.txt', outfile)
    logoutput(paste0('Saving ', distm, ' PCoA table to ', tabletsv))
    write.table(pcoa$dsites, tabletsv, quote=FALSE, sep='\t', row.names=FALSE, na="")

  }


#' Morpheus heatmap
#'
#' @description Creates heatmaps using Morpheus R API \url{https://software.broadinstitute.org/morpheus/}.  The heatmaps are made
#' using relative abundances.
#'
#' @param mapfile full path to mapping file
#' @param datafile  full path to input OTU file (biom or see \link{readindata})
#' @param outdir  full path to output directory
#' @param amp  (Optional) ampvis2 object. may be specified instead of mapfile and datafile
#' @param sampdepth sampling depth
#' @param rarefy Logical. Rarefy the OTU table if sampdepth is specified.
#' @param filter_level minimum abundance to show in the heatmap
#' @param taxlevel vector of taxonomic levels to graph.  must be subset of
#' c("Kingdom", "Phylum", "Class", "Order", "Family", "Genus", "Species", "seq").  See Details.
#' @param colors  (Optional) color vector - length equal to number of TreatmentGroups in mapfile
#' @param ...  parameters to pass to  \code{\link{readindata}}
#'
#' @return  Saves heatmaps to outdir.
#' @export
#'
#' @details For the \code{taxlevel} parameter, each level is made into a separate heatmap.  "seq" makes
#'  the heatmap with no collapsing of taxonomic levels.
#'
#' @importFrom morpheus morpheus
#'
#' @source [graphs.R](../R/graphs.R)
#'
#' @examples
#' \dontrun{
#'  morphheatmap(mapfile="mapfile.txt", datafile="OTU_table.txt", outdir="outputs/graphs",
#'  sampdepth = 25000, taxlevel = c("Family", "seq"), tsvfile=TRUE)
#' }
#'
#'
morphheatmap <- function(mapfile, datafile, outdir, amp = NULL, sampdepth = NULL, rarefy=FALSE, filter_level = 0.1, taxlevel=c("seq"), colors = NULL, ...) {

  ## read in data
  if (is.null(amp)) {
    amp <- readindata(mapfile=mapfile, datafile=datafile, ...)
  }

  ## normalize data
  logoutput("Calculate relative abundance.")
  cmnd <- 'amp <- subsetamp(amp, sampdepth = sampdepth, rarefy=rarefy, normalise = TRUE)'
  logoutput(cmnd)
  eval(parse(text=cmnd))


  if (!all(nrow(amp$abund) > 1, ncol(amp$abund) > 1)) {
    stop("OTU table must be at least 2x2 for heatmap.")
  }

  ## Annotations
  tg <- which(colnames(amp$metadata) == "TreatmentGroup")
  desc <-  which(colnames(amp$metadata) == "Description") - 1
  columns <- lapply(tg:desc, function(x) { list(field=colnames(amp$metadata)[x], highlightMatchingValues=TRUE, display=list('color'))  } )
  columns <- append(list(list(field='id', display=list('text'))), columns)
  try(names(colors) <- unique(amp$metadata$TreatmentGroup), silent = TRUE)
  rows <- list(list(field='id', display=list('text')))

  ## Heatmap colors
  hmapcolors <- rev(colorRampPalette( RColorBrewer::brewer.pal(11, "RdYlBu"), bias=0.5)(100))

  ## heatmap function
  makeheatmap <- function(tl, amp) {

    ## create matrix at higher taxonomic level
    if (tl != "seq") {
      amptax <- highertax(amp, taxlevel=tl)
    } else {
      amptax <- amp
    }

    if (filter_level > 0) {
      logoutput(paste('Filter taxa below', filter_level, 'abundance.'))
      cmnd <- paste0('amptax <- filterlowabund(amptax, level = ', filter_level,')')
      logoutput(cmnd)
      eval(parse(text = cmnd))
    }

    ## row and column names for matrix
    if (tl == "seq") {
      sn <- shortnames(amptax$tax, taxa = "Species")
      sn <- paste(amptax$tax$OTU, sn)
    } else {
      sn <- amptax$tax$sn
    }
    mat <- amptax$abund
    row.names(mat) <- sn
    mat <- mat[,amptax$metadata$SampleID]

    ## log scale for colors
    mm <- max(amptax$abund)
    values <-  c(0,expm1(seq(log1p(filter_level), log1p(100), length.out = 99)))
    w <- which(values > 10)
    values[w] <- round(values[w])

    cmnd <- 'heatmap <- morpheus(mat, columns=columns, columnAnnotations = amptax$metadata, columnColorModel = list(type=as.list(colors)), colorScheme = list(scalingMode="fixed", values=values, colors=hmapcolors, stepped=FALSE), rowAnnotations = amptax$tax, rows = rows)'
    logoutput(cmnd)
    eval(parse(text = cmnd))

    outdir <- tools::file_path_as_absolute(outdir)
    outfile <- file.path(outdir, paste0(tl, "_heatmap.html"))
    logoutput(paste("Saving plot to", outfile))
    heatmap$width = '100%'
    heatmap$height = '90%'
    tt <- tags$div(heatmap, style = "position: absolute; top: 10px; right: 40px; bottom: 40px; left: 40px;")
    save_fillhtml(tt, file = outfile, bodystyle = 'height:100%; width:100%;overflow:hidden;')

    write.tab.table(amptax$abund, file.path(outdir, "heatmap.txt"))
  }

  for (t in taxlevel) {
    cmnd <- paste0('makeheatmap("', t, '", amp)')
    logoutput(cmnd)
    if (inherits(try(eval(parse(text = cmnd))), "try-error")) {
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
#' @source [graphs.R](../R/graphs.R)
#'
#' @importFrom bpexploder bpexploder
#'
adivboxplot <- function(mapfile, datafile, outdir, amp=NULL, sampdepth = NULL, colors = NULL, ...) {
  if (is.null(amp)) {
    amp <- readindata(mapfile = mapfile, datafile = datafile, ...)
  }

  if (is.null(sampdepth)) {
    logoutput('Calculate number of counts to rarefy table.')
    cmnd <- 'sampdepth <-  min(colSums(amp$abund))'
    logoutput(cmnd)
    eval(parse(text=cmnd))
  }

  cmnd <- paste0('alphadiv <- amp_alphadiv(amp, measure="shannon", richness = TRUE, rarefy = ', sampdepth, ')')
  logoutput(cmnd)
  eval(parse(text = cmnd))

  logoutput(paste0('Saving alpha diversity table to ', file.path(outdir, 'alphadiv.txt') ))
  write.table(alphadiv, file.path(outdir, 'alphadiv.txt'), quote = FALSE, sep = '\t', row.names = FALSE, na = "")

  tg <- which(colnames(amp$metadata) == "TreatmentGroup")
  desc <- which(colnames(amp$metadata) == "Description") - 1

  divplots <- function(adiv, col, colors) {
    if (col == "TreatmentGroup") {
      lc <- colors
    } else {
      lc <- NULL
    }

    shannon <-  bpexploder(alphadiv, settings = list(groupVar = col, yVar = "Shannon", tipText = list(SampleID = "SampleID", Shannon = "Shannon Index", Description = "Desc"), relativeWidth = 0.8, levelColors = lc))

    chao1 <- bpexploder(alphadiv, settings = list(groupVar = col, yVar = "Chao1", tipText = list(SampleID = "SampleID", Chao1 = "Species Richness", Description = "Desc"), relativeWidth = 0.8, levelColors = lc))
    return(list(shannon, chao1))
  }

  divwidget <- unlist(lapply(colnames(amp$metadata)[tg:desc], function(x) divplots(alphadiv, x, colors)), recursive = FALSE)
  tt <- tags$div(
    style = "display: grid; grid-template-columns: 1fr 1fr; grid-row-gap: 5em;",
    lapply(divwidget, function(x) { x$width = '90%'; x$height = '100%'; tags$div(x) })
  )

  htmlGrid(tt, file = file.path(outdir, "alphadiv.html"),  data = alphadiv, title = "species diversity", jquery = TRUE)

}

#' Pipeline function
#'
#' @description Make all 4 types of graphs
#'
#' @param mapfile  full path to map file
#' @param datafile full path to input OTU file (biom or see \link{readindata})
#' @param outdir  full path to output directory
#' @param sampdepth  sampling depth
#' @param ... other parameters to pass to \link{readindata}
#'
#' @return graphs are saved to outdir.  See [user doc](../doc/user_doc.md).
#'
#' @source [graphs.R](../R/graphs.R)
#'
#' @export
#'
allgraphs <- function(mapfile, datafile, outdir, sampdepth = NULL, ...) {
  amp <- readindata(mapfile=mapfile, datafile=datafile, ...)

  ## Choose colors
  amp$metadata <-  amp$metadata[order(amp$metadata$TreatmentGroup),]
  numtg <- length(unique(amp$metadata$TreatmentGroup))
  allcols <- c(RColorBrewer::brewer.pal(8, "Set2"), RColorBrewer::brewer.pal(12, "Set3"))[c(1:7,9,11:14, 10, 15:16,18:20)]
  coln <- length(allcols)
  if (numtg <= coln){
    st <- sample.int(coln, size=1)
    st <- ((st:(st+(numtg - 1)) - 1) %% coln) + 1
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
  logoutput('Relative abundance heatmaps', 1)
  cmnd <- 'morphheatmap(outdir = outdir, amp = amp, taxlevel = c("Family", "seq"), colors=allcols, filter_level=0)'
  logoutput(cmnd)
  try(eval(parse(text=cmnd)))

  ## Filter out low count samples
  cs <- colSums(amp$abund)
  sampdepth <- min(cs[cs >= sampdepth])
  logoutput(paste0('Filter samples below ', sampdepth, ' counts.'), 1)
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
#' @param datafile full path to input OTU file (biom or see \link{readindata})
#' @param outdir  output directory for graphs
#' @param FUN function you would like to run
#' @param logfilename logfilename
#' @param info print sessionInfo to logfile
#' @param ...  parameters needed to pass to FUN
#'
#' @return Returns 0 if FUN succeeds and 1 if it returns an error.
#' @export
#'
#' @source [graphs.R](../R/graphs.R)
#'
#' @examples
#'
#' \dontrun{
#'
#' # example with no optional arguments for running allgraphs
#' trygraphwrapper("/path/to/inputs/mapfile.txt","/path/to/outputs/out.biom",
#'  "/path/to/outputs/", allgraphs)
#'
#' # example with optional argument sampdepth
#' trygraphwrapper("/path/to/inputs/mapfile.txt","/path/to/outputs/out.biom",
#' "/path/to/outputs/", allgraphs, sampdepth = 30000)
#'
#' # example of making heatmap with optional arguments
#' trygraphwrapper("/path/to/inputs/mapfile.txt", "/path/to/outputs/taxa_species.biom", "/path/to/outputs", morphheatmap, sampdepth = 30000, filter_level=0.01, taxlevel=c("Family", "seq"))
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
  dir.create(outdir, showWarnings = FALSE, recursive = TRUE)


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

