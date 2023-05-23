datavis16s README
================

- [Usage](#usage)

- [Outputs](#outputs)

- [Dependencies](#dependencies)

  

R package for graphs for Nephele 16S pipelines.

## Usage

- **Function reference:** [datavis16s R package manual](doc/Reference_Manual_datavis16s.md) 
- **Nephele User docs:** [html for Nephele2 website](https://github.niaid.nih.gov/bcbb/nephele2/blob/master/pipelines/datavis16s/doc/datavis16s_pipeline.html)

**Within R**

- There are 4 main functions for making graphs: `adivboxplot`, `morphheatmap`, `pcoaplot`, and `rarefactioncurve`, as well as `allgraphs` which makes all 4. See the [manual](doc/Reference_Manual_datavis16s.md) for the arguments for these functions.
- You can use `readindata` to create an ampvis2 object, and pass that instead of the mapping file and biom file.

**Command line**

- The script [graphs.R](R/graphs.R) can be run on the command line using Rscript:

- ```bash
  $ ./graphs.R --help
  Usage: graphs.R [-h] [-l <logfile> -s <sampdepth> --tsvfile --mincount <mincount>] -d <datafile> -m <mapfile> -o <outdir>
  
  -h --help                         show this
  -d --datafile FILE                input ASV/OTU table - either biom or tsv file. required.
  -m --mapfile FILE                 mapping file. required.
  -o --outdir DIR                   output directory. required.
  -l --logfilename FILE             log filename [default: logfile.txt]
  -s --sampdepth N                  Integer. sampling depth [default: 10000]
  --tsvfile                         Logical. Is datafile a tab-delimited text (tsv) file? Default (FALSE) expects biom file.
  --mincount N                      Integer. minimum number of reads to produce graphs [default: 10]
  ```

  

**Sampling depth**
-   The sampling depth argument, `sampdepth`, is optional for all functions.
-   If specified, it is used to remove samples with read counts below `sampdepth`.
-   For functions with `rarefy` argument, setting to TRUE will rarefy the OTU table to `sampdepth` reads. `adivboxplot` will use the smallest sample size to rarefy if `sampdepth` is not specified.
-   Currently, we use 10000 as the default.

1Can optionally pass tab-delimited text file to each of the functions instead of the biom file. See \[`readindata`\]\[doc/Reference\_Manual\_datavis16s.md\#readindata\] for more details.

### Outputs

-   `trygraphwrapper` creates a subdirectory “graphs” in output directory, and passes that as the output directory to the individual functions. The individual graph functions just use the specified output directory passed to them. - Creates html files in outdir as well as subdirectory “lib” which contains the external js,css,etc files for the graphs. See [user doc](https://github.niaid.nih.gov/bcbb/nephele2/blob/master/pipelines/datavis16s/doc/user_doc.md) for more info.

## Dependencies

-   For the Nephele AMI, debian package libxml2-dev is needed.
-   To install all R dependencies, see [datavis16s_dependencies.R](scripts/datavis16s_dependencies.R). 
- See [Tools and References](doc/user_doc.md#tools-and-references) in the user doc for dependency citations.
