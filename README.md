# datavis16s

#### Dependencies

- To install all dependencies, run the commands in [dependencies.R](scripts/dependencies.R).  You may need to change the path to the datavis16s directory.

-   To build the package along with the user and package documentation, run the commands in [build.R](scripts/build.R). This will produce the standard man files for within-R help, as well as the [package manual](doc/Reference_Manual_datavis16s.md) and the [user docs](doc/user_doc.md).

    ``` r
    source("scripts/build.R")
    ```

#### Usage

- The generic wrapper function to be called from rpy2 is [`trygraphwrapper`](doc/Reference_Manual_datavis16s.md#trygraphwrapper).  It returns 0 for success and 1 for failure.  See the function help for examples.  
- There are 4 main functions for making graphs: `alphadivboxplot`, `morphheatmap`, `pcoaplot`, and `rarefactioncurve`, as well as `allgraphs` which makes all 4.  See the [manual](doc/Reference_Manual_datavis16s.md).
- For use in python, you must pass the full paths for the output directory, mapping file, biom file (or tab-delimited OTU table -- see [`readindata`](doc/Reference_Manual_datavis16s.md#readindata) for more information).
- For use in R, you can use `readindata` to create an ampvis2 object, and pass that instead of the mapping file and biom file.
- The sampling depth, `sampdepth`, is optional for all graphs except for the alpha diversity boxplot which requires it to rarefy the OTU table.  If you do not specify, it will use the number of reads from the smallest sample.
- `trygraphwrapper`, by default, prints the R sessionInfo to the logfile before it runs the function.  If you do not want it to do this (e.g. if you are calling the function multiple times in the same script), you can pass `info = FALSE`.

#### Outputs

- The `trygraphwrapper` function creates a subdirectory "graphs" in outdir, and passes that as the output directory to the individual functions.  The individual graph functions just use outdir as the output directory.
- Creates html files in outdir as well as subdirectory "lib" which contains the external js,css,etc files for the graphs.

#### Installation

-   You can install this package, datavis16s, with devtools within R from a locally cloned repository (may need to change directory):

    ``` r
    devtools::install_local("/path/to/nephele2/pipelines/datavis16s", 
        dependencies = TRUE, force = TRUE)
    ```

-   or you can install from the command line (**this does not install dependencies, which should already be installed**):

    ``` bash
    R CMD INSTALL --no-help /path/to/nephele2/pipelines/datavis16s
    ```

-   or to use devtools to install datavis16s from the NIAID github, you will need to generate a [GitHub personal access token](https://help.github.com/articles/creating-a-personal-access-token-for-the-command-line/). In R:

    ``` r
    # change token to token string
    Sys.setenv(GITHUB_PAT = "token")
    # change ref to whichever branch
    devtools::install_github("bcbb/nephele2/pipelines/datavis16s", 
        host = "https://github.niaid.nih.gov/api/v3", ref = "16sdataviz", 
        dependencies = TRUE)
    ```