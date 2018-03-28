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
#' @param taxtable taxonomy table object from ampvis2 object amp$tax
#'
#' @return data.frame taxonomy table object like ampvis2 amp$tax.  taxonomy names
#' are sanitized and formatted to be a bit nicer.
#'
#' @source [utilities.R](../R/utilities.R)
#'
shortnames <- function(taxtable) {
  ## greengenes
  taxtable <- apply(taxtable, 2, function(x) { v <- grep("_unclassified$|^Unassigned$", x); x[v] <- NA; x })
  taxtable <- apply(taxtable, 2, function(x) { gsub("^[kpcofgs]__", "", x) })

  ## SILVA97
  taxtable <- apply(taxtable, 2, function(x) { gsub("^D_\\d+__", "", x) })
  uncnames <-  c("Other", "uncultured", "uncultured bacterium", "Ambiguous_taxa", "uncultured organism", "uncultured rumen bacterium")

  taxtable[which(taxtable %in% c("", "none"), arr.ind = TRUE)] <- NA


  ## Unclassified
  vd <- which(is.na(taxtable[,"Kingdom"]))
  taxtable[vd,"Kingdom"] <- paste(row.names(taxtable)[vd], "unclassified")


  ## Output Genus species instead of just species
  vn <- which(apply(taxtable,1, function(x) !(is.na(x["Species"]) | x["Species"] %in% uncnames | grepl(paste0("^",x['Genus']), x["Species"]))))
  if (length(vn) > 0) {
    taxtable[vn,"Species"] <- paste(taxtable[vn,"Genus"],taxtable[vn,"Species"] )
  }


  ## Generate newnames
  snamecol <- function(taxa) {
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


      return(paste(x[y-1], colnames(shorttable)[y-1]))

    }

    tt <- which(colnames(taxtable) == taxa)
    shorttable <- taxtable[,1:tt]
    sn <- apply(shorttable, 1, sname )
    return(sn)
  }


  taxalist <- intersect(c("Phylum", "Class", "Order", "Family", "Genus", "Species"), colnames(taxtable))
  tlist <- lapply(taxalist, snamecol)
  newname_taxtable <- do.call(cbind.data.frame, tlist)
  newname_taxtable <- cbind.data.frame(taxtable[,"Kingdom"], newname_taxtable, taxtable[,"OTU"])
  colnames(  newname_taxtable ) <- colnames(taxtable)
  return(newname_taxtable)

}

#' return tables at higher tax level
#'
#' @param amp  ampvis2 object
#' @param taxlevel  taxonomic level at which to sum up the counts
#'
#' @return  ampvis2 object with otu table and taxa summed up to the taxlevel
#'
#' @importFrom data.table data.table .SD
#'
#' @source [utilities.R](../R/utilities.R)
#'
highertax <- function(amp, taxlevel) {

  otu <- as.matrix(amp$abund)
  tax <- amp$tax

  tc <- which(colnames(tax) == taxlevel)
  sn <- shortnames(tax)
  tax <- tax[,1:tc]
  tax <- tax[,c(tc+1,1:tc)]
  taxcols <- colnames(tax)
  otucols <- colnames(otu)
  totu <- cbind.data.frame(otu, tax)
  dt <- data.table(totu)
  dt <- dt[, lapply(.SD, sum) , by = c(taxcols)]
  otu <- data.frame(dt[,otucols, with=FALSE], check.names = FALSE)
  tax <- data.frame(dt[,taxcols, with=FALSE])
  row.names(otu) <- tax[,ncol(tax)]
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


#' Print ampvis2 object summary
#'
#' @param data ampvis2 object
#'
#' @return Prints summary stats about ampvis2 object
#'
#' @source [utilities.R](../R/utilities.R)
#'
#' @description  This is a copy of the internal ampvis2 function print.ampvis2.  CRAN does not allow
#' ':::' internal calling of function in package.
#'
#' @importFrom stats median
#'
print_ampvis2 <- function(data) {

  cat(class(data), "object with", length(data), "elements.\nSummary of OTU table:\n")
  print.table(c(
    Samples = as.character(ncol(data$abund)), OTUs = as.character(nrow(data$abund)),
    `Total#Reads` = as.character(sum(data$abund)), `Min#Reads` = as.character(min(colSums(data$abund))),
    `Max#Reads` = as.character(max(colSums(data$abund))),
    `Median#Reads` = as.character(median(colSums(data$abund))),
    `Avg#Reads` = as.character(round(mean(colSums(data$abund)),
      digits = 2
    ))
  ), justify = "right")
  cat("\nAssigned taxonomy:\n")
  print.table(c(Kingdom = paste(sum(nchar(data$tax$Kingdom) >
    3), "(", round(sum(nchar(data$tax$Kingdom) > 3) / nrow(data$abund),
    digits = 2
  ) * 100, "%)", sep = ""), Phylum = paste(sum(nchar(data$tax$Phylum) >
    3), "(", round(sum(nchar(data$tax$Phylum) > 3) / nrow(data$abund) *
    100, digits = 2), "%)", sep = ""), Class = paste(sum(nchar(data$tax$Class) >
    3), "(", round(sum(nchar(data$tax$Class) > 3) / nrow(data$abund) *
    100, digits = 2), "%)", sep = ""), Order = paste(sum(nchar(data$tax$Order) >
    3), "(", round(sum(nchar(data$tax$Order) > 3) / nrow(data$abund) *
    100, digits = 2), "%)", sep = ""), Family = paste(sum(nchar(data$tax$Family) >
    3), "(", round(sum(nchar(data$tax$Family) > 3) / nrow(data$abund) *
    100, digits = 2), "%)", sep = ""), Genus = paste(sum(nchar(data$tax$Genus) >
    3), "(", round(sum(nchar(data$tax$Genus) > 3) / nrow(data$abund) *
    100, digits = 2), "%)", sep = ""), Species = paste(sum(nchar(data$tax$Species) >
    3), "(", round(sum(nchar(data$tax$Species) > 3) / nrow(data$abund) *
    100, digits = 2), "%)", sep = "")), justify = "right")
  cat(
    "\nMetadata variables:", as.character(ncol(data$metadata)),
    "\n", paste(as.character(colnames(data$metadata)), collapse = ", ")
  )
}

#' #' Cleanup taxonomy names
#' #'
#' #' @param taxtable taxonomy table attribute of ampvis2 object
#' #'
#' #' @return data frame of taxonomy table with sanitized taxonomy
#' #'
#' #'
#' #'
#' taxonomycleanup <- function(taxtable) {
#'
#'   ## greengenes
#'   taxtable <- apply(taxtable, 2, function(x) { v <- grep("_unclassified$|^Unassigned$", x); x[v] <- NA; x })
#'   taxtable <- apply(taxtable, 2, function(x) { gsub("^[kpcofgs]__", "", x) })
#'
#'   ## SILVA97
#'   taxtable <- apply(taxtable, 2, function(x) { gsub("^D_\\d+__", "", x) })
#'   taxtable[which(taxtable %in% c("", "none"), arr.ind = TRUE)] <- NA
#'
#'   vd <- which(is.na(taxtable[,"Kingdom"]))
#'   taxtable[vd,"Kingdom"] <- paste(row.names(taxtable)[vd], "unclassified")
#'
#'   return(as.data.frame(taxtable))
#'
#'
#' }
