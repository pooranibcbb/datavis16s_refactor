#' write log output
#'
#' @description Prints time along with log message.
#'
#' @param c String. Log message/command to print.
#' @param bline Number of blank lines to precede output.
#' @param aline Number of blank lines to follow output.
#'
#' @source [utilities.R](../R/utilities.R)
#'
logoutput <- function(c, bline = 0, aline = 0) {

  lo <- paste0("[", date(), "] ", c)
  writeLines(c(rep("", bline), lo, rep("", aline)))

}

#' shortnames for taxonomy
#'
#' @param taxtable taxonomy table object from amp$tax
#' @param taxa  taxonomic level at which to retrieve the names
#'
#' @return Vector of shortened names for each seqvar/otu.
#'
#' @source [utilities.R](../R/utilities.R)
#'
shortnames <- function(taxtable, taxa="Species") {
  ## greengenes
  taxtable <- apply(taxtable, 2, function(x) { v <- grep("_unclassified$|^Unassigned$", x); x[v] <- NA; x })
  taxtable <- apply(taxtable, 2, function(x) { gsub("^[kpcofgs]__", "", x) })

  ## SILVA97
  taxtable <- apply(taxtable, 2, function(x) { gsub("^D_\\d+__", "", x) })
  uncnames <-  c("Other", "uncultured", "uncultured bacterium", "Ambiguous_taxa", "uncultured organism", "uncultured rumen bacterium")

  taxtable[which(taxtable %in% c("", "none"), arr.ind = TRUE)] <- NA

  vd <- which(is.na(taxtable[,"Kingdom"]))
  taxtable[vd,"Kingdom"] <- paste(row.names(taxtable)[vd], "unclassified")

  if (taxa == "Species") {
    vn <- which(apply(taxtable,1, function(x) !(is.na(x["Species"]) | x["Species"] %in% uncnames | grepl(paste0("^",x['Genus']), x["Species"]))))
    if (length(vn) > 0) {
      taxtable[vn,"Species"] <- paste(taxtable[vn,"Genus"],taxtable[vn,"Species"] )
    }
  }

  tt <- which(colnames(taxtable) == taxa)
  taxtable <- taxtable[,1:tt]

  sname <- function(x) {
    ## SILVA
    y <- suppressWarnings(min(which(x %in% uncnames)))
    if (y != "Inf"){
      return(paste(x[y-1], colnames(taxtable)[y-1], x[y]))
    }

    y <- suppressWarnings(min(which(is.na(x))))
    if (y == "Inf") {
      return(paste(x[length(x)]))
    }

    if ( y == 2 ) {
      return(paste(x[1]))
    }

    return(paste(x[y-1], colnames(taxtable)[y-1]))

  }

  sn <- apply(taxtable, 1, sname )
  return(sn)
}

#' return tables at higher tax level
#'
#' @param amp  ampvis2 object
#' @param taxlevel  taxonomic level at which to sum up the counts
#'
#' @return  ampvis2 object with otu table and taxa summed up to the taxlevel
#'
#' @importFrom data.table data.table
#'
#' @source [utilities.R](../R/utilities.R)
#'
highertax <- function(amp, taxlevel=NULL) {

  otu <- as.matrix(amp$abund)
  tax <- amp$tax
  if (is.null(taxlevel)) {
    n <- ncol(tax)
    tax$sn <- shortnames(tax)
    tax <- tax[,c(n+1,1:n)]
    amp$abund <- as.data.frame(otu)
    amp$tax <- tax
    return(amp)
  }
  tc <- which(colnames(tax) == taxlevel)
  sn <- shortnames(tax, taxa=taxlevel)
  tax <- tax[,1:tc]
  tax$sn <- sn
  tax <- tax[,c(tc+1,1:tc)]
  taxcols <- colnames(tax)
  otucols <- colnames(otu)
  totu <- cbind.data.frame(otu, tax)
  dt <- data.table(totu)
  dt <- dt[, lapply(.SD, sum) , by = c(taxcols)]
  otu <- data.frame(dt[,otucols, with=FALSE], check.names = FALSE)
  tax <- data.frame(dt[,taxcols, with=FALSE])
  row.names(otu) <- tax$sn
  amp$abund <- as.data.frame(otu)
  amp$tax <- tax
  return(amp)
}

#' Filter low abundant taxa
#'
#' @param amp  ampvis2 object
#' @param level  level at which to filter
#' @param persamp  percent of samples which must have taxa in common
#' @param abs  is level an absolute count? if false, will use level as relative percent.
#'
#' @return filtered ampvis2 object
#'
#' @source [utilities.R](../R/utilities.R)
#'
filterlowabund <- function(amp, level=0.01, persamp=0, abs=FALSE) {

  otu <- as.matrix(amp$abund)
  tax <- amp$tax
  if (abs) {
    mat <- otu
  } else {
    mat <- apply(otu, 2, function(x) { y <- sum(x); 100*x/y  } )
  }
  v <- which(mat < level & mat > 0)
  otu[v] <- 0
  w <- which(rowSums(otu) == 0)
  ps <- which(apply(otu, 1, function(x) length(which(x > 0))/ncol(otu)) < persamp/100)
  w <- unique(c(w, ps))
  if (length(w) > 0) {
    otu <- otu[-w,]
    tax <- tax[-w,]
  }
  amp$abund <- as.data.frame(otu)
  amp$tax <- tax
  return(amp)
}



