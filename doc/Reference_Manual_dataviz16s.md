dataviz16s
================

-   [DESCRIPTION](#description)
-   [Exported](#exported)
    -   [`adivboxplot`](#adivboxplot)
    -   [`allgraphs`](#allgraphs)
    -   [`morphheatmap`](#morphheatmap)
    -   [`pcoaplot`](#pcoaplot)
    -   [`rarefactioncurve`](#rarefactioncurve)
    -   [`readindata`](#readindata)
    -   [`trygraphwrapper`](#trygraphwrapper)
-   [Internal](#internal)
    -   [`dataviz16s-package`](#dataviz16s-package)
    -   [`filterlowabund`](#filterlowabund)
    -   [`gridCode`](#gridcode)
    -   [`highertax`](#highertax)
    -   [`logoutput`](#logoutput)
    -   [`plotlyGrid`](#plotlygrid)
    -   [`shortnames`](#shortnames)
    -   [`subsetamp`](#subsetamp)

<!-- toc -->
March 04, 2018

DESCRIPTION
===========

    Package: dataviz16s
    Title: Graphs for Nephele 16S Pipelines
    Version: 0.1.0
    Authors@R: person("Poorani", "Subramanian", email = "poorani.subramanian@nih.gov", role = c("aut", "cre"))
    Description: What the package does (one paragraph).
    Depends: R (>= 3.4.1)
    License: none
    Encoding: UTF-8
    LazyData: true
    RoxygenNote: 6.0.1
    Imports:
      ampvis2,
      biomformat,
      bpexploder,
      data.table,
      ggplot2,
      htmltools,
      htmlwidgets,
      jsonlite,
      morpheus,
      plotly,
      RColorBrewer,
      vegan

Exported
========

`adivboxplot`
-------------

Alpha diversity boxplot

### Description

Plots exploding boxplot of shannon diversity and Chao species richness. If sampling depth is NULL, rarefies OTU table to the minimum readcount of any sample. If this is low, then the plot will fail.

### Usage

``` r
adivboxplot(mapfile, datafile, outdir, amp, sampdepth = NULL, colors = NULL,
  ...)
```

### Arguments

| Argument    | Description                                                      |
|-------------|------------------------------------------------------------------|
| `mapfile`   | full path to map file                                            |
| `datafile`  | full path to input OTU file                                      |
| `outdir`    | full path to output directory                                    |
| `amp`       | ampvis2 object. may be specified instead of mapfile and datafile |
| `sampdepth` | sampling depth                                                   |
| `colors`    | colors to use for plots                                          |
| `...`       | other parameters to pass to [readindata](#readindata)            |

### Value

Save alpha diversity boxplots to outdir.

`allgraphs`
-----------

Pipeline function

### Description

Make all 4 types of graphs

### Usage

``` r
allgraphs(mapfile, datafile, outdir, sampdepth = NULL, ...)
```

### Arguments

| Argument    | Description                                           |
|-------------|-------------------------------------------------------|
| `mapfile`   | full path to map file                                 |
| `datafile`  | full path to input OTU file                           |
| `outdir`    | full path to output directory                         |
| `sampdepth` | sampling depth                                        |
| `...`       | other parameters to pass to [readindata](#readindata) |

### Value

graphs are saved to outdir

`morphheatmap`
--------------

Morpheus heatmap

### Description

Creates heatmaps using Morpheus R API <https://software.broadinstitute.org/morpheus/> .

### Usage

``` r
morphheatmap(mapfile, datafile, outdir, amp, sampdepth = NULL,
  rarefy = FALSE, filter_level = 0.1, taxlevel = c("seq"), ...)
```

### Arguments

<table style="width:43%;">
<colgroup>
<col width="19%" />
<col width="23%" />
</colgroup>
<thead>
<tr class="header">
<th>Argument</th>
<th>Description</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td><code>mapfile</code></td>
<td>full path to mapping file</td>
</tr>
<tr class="even">
<td><code>datafile</code></td>
<td>full path to input OTU file</td>
</tr>
<tr class="odd">
<td><code>outdir</code></td>
<td>full path to output directory</td>
</tr>
<tr class="even">
<td><code>amp</code></td>
<td>(Optional) ampvis2 object. may be specified instead of mapfile and datafile</td>
</tr>
<tr class="odd">
<td><code>sampdepth</code></td>
<td>sampling depth</td>
</tr>
<tr class="even">
<td><code>rarefy</code></td>
<td>Logical. Rarefy the OTU table if sampdepth is specified.</td>
</tr>
<tr class="odd">
<td><code>filter_level</code></td>
<td>minimum abundance to show in the heatmap</td>
</tr>
<tr class="even">
<td><code>taxlevel</code></td>
<td>vector of taxonomic levels to graph. must be subset of c(&quot;Kingdom&quot;, &quot;Phylum&quot;, &quot;Class&quot;, &quot;Order&quot;, &quot;Family&quot;, &quot;Genus&quot;, &quot;Species&quot;, &quot;seq&quot;). See Details.</td>
</tr>
<tr class="odd">
<td><code>...</code></td>
<td>parameters to pass to <a href="#readindata"><code>readindata</code></a></td>
</tr>
</tbody>
</table>

### Details

For the `taxlevel` parameter, each level is made into a separate heatmap. "seq" makes the heatmap with no collapsing of taxonomic levels.

### Value

Saves heatmaps to outdir.

### Examples

``` r
 ## Not run: 
morphheatmap(mapfile="mapfile.txt", datafile="OTU_table.txt", outdir="outputs/graphs",
sampdepth = 25000, taxlevel = c("Family", "seq"), tsvfile=TRUE) 
## End(Not run) 
 
 
```

`pcoaplot`
----------

PCoA plots

### Description

PCoA plots

### Usage

``` r
pcoaplot(mapfile, datafile, outdir, amp, sampdepth = NULL,
  distm = "binomial", filter_species = 0.01, rarefy = FALSE,
  colors = NULL, ...)
```

### Arguments

<table style="width:43%;">
<colgroup>
<col width="19%" />
<col width="23%" />
</colgroup>
<thead>
<tr class="header">
<th>Argument</th>
<th>Description</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td><code>mapfile</code></td>
<td>full path to map file</td>
</tr>
<tr class="even">
<td><code>datafile</code></td>
<td>full path to input OTU file</td>
</tr>
<tr class="odd">
<td><code>outdir</code></td>
<td>full path to output directory</td>
</tr>
<tr class="even">
<td><code>amp</code></td>
<td>ampvis2 object. may be specified instead of mapfile and datafile</td>
</tr>
<tr class="odd">
<td><code>sampdepth</code></td>
<td>sampling depth</td>
</tr>
<tr class="even">
<td><code>distm</code></td>
<td>distance measure for PCoA. any that are supported by <a href="#ampordinate">amp_ordinate</a> except for unifrac, wunifrac, and none.</td>
</tr>
<tr class="odd">
<td><code>filter_species</code></td>
<td>Remove low abundant OTU's across all samples below this threshold in percent. Setting this to 0 may drastically increase computation time.</td>
</tr>
<tr class="even">
<td><code>rarefy</code></td>
<td>Logical. Should the OTU table be rarefied to the sampling depth? See details.</td>
</tr>
<tr class="odd">
<td><code>colors</code></td>
<td>(Optional) color vector - length equal to number of TreatmentGroups in mapfile</td>
</tr>
<tr class="even">
<td><code>...</code></td>
<td>parameters to pass to <a href="#readindata"><code>readindata</code></a></td>
</tr>
</tbody>
</table>

### Value

Saves pcoa plots to outdir.

`rarefactioncurve`
------------------

Make rarefaction curve graph

### Description

Make rarefaction curve graph

### Usage

``` r
rarefactioncurve(mapfile, datafile, outdir, amp, colors = NULL, ...)
```

### Arguments

<table style="width:43%;">
<colgroup>
<col width="19%" />
<col width="23%" />
</colgroup>
<thead>
<tr class="header">
<th>Argument</th>
<th>Description</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td><code>mapfile</code></td>
<td>full path mapping file</td>
</tr>
<tr class="even">
<td><code>datafile</code></td>
<td>full path to OTU file</td>
</tr>
<tr class="odd">
<td><code>outdir</code></td>
<td>full path to output directory</td>
</tr>
<tr class="even">
<td><code>amp</code></td>
<td>(Optional) ampvis2 object. may be specified instead of mapfile and datafile</td>
</tr>
<tr class="odd">
<td><code>colors</code></td>
<td>(Optional) color vector - length equal to number of TreatmentGroups in mapfile</td>
</tr>
<tr class="even">
<td><code>...</code></td>
<td>parameters to pass to <a href="#readindata"><code>readindata</code></a></td>
</tr>
</tbody>
</table>

### Value

Saves rarefaction curve plot to output directory.

`readindata`
------------

Read in data

### Description

Read in data

### Usage

``` r
readindata(mapfile, datafile, tsvfile = FALSE, mincount = 10)
```

### Arguments

<table style="width:43%;">
<colgroup>
<col width="19%" />
<col width="23%" />
</colgroup>
<thead>
<tr class="header">
<th>Argument</th>
<th>Description</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td><code>mapfile</code></td>
<td>full path to mapfile. must contain SampleID, TreatmentGroup, and Description columns</td>
</tr>
<tr class="even">
<td><code>datafile</code></td>
<td>full path to input data file. must be either biom file or tab delimited text file OTU table with 7 level taxonomy.</td>
</tr>
<tr class="odd">
<td><code>tsvfile</code></td>
<td>Logical. Is datafile a tab-delimited text file? See details.</td>
</tr>
<tr class="even">
<td><code>mincount</code></td>
<td>minimum number of reads</td>
</tr>
</tbody>
</table>

### Details

datafile may be either biom file or text file. If text file, it should have ampvis2 OTU table format <https://madsalbertsen.github.io/ampvis2/reference/amp_load.html#the-otu-table> . If the number of reads is less than mincount, the function will give an error, as we cannot make graphs with so few counts.

### Value

ampvis2 object

`trygraphwrapper`
-----------------

Wrapper for any graph function

### Description

This is a wrapper for any of the graph functions meant to be called using rpy2 in python.

### Usage

``` r
trygraphwrapper(mapfile, datafile, outdir, FUN, logfilename = "logfile.txt",
  info = TRUE, ...)
```

### Arguments

| Argument      | Description                      |
|---------------|----------------------------------|
| `mapfile`     | full path to map file            |
| `datafile`    | full path input OTU file         |
| `outdir`      | output directory for graphs      |
| `FUN`         | function you would like to run   |
| `logfilename` | logfilename                      |
| `info`        | print sessionInfo to logfile     |
| `...`         | parameters needed to pass to FUN |

### Value

Returns 0 if FUN succeeds and 1 if it returns an error.

### Examples

``` r
 
 ## Not run: 
trygraphwrapper("/mnt/EFS/user_uploads/job_id/inputs/mapfile.txt","/mnt/EFS/user_uploads/job_id/outputs/out.biom",
"/mnt/EFS/user_uploads/job_id/outputs/", allgraphs)
# example with no optional arguments for running allgraphs 
## End(Not run) 
 
 ## Not run: 
trygraphwrapper("/mnt/EFS/user_uploads/job_id/inputs/mapfile.txt","/mnt/EFS/user_uploads/job_id/outputs/out.biom",
"/mnt/EFS/user_uploads/job_id/outputs/", allgraphs, sampdepth = 30000)
# example with optional arguments sampdepth 
## End(Not run) 
 
```

Internal
========

`dataviz16s-package`
--------------------

dataviz16s: A package for Nephele 16S pipeline visualization

### Description

dataviz16s: A package for Nephele 16S pipeline visualization

`filterlowabund`
----------------

Filter low abundant taxa

### Description

Filter low abundant taxa

### Usage

``` r
filterlowabund(amp, level = 0.01, persamp = 0, abs = FALSE)
```

### Arguments

<table style="width:43%;">
<colgroup>
<col width="19%" />
<col width="23%" />
</colgroup>
<thead>
<tr class="header">
<th>Argument</th>
<th>Description</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td><code>amp</code></td>
<td>ampvis2 object</td>
</tr>
<tr class="even">
<td><code>level</code></td>
<td>level at which to filter</td>
</tr>
<tr class="odd">
<td><code>persamp</code></td>
<td>percent of samples which must have taxa in common</td>
</tr>
<tr class="even">
<td><code>abs</code></td>
<td>is level an absolute count? if false, will use level as relative percent.</td>
</tr>
</tbody>
</table>

### Value

filtered ampvis2 object

`gridCode`
----------

Format plotly grid code

### Usage

``` r
gridCode(data)
```

### Arguments

| Argument | Description                  |
|----------|------------------------------|
| `data`   | data to populate plotly grid |

### Value

list of 3 values:

-   `jq` optional jquery script
-   `html` html for plotly export link
-   `javascript` js function for exporting data

`highertax`
-----------

return tables at higher tax level

### Description

return tables at higher tax level

### Usage

``` r
highertax(amp, taxlevel = NULL)
```

### Arguments

| Argument   | Description                                   |
|------------|-----------------------------------------------|
| `amp`      | ampvis2 object                                |
| `taxlevel` | taxonomic level at which to sum up the counts |

### Value

ampvis2 object with otu table and taxa summed up to the taxlevel

`logoutput`
-----------

write log output

### Description

Prints time along with log message.

### Usage

``` r
logoutput(c, bline = 0, aline = 0)
```

### Arguments

| Argument | Description                              |
|----------|------------------------------------------|
| `c`      | String. Log message/command to print.    |
| `bline`  | Number of blank lines to precede output. |
| `aline`  | Number of blank lines to follow output.  |

`plotlyGrid`
------------

Add Plotly data export to Plotly graph

### Description

All functions create an output html plot with link which sends the data to a grid in the plotly chart studio.

`plotlyGrid` takes in a ggplot or plotly object and creates an output html plotly plot.

`nonplotlyGrid` takes in an htmlwidget.

`htmlGrid` takes in an html tag object.

### Usage

``` r
plotlyGrid(pplot, filename, data = NULL, title = NULL, outlib = "lib")
nonplotlyGrid(hw, filename, data, jquery = FALSE, title = NULL,
  outlib = "lib")
htmlGrid(ht, filename, data, jquery = FALSE, title = NULL, outlib = "lib")
```

### Arguments

<table style="width:43%;">
<colgroup>
<col width="19%" />
<col width="23%" />
</colgroup>
<thead>
<tr class="header">
<th>Argument</th>
<th>Description</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td><code>pplot</code></td>
<td>plotly or ggplot object</td>
</tr>
<tr class="even">
<td><code>filename</code></td>
<td>output filename (fullpath)</td>
</tr>
<tr class="odd">
<td><code>data</code></td>
<td>data frame to export to plotly grid (optional for plotlyGrid)</td>
</tr>
<tr class="even">
<td><code>title</code></td>
<td>title of html page</td>
</tr>
<tr class="odd">
<td><code>outlib</code></td>
<td>(Optional) name of external lib directory for non-selfcontained html. Useful for multiple graphs sharing the same lib.</td>
</tr>
<tr class="even">
<td><code>hw</code></td>
<td>htmlwidget</td>
</tr>
<tr class="odd">
<td><code>jquery</code></td>
<td>should we load jquery</td>
</tr>
<tr class="even">
<td><code>ht</code></td>
<td>html tagList</td>
</tr>
</tbody>
</table>

### Value

html plot is saved to filename. external libraries are saved to outlib in same directory as filename.

`shortnames`
------------

shortnames for SILVA taxonomy

### Description

shortnames for SILVA taxonomy

### Usage

``` r
shortnames(taxtable, taxa = "Species")
```

### Arguments

| Argument   | Description                                    |
|------------|------------------------------------------------|
| `taxtable` | taxonomy table object from amp$tax             |
| `taxa`     | taxonomic level at which to retrieve the names |

### Value

Vector of shortened names for each seqvar/otu.

`subsetamp`
-----------

Subset and rarefy OTU table.

### Description

Subset and/or rarefy OTU table.

### Usage

``` r
subsetamp(amp, sampdepth, rarefy = FALSE)
```

### Arguments

| Argument    | Description                                    |
|-------------|------------------------------------------------|
| `amp`       | ampvis2 object                                 |
| `sampdepth` | sampling depth. See details.                   |
| `rarefy`    | rarefy the OTU table in addition to subsetting |

### Details

`sampdepth` will be used to filter out samples with fewer than this number of reads. If rarefy is TRUE, then it will also be used as the depth at which to subsample using vegan function rrarefy.

### Value

ampvis2 object
