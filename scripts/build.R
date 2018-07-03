library(devtools)
library(rmarkdown)
library(Rd2md)


## Build package
document(roclets=c('rd', 'collate', 'namespace'))
install(args = c("--preclean", "--no-multiarch", "--with-keep.source"), upgrade_dependencies = F)

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

## Sphinx
templatedir <- "../../misc_examples/Rdocs"
docsdir <- "../../docs/api_docs/source"

pcrst <- function(markdownfile, rstfile, path=F) {
  system2('perl', args = c(file.path(templatedir, 'md2rst.pl'), markdownfile, 'https://github.niaid.nih.gov/bcbb/nephele2/tree/master/pipelines/datavis16s'))
  if (path) {
    outfile = rstfile
  } else {
    outfile = file.path(docsdir, rstfile)
  }
  pandoc_convert(paste0(markdownfile, ".bak"), to = "rst", options = c("--columns=1000", "-s", "--template=/Users/subramanianp4/git/nephele2/misc_examples/Rdocs/template.rst"), wd = getwd(), output = outfile, verbose = TRUE)
}


yaml <- "---
title: \"datavis16s R package manual\"
author: Poorani Subramanian
output:
  md_document:
    variant: markdown_strict+grid_tables
    pandoc_args: \"--columns=1000\"
header-includes:  |
  | ---
  | title: \"datavis16s R package manual\"
  | author: Poorani Subramanian
  | header-includes: \\|
  |   :tocdepth: 3
  |
  | ---

---
```{r setup, include=FALSE}
knitr::opts_chunk$set(echo = TRUE, eval = TRUE, tidy=TRUE, tidy.opts = list(width.cutoff=60))
```

"
Rmdfile <-  "doc/Reference_Manual_datavis16s.Rmd"
mdfile <-  "doc/tempfile.md"


ReferenceManual(front.matter = yaml, title.level = 1, run.examples = FALSE, sepexported = TRUE, man_file = Rmdfile)
rmarkdown::render(Rmdfile, output_file = basename(mdfile))
pcrst(mdfile, "Reference_Manual_datavis16s.rst")

file.remove(Rmdfile)
file.remove(mdfile)
file.remove(paste0(mdfile, ".bak"))
file.remove("doc/Reference_Manual_datavis16s.html")

## User docs

userRmd <- "doc/user_doc.Rmd"
usermd <- "doc/user_doc.md"
render(userRmd, output_format = "github_document")
pcrst(usermd,"datavis16s.user_doc.rst" )


# file.rename("doc/user_doc.md", "doc/github_doc.md")
render(userRmd, output_format = "html_document", output_file = "datavis16s_pipeline.html")
system2(command = "sed" , args=c('-i.bak', '\'s/[\\“\\”]/\"/g\'', "doc/datavis16s_pipeline.html"))
file.remove("doc/datavis16s_pipeline.html.bak")
file.remove("doc/user_doc.md")
file.remove(c("doc/user_doc.html", "doc/user_doc.md.bak"))

render("README.Rmd")
pcrst("README.md", "datavis16s.readme.rst")
file.remove(c("README.md.bak", "README.html"))
system2("/Users/subramanianp4/git/n2_docs/sphinx.sh")

