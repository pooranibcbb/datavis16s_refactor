#' @title Add Plotly data export to Plotly graph
#'
#' @description All functions create an output html plot  with link which sends the data to a grid in the plotly chart
#'  studio.
#'
#'  \code{plotlyGrid} takes in a ggplot or plotly object and creates an output html plotly plot.
#'
#' @param pplot plotly or ggplot object
#' @param filename output filename (fullpath)
#' @param data data frame to export to plotly grid (optional for plotlyGrid)
#' @param title title of html page
#' @param outlib (Optional) name of external lib directory for non-selfcontained html.
#' Useful for multiple graphs sharing the same lib.
#'
#' @importFrom htmlwidgets prependContent saveWidget
#' @importFrom plotly plotly_data plotly_build config ggplotly
#' @importFrom tools file_path_sans_ext
#'
#' @return html plot is saved to filename. external libraries are saved to outlib in same directory as filename.
#'
#' @rdname plotlyGrid
#' @name plotlyGrid
#'
plotlyGrid <- function(pplot, filename, data=NULL, title=NULL, outlib="lib") {

  if ("ggplot" %in% class(pplot)) pplot <- ggplotly(pplot)

  pp <- plotly_build(pplot)

  if (is.null(data)) {
    data <- plotly_data(pp)
  }

  list2env(gridCode(data), envir=environment())

  pp <- prependContent(pp, html)
  pp <- prependContent(pp,javascript)

  if (is.null(title)) {
    title <- tools::file_path_sans_ext(basename(filename))

  }

  outfile <- file.path(tools:::file_path_as_absolute(dirname(filename)), basename(filename))
  outlib <- file.path(dirname(outfile), basename(outlib))
  logoutput(paste("Saving plot to", outfile))
  saveWidget(config(pp, cloud = T, editable = T), file=outfile , selfcontained = FALSE, title=title, lib=outlib)
}

#' @title Add Plotly data export to generic htmlwidget
#'
#' @description \code{nonplotlyGrid} takes in an htmlwidget.
#'
#' @param hw htmlwidget
#' @param jquery should we load jquery
#'
#' @importFrom htmlwidgets prependContent saveWidget
#'
#' @rdname plotlyGrid
#'
nonplotlyGrid <- function(hw, filename, data, jquery = FALSE, title=NULL, outlib="lib") {

  list2env(gridCode(data), envir=environment())

  if (jquery){
    hw <- prependContent(hw, jq)
    selfcontained = FALSE
  } else {
    selfcontained = TRUE
  }
  hw <- prependContent(hw, html)
  hw <- prependContent(hw,javascript)

  if (is.null(title)) {
    title <- tools::file_path_sans_ext(basename(filename))
  }

  outfile <- file.path(tools:::file_path_as_absolute(dirname(filename)), basename(filename))
  outlib <- file.path(dirname(outfile), basename(outlib))


  logoutput(paste("Saving plot to", outfile))
  saveWidget(hw, file= outfile, selfcontained = selfcontained, title = title, lib=outlib)
}

#' @title Add Plotly data export to plain html
#'
#' @description \code{htmlGrid} takes in an html tag object.
#'
#' @param ht html tagList
#'
#' @importFrom htmltools tagList save_html tags
#'
#' @rdname plotlyGrid
#'
htmlGrid <- function(ht, filename, data, jquery = FALSE, title=NULL, outlib="lib") {

  list2env(gridCode(data), envir=environment())

  if (is.null(title)) {
    title <- tools::file_path_sans_ext(basename(filename))
  }
  title <- tags$h2(title, style = "font-family: sans-serif; text-align: center;")
  outfile <- file.path(tools:::file_path_as_absolute(dirname(filename)), basename(filename))

  outlib <- file.path(dirname(outfile), basename(outlib))

  logoutput(paste("Saving plot to", outfile))
  save_html(tagList(title,jq, html, javascript, ht), file= outfile, lib=outlib)
}


#' @title Format plotly grid code
#'
#' @param data data to populate plotly grid
#'
#' @return list of 3 values:
#' \describe{
#'   \item{jq}{optional jquery script}
#'   \item{html}{html for plotly export link}
#'   \item{javascript}{js function for exporting data}
#' }
#'
#' @importFrom jsonlite toJSON
#' @importFrom htmltools HTML
#'
#'
gridCode <- function(data) {

  ll <- as.list(data)

  nn <- names(ll)
  ll <- lapply(nn, function(x) { mm <- ll[[x]]; ll[[x]] <- NULL; return(list(data=mm));  } )
  names(ll) <- nn
  ll <- toJSON(ll)

  jq <- HTML('<script src=\"https://ajax.googleapis.com/ajax/libs/jquery/3.3.1/jquery.min.js\"></script>')
  html <- HTML(text = '<a href=\"#\" id=\"plotly-data-export\" target=\"_blank\" style=\"font-family:sans-serif;\">Export Data to Plotly</a>')

  javascript <- HTML(paste('<script>',
                           'function getPlotlyGridData(){',
                           '  return {',
                           paste0('cols: ', ll),
                           '  }',
                           '}',
                           "$(\'#plotly-data-export\').click(function(){",
                           "  var hiddenForm = $(\'<div id=\"hiddenform\" \'+",
                           "                       \'style=\"display:none;\">\'+",
                           "                       \'<form action=\"https://plot.ly/datagrid\" \'+",
                           "                       \'method=\"post\" target=\"_blank\">\'+",
                           "                       \'<input type=\"text\" \'+",
                           "                       \'name=\"data\" /></form></div>\')",
                           "  .appendTo(\'body\');",
                           "  var dataGrid = JSON.stringify(getPlotlyGridData())",
                           "  hiddenForm.find(\'input\').val(dataGrid);",
                           "  hiddenForm.find(\'form\').submit();",
                           "  hiddenForm.remove();",
                           "  return false;",
                           "});",
                           "</script>", sep = "\n"))
  return(list(jq=jq, html=html, javascript=javascript))
}
