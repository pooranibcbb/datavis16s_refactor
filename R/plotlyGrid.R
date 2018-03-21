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
#' @importFrom plotly plotly_data plotly_build ggplotly
#'
#' @return html plot is saved to filename. external libraries are saved to outlib in same directory as filename.
#'
#' @source [plotlyGrid.R](../R/plotlyGrid.R)
#' @rdname plotlyGrid
#' @name plotlyGrid
#'
plotlyGrid <- function(pplot, filename, data=NULL, title=NULL, outlib="lib") {

  if ("ggplot" %in% class(pplot)) {

    withCallingHandlers({
      pplot <- ggplotly(pplot)
    }, message=function(c) {
      if (startsWith(conditionMessage(c), "We recommend that you use the dev version of ggplot2"))
        invokeRestart("muffleMessage")
    })
  }
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

  outfile <- file.path(tools::file_path_as_absolute(dirname(filename)), basename(filename))
  outlib <- file.path(dirname(outfile), basename(outlib))
  logoutput(paste("Saving plot to", outfile))
  saveWidget(plotly::config(pp, cloud = T, editable = T), file=outfile , selfcontained = FALSE, title=title, libdir=outlib)
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

  outfile <- file.path(tools::file_path_as_absolute(dirname(filename)), basename(filename))
  outlib <- file.path(dirname(outfile), basename(outlib))


  logoutput(paste("Saving plot to", outfile))
  saveWidget(hw, file= outfile, selfcontained = selfcontained, title = title, libdir=outlib)
}

#' @title Add Plotly data export to plain html
#'
#' @description \code{htmlGrid} takes in an html tag object.
#'
#' @param ht html tagList
#'
#' @importFrom htmltools tagList tags
#'
#' @rdname plotlyGrid
#'
htmlGrid <- function(ht, filename, data, jquery = FALSE, title=NULL, outlib="lib") {

  list2env(gridCode(data), envir=environment())

  if (is.null(title)) {
    title <- tools::file_path_sans_ext(basename(filename))
    tl <- tagList(jq, html, javascript, ht)
  } else {
    title <- tags$h2(title, style = "font-family: sans-serif; text-align: center;")
    tl <- tagList(title,jq, html, javascript, ht)
  }
  outfile <- file.path(tools::file_path_as_absolute(dirname(filename)), basename(filename))

  outlib <- file.path(dirname(outfile), basename(outlib))

  logoutput(paste("Saving plot to", outfile))
  htmltools::save_html(tl, file= outfile, lib=outlib)
}


#' @title Format plotly grid code
#'
#' @description Format data according to here: \url{https://plot.ly/export/}
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
#' @importFrom htmltools HTML
#'
#' @source [plotlyGrid.R](../R/plotlyGrid.R)
#'
gridCode <- function(data) {

  ll <- as.list(data)

  nn <- names(ll)
  ll <- lapply(nn, function(x) { mm <- ll[[x]]; ll[[x]] <- NULL; return(list(data=mm));  } )
  names(ll) <- nn
  ll <- jsonlite::toJSON(ll)

  jq <- HTML('<script src=\"https://ajax.googleapis.com/ajax/libs/jquery/3.3.1/jquery.min.js\"></script>')
  html <- HTML(text = '<a href=\"#\" id=\"plotly-data-export\" target=\"_blank\" style=\"font-family:\'Open Sans\',sans-serif;\">Export Data to Plotly</a>')

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


#' Save an HTML object to a file
#'
#' @param html HTML content to print
#' @param file File to write content to
#' @param background Background color for web page
#' @param libdir Directory to copy dependenies to
#' @param bodystyle html style string
#'
#' @return save html to file
#'
#' @source [plotlyGrid.R](../R/plotlyGrid.R)
#'
save_fillhtml <- function (html, file, background = "white", libdir = "lib", bodystyle="")
{
  dir <- dirname(file)
  oldwd <- setwd(dir)
  on.exit(setwd(oldwd), add = TRUE)
  rendered <- htmltools::renderTags(html)
  deps <- lapply(rendered$dependencies, function(dep) {
    dep <- htmltools::copyDependencyToDir(dep, libdir, FALSE)
    dep <- htmltools::makeDependencyRelative(dep, dir, FALSE)
    dep
  })
  html <- c("<!DOCTYPE html>", "<html>", "<head>", "<meta charset=\"utf-8\"/>",
            htmltools::renderDependencies(deps, c("href", "file")), rendered$head,
            "</head>", sprintf("<body style=\"background-color:%s;%s\">",
                               htmltools::htmlEscape(background), bodystyle), rendered$html, "</body>",
            "</html>")
  writeLines(html, file, useBytes = TRUE)
}
