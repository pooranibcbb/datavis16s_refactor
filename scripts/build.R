library(devtools)
library(rmarkdown)
library(Rd2md)


# Build package ----------------------------------------------------------------------------------
# document(roclets=c('rd', 'collate', 'namespace'))
# devtools::install(args = c("--preclean", "--no-multiarch", "--with-keep.source"), dependencies = F, upgrade=F)
#
# ## Imported packages - can check DESCRIPTION
# ns <- scan("NAMESPACE", sep="\n", what = character())
# importedpackages <- unique(stringr::str_match(ns, "import.*\\((.*?)[\\,\\)]")[,2])
#
#
# ## update description
# desc::desc_set(Date=format(Sys.time(), format = "%F %T UTC", tz="GMT"), normalize=TRUE)
# deptable <- desc::desc_get_deps()
# # deptable$version <- apply(deptable, 1, function(x) { if (x[2] == "R") return(x[3]); paste("==", packageVersion(x[2])) })
# desc::desc_set_deps(deptable, normalize = TRUE)


# Documentation --------------------------------

myoutputoptions <- list(pandoc_args=paste0("--template=", file.path(find.package("rmarkdown"), "rmarkdown/templates/github_document/resources/default.md")))

remove.file <- function(x) {
  suppressWarnings(file.remove(x))
}

templatedir <- tools::file_path_as_absolute("../../misc_examples/Rdocs")

clean_pandoc2_highlight_tags = function(x) {
  x = gsub('(</a></code></pre>)</div>', '\\1', x)
  x = gsub('<div class="sourceCode"[^>]+>(<pre)', '\\1', x)
  x = gsub('<a class="sourceLine"[^>]+>(.*)</a>', '\\1', x)
  x
}

pcrst <- function(markdownfile, rstfile, docsd,poptions=NULL) {
  system2('perl', args = c(file.path(templatedir, 'md2rst.pl'), markdownfile, 'https://github.niaid.nih.gov/bcbb/nephele2/tree/master/pipelines/datavis16s'))
  poptions <-  c(poptions,"--columns=1000", "-s", paste0("--template=", templatedir,"/template.rst"))
  pandoc_convert(paste0(markdownfile, ".bak"), to = "rst", options = poptions, wd = getwd(), output = file.path(docsd, rstfile), verbose = TRUE)
}



## library function specification ============
#
# yaml <- "---
# title: \"datavis16s\"
# output:
#   md_document:
#     variant: markdown_github-ascii_identifiers+link_attributes
#     toc: true
#     toc_depth: 2
# ---
#
# ```{r setup, include=FALSE}
# knitr::opts_chunk$set(echo = TRUE, eval = FALSE, tidy=TRUE, tidy.opts = list(width.cutoff=80))
# ```
# "
#
# mdfile <- "doc/Reference_Manual_datavis16s.md"
# Rmdfile <- gsub(".md", ".Rmd", mdfile)
# ## CRAN Rd2md
# # ReferenceManual(outdir = file.path(getwd(), "doc"), front.matter = yaml)
# ## My Rd2md https://github.com/pooranis/Rd2md
# ReferenceManual(outdir = file.path(getwd(), "doc"), front.matter = yaml, title.level = 1, run.examples = FALSE, sepexported = TRUE)
# file.rename(mdfile, Rmdfile)
# render(Rmdfile, output_options = myoutputoptions)
file.remove(Rmdfile)

## Sphinx ==========
templatedir <- "../../misc_examples/Rdocs"
docsdir <- "../../docs/source"


#
yaml <- "---
title: datavis16s R functions
author: Poorani Subramanian
output:
  md_document:
    toc: true
    toc_depth: 3
    variant: markdown_strict+grid_tables
    pandoc_args: \"--columns=1000\"
---
```{r setup, include=FALSE}
knitr::opts_chunk$set(echo = TRUE, eval = TRUE, tidy=TRUE, tidy.opts = list(width.cutoff=60))
```

"
Rmdfile <-  "doc/Reference_Manual_datavis16s.Rmd"
mdfile <-  "doc/tempfile.md"


ReferenceManual(front.matter = yaml, title.level = 2, run.examples = FALSE, sepexported = TRUE, man_file = Rmdfile)
oops <- myoutputoptions
oops$pandoc_args <- c(oops$pandoc_args, "-M", "title=User docs")
rmarkdown::render(Rmdfile, output_file = basename(mdfile), output_options = myoutputoptions)
pcrst(mdfile, "Reference_Manual_datavis16s.rst", docsd = "./doc")

file.remove(Rmdfile)
file.remove(mdfile)
file.remove(paste0(mdfile, ".bak"))
file.remove("doc/Reference_Manual_datavis16s.html")

# User docs ---------------------------------------------------------------

userRmd <- "doc/user_doc.Rmd"
mdfile <- "doc/user_doc.md"
oops <- myoutputoptions
oops$pandoc_args <- c(oops$pandoc_args, "-M", "title=User docs")
render(userRmd, output_format = "md_document", output_options = oops)
pcrst(mdfile, "user_doc.rst", docsd = './doc')

render("doc/user_doc.Rmd", output_format = "html_document", output_file = "datavis16s_pipeline.html", output_options=list(pandoc_args = c("--ascii")))
htmlfile <- readLines("doc/datavis16s_pipeline.html")
htmlfile <- sapply(htmlfile, clean_pandoc2_highlight_tags)
writeLines(htmlfile, "doc/datavis16s_pipeline.html")
remove.file("doc/user_doc.md.bak")
remove.file("doc/user_doc.md")


# README ------------------------------------------------------------------

rmarkdown::render("R_README.Rmd", output_options=myoutputoptions, output_file = "README.md")
pcrst("README.md", "README.rst", docsd = '.')

remove.file("README.md.bak")
remove.file("README.md")


