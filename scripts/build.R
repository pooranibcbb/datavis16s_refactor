library(devtools)
library(rmarkdown)


## Build package
document(roclets=c('rd', 'collate', 'namespace'))
install(args = c("--preclean", "--no-multiarch", "--with-keep.source"))

## Imported packages - can check DESCRIPTION
ns <- scan("NAMESPACE", sep="\n", what = character())
importedpackages <- unique(stringr::str_match(ns, "import.*\\((.*?)[\\,\\)]")[,2])

## update description
#desc::desc_set(Date=format(Sys.time(), format = "%F %T UTC", tz="GMT"), normalize=TRUE)
# deptable <- desc::desc_get_deps()
# deptable$version <- apply(deptable, 1, function(x) { if (x[2] == "R") return(x[3]); paste("==", packageVersion(x[2])) })
# desc::desc_set_deps(deptable, normalize = TRUE)


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
file.remove(Rmdfile)

yaml <- "---
title: \"datavis16s R package\"
author: Poorani Subramanian
header-includes: |
:tocdepth: 3
---
"

Rmdfile <-  "doc/datavis16s.R.Rmd"
docsdir <- "../../docs/api_docs/source"
templatedir <- "../../misc_examples/Rdocs"

ReferenceManual(outdir = tempdir(), front.matter = yaml, title.level = 1, run.examples = TRUE, sepexported = TRUE)
file.rename(file.path(tempdir(),"Reference_Manual_datavis16s.md" ), Rmdfile)
system2(command = "sed" , args=c('-i.bak', '\'s/\\[\`/\\[/g\'', Rmdfile))
system2(command = "sed" , args=c('-i.bak', '\'s/\`\\]/\\]/g\'', Rmdfile))
pandoc_convert(Rmdfile, to = "rst", options = c("--columns=1000", "-s", paste0("--template=",templatedir, "/template.rst")), wd = getwd(), output = file.path(docsdir, "datavis16s.R.rst"), verbose = TRUE)
file.remove(Rmdfile)
file.remove(paste0(Rmdfile, ".bak"))

## User docs

userRmd <- "doc/user_doc.Rmd"
usermd <- "doc/user_doc.md"
render(userRmd, output_format = "github_document")
system2(command = "sed" , args=c('-i.bak', '\'s/\\[\`/\\[/g\'', usermd))
system2(command = "sed" , args=c('-i.bak', '\'s/\`\\]/\\]/g\'', usermd))
pandoc_convert(usermd, to = "rst", options = c("--columns=1000", "-s", paste0("--template=",templatedir, "/template.rst")), wd = getwd(), output = file.path(docsdir, "datavis16s.user_doc.rst"), verbose = TRUE)

# file.rename("doc/user_doc.md", "doc/github_doc.md")
render(userRmd, output_format = "html_document", output_file = "datavis16s_pipeline.html")
system2(command = "sed" , args=c('-i.bak', '\'s/[\\“\\”]/\"/g\'', "doc/datavis16s_pipeline.html"))
file.remove("doc/datavis16s_pipeline.html.bak")
# file.rename("doc/github_doc.md", "doc/user_doc.md")
file.remove(c("doc/user_doc.html", "doc/user_doc.md.bak"))


