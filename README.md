datavis16s R package
================

-   [Dependencies](#dependencies)
-   [Usage](#usage)
-   [Installation](#installation)

R package for graphs for Nephele 16S pipelines.

### Dependencies

-   For the Nephele AMI, debian package libxml2-dev is needed.
-   Requires [rpy2](https://rpy2.bitbucket.io) to use with python.
-   To install all R dependencies, run the commands in [dependencies.R](scripts/dependencies.R). You may need to change the path to the datavis16s directory.
-   To build the package along with the user and package documentation, run the commands in [build.R](scripts/build.R). This will produce the standard man files for within-R help, as well as the [package manual](doc/Reference_Manual_datavis16s.md) and the user docs [sphinx](datavis16s.user_doc.html) and [html for Nephele2 website](https://github.niaid.nih.gov/bcbb/nephele2/blob/master/pipelines/datavis16s/doc/datavis16s_pipeline.html).

    ``` r
    source("scripts/build.R")
    ```

### Usage

-   There are 4 main functions for making graphs: `adivboxplot`, `morphheatmap`, `pcoaplot`, and `rarefactioncurve`, as well as `allgraphs` which makes all 4 (used as [DADA2 pipeline](../DADA2) function). See the [manual](doc/Reference_Manual_datavis16s.md) for the arguments for these functions.

-   **Python with rpy2**
    -   The generic wrapper function to be called from rpy2 is [trygraphwrapper](doc/Reference_Manual_datavis16s.md#trygraphwrapper). It returns 0 for success and 1 for failure. See the [function help](doc/Reference_Manual_datavis16s.md#trygraphwrapper) for examples.
    -   Must pass the full paths for the output directory, mapping file, biom file[1](#fn1).
    -   `trygraphwrapper`, by default, prints the R sessionInfo to the logfile before it runs the function. If you do not want it to do this (e.g. if you are calling the function multiple times in the same script), you can pass `info = FALSE`.
-   **R**
    -   You can use `readindata` to create an ampvis2 object, and pass that instead of the mapping file and biom file.
-   **Sampling depth**
    -   The sampling depth argument, `sampdepth`, is optional for all functions.
    -   If specified, it is used to remove samples with read counts below `sampdepth`.
    -   For functions with `rarefy` argument, setting to TRUE will rarefy the OTU table to `sampdepth` reads. `adivboxplot` will use the smallest sample size to rarefy if `sampdepth` is not specified.

    -   For pipelines, the alpha diversity boxplot and the PCoA would benefit from having this sampling depth set properly.
        -   Poorani and Conrad implemented the median absolute deviation method as default across all pipelines. See :any:`get_depth` and :any:`left_mad_zcore`
        -   All other functions will not remove samples or rarefy unless `sampdepth` is specified.

1Can optionally pass tab-delimited text file to each of the functions instead of the biom file. See \[`readindata`\]\[doc/Reference\_Manual\_datavis16s.md\#readindata\] for more details.

#### Outputs

-   `trygraphwrapper` creates a subdirectory "graphs" in output directory, and passes that as the output directory to the individual functions. The individual graph functions just use the specified output directory passed to them. - Creates html files in outdir as well as subdirectory "lib" which contains the external js,css,etc files for the graphs. See [user doc](https://github.niaid.nih.gov/bcbb/nephele2/blob/master/pipelines/datavis16s/doc/user_doc.md) for more info.

### Installation

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
        host = "https://github.niaid.nih.gov/api/v3", ref = "datavis16s", 
        dependencies = TRUE)
    ```
