library(devtools)
library(rmarkdown)

## Build package
document(roclets=c('rd', 'collate', 'namespace'))
install(args = c("--preclean", "--no-multiarch", "--with-keep.source"))

## Imported packages - can check DESCRIPTION
ns <- scan("NAMESPACE", sep="\n", what = character())
importedpackages <- unique(stringr::str_match(ns, "import.*\\((.*?)[\\,\\)]")[,2])

## Documentation

## library function specification
library(Rd2md)
yaml <- "---
title: \"datavis16s\"
output:
    github_document:
        toc: true
        toc_depth: 2
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
ReferenceManual(outdir = file.path(getwd(), "doc"), front.matter = yaml, title.level = 1, run.examples = FALSE, sepexported = TRUE)
file.copy(mdfile, Rmdfile, overwrite = TRUE )
render(Rmdfile)
#file.remove(Rmdfile)

# ## User docs
# render("doc/user_doc.Rmd", output_format = "github_document")
# file.rename("doc/user_doc.md", "doc/github_doc.md")
# render("doc/user_doc.Rmd", output_format = "html_document", output_file = "datavis16s_pipeline.html")
# system2(command = "sed" , args=c('-i.bak', '\'s/[\\“\\”]/\"/g\'', "doc/datavis16s_pipeline.html"))
# file.remove("doc/datavis16s_pipeline.html.bak")
# file.rename("doc/github_doc.md", "doc/user_doc.md")
# file.remove("doc/user_doc.html")

## README
# render("README.Rmd")
# file.remove("README.html")
