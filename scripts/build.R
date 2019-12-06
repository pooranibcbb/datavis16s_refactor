library(devtools)
library(rmarkdown)
library(Rd2md)

Sys.setenv(PATH=paste(Sys.getenv("PATH"), "/Users/subramanianp4/Library/Python/3.7/bin", sep=":"))

# Build package ----------------------------------------------------------------------------------
document(roclets=c('rd', 'collate', 'namespace'))
devtools::install(args = c("--preclean", "--no-multiarch", "--with-keep.source"), dependencies = F, upgrade=F)

## Imported packages - can check DESCRIPTION
ns <- scan("NAMESPACE", sep="\n", what = character())
importedpackages <- unique(stringr::str_match(ns, "import.*\\((.*?)[\\,\\)]")[,2])


## update description
desc::desc_set(Date=format(Sys.time(), format="%F"), normalize=TRUE)
deptable <- desc::desc_get_deps()
# deptable$version <- apply(deptable, 1, function(x) { if (x[2] == "R") return(x[3]); paste("==", packageVersion(x[2])) })
desc::desc_set_deps(deptable, normalize = TRUE)


# Documentation --------------------------------

myoutputoptions <- list(pandoc_args=c("--template", file.path(find.package("rmarkdown"), "rmarkdown/templates/github_document/resources/default.md"), "--atx-headers", "--columns=10000"))


remove.file <- function(x) {
  suppressWarnings(file.remove(x))
}

clean_pandoc2_highlight_tags = function(x) {
  x = gsub('(</a></code></pre>)</div>', '\\1', x)
  x = gsub('<div class="sourceCode"[^>]+>(<pre)', '\\1', x)
  x = gsub('<a class="sourceLine"[^>]+>(.*)</a>', '\\1', x)
  x
}

## library function specification ============

yaml <- "---
title: 'R Package datavis16s'
author: 'Poorani Subramanian'
output:
  md_document:
    variant: markdown_github+link_attributes+pipe_tables
    toc_depth: 3
    toc: true
---

```{r setup, include=FALSE}
knitr::opts_chunk$set(echo = TRUE, eval = FALSE, tidy=TRUE, tidy.opts = list(width.cutoff=80))
```

"

mdfile <- "doc/Reference_Manual_datavis16s.md"
Rmdfile <- gsub(".md", ".Rmd", mdfile)
## CRAN Rd2md
# ReferenceManual(outdir = file.path(getwd(), "doc"), front.matter = yaml)
## My Rd2md https://github.com/pooranis/Rd2md
ReferenceManual(outdir = file.path(getwd(), "doc"), front.matter = yaml, title.level = 2, run.examples = FALSE, sepexported = TRUE)
file.rename(mdfile, Rmdfile)
render(Rmdfile, output_options = myoutputoptions)
file.remove(Rmdfile)

# User docs ---------------------------------------------------------------

# userRmd <- "doc/user_doc.Rmd"
# mdfile <- "doc/user_doc.md"
# oops <- myoutputoptions
# oops$pandoc_args <- c(oops$pandoc_args, "-M", "title=User docs")
# render(userRmd, output_format = "md_document", output_options = oops)


# render("doc/user_doc.Rmd", output_format = "html_document", output_file = "datavis16s_pipeline.html", output_options=list(pandoc_args = c("--ascii", "-F", "panflute"))
# htmlfile <- readLines("doc/datavis16s_pipeline.html")
# htmlfile <- sapply(htmlfile, clean_pandoc2_highlight_tags)
# writeLines(htmlfile, "doc/datavis16s_pipeline.html")
# remove.file("doc/user_doc.md.bak")





