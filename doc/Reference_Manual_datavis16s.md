datavis16s
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
    -   [`datavis16s-package`](#datavis16s-package)
    -   [`filterlowabund`](#filterlowabund)
    -   [`gridCode`](#gridcode)
    -   [`highertax`](#highertax)
    -   [`logoutput`](#logoutput)
    -   [`plotlyGrid`](#plotlygrid)
    -   [`print_ampvis2`](#print_ampvis2)
    -   [`save_fillhtml`](#save_fillhtml)
    -   [`shortnames`](#shortnames)
    -   [`subsetamp`](#subsetamp)

<!-- toc -->
May 03, 2018

DESCRIPTION
===========

    Package: datavis16s
    Title: Graphs for Nephele 16S Pipelines
    Version: 0.1.0
    Date: 2018-03-20 22:26:33 UTC
    Authors@R (parsed):
        * Poorani Subramanian <poorani.subramanian@nih.gov> [aut, cre]
    Description: betterbetterplots!
    License: none
    URL:
        https://github.niaid.nih.gov/bcbb/nephele2/tree/master/pipelines/datavis16s
    Depends:
        R (>= 3.4.1)
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
    Encoding: UTF-8
    LazyData: true
    RoxygenNote: 6.0.1

Exported
========

`adivboxplot`
-------------

Alpha diversity boxplot

### Description

Plots exploding boxplot of shannon diversity and Chao species richness. If sampling depth is NULL, rarefies OTU table to the minimum readcount of any sample. If this is low, then the plot will fail.

### Usage

``` r
adivboxplot(datafile, outdir, mapfile, amp = NULL, sampdepth = NULL, colors = NULL, 
    ...)
```

### Arguments

| Argument    | Description                                                      |
|-------------|------------------------------------------------------------------|
| `datafile`  | full path to input OTU file                                      |
| `outdir`    | full path to output directory                                    |
| `mapfile`   | full path to map file                                            |
| `amp`       | ampvis2 object. may be specified instead of mapfile and datafile |
| `sampdepth` | sampling depth. see details.                                     |
| `colors`    | colors to use for plots                                          |
| `...`       | other parameters to pass to [readindata](#readindata)            |

### Details

If `sampdepth` is NULL, the sampling depth is set to the size of the smallest sample.

### Value

Save alpha diversity boxplots to outdir.

### Source

[graphs.R](../R/graphs.R)

`allgraphs`
-----------

Pipeline function

### Description

Make all 4 types of graphs

### Usage

``` r
allgraphs(datafile, outdir, mapfile, sampdepth = NULL, ...)
```

### Arguments

| Argument    | Description                                                          |
|-------------|----------------------------------------------------------------------|
| `datafile`  | full path to input OTU file (biom or see [readindata](#readindata) ) |
| `outdir`    | full path to output directory                                        |
| `mapfile`   | full path to map file                                                |
| `sampdepth` | sampling depth. see details.                                         |
| `...`       | other parameters to pass to [readindata](#readindata)                |

### Details

If sampdepth is NULL, then the sampling depth is set to the size of the smallest sample larger than 0.2\*median sample size. Otherwise, it is set to the size of the smallest sample larger than sampdepth.

This value is used to remove samples before for alpha diversity and PCoA plots. Also, to rarefy OTU table for the alpha diversity and Bray-Curtis distance PCoA.

### Value

graphs are saved to outdir. See [user doc](../doc/user_doc.md).

### Source

[graphs.R](../R/graphs.R)

`morphheatmap`
--------------

Morpheus heatmap

### Description

Creates heatmaps using Morpheus R API <https://software.broadinstitute.org/morpheus/> . The heatmaps are made using relative abundances.

### Usage

``` r
morphheatmap(datafile, outdir, mapfile, amp = NULL, sampdepth = NULL, rarefy = FALSE, 
    filter_level = 0, taxlevel = c("seq"), colors = NULL, ...)
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
<td><code>datafile</code></td>
<td>full path to input OTU file (biom or see <a href="#readindata">readindata</a> )</td>
</tr>
<tr class="even">
<td><code>outdir</code></td>
<td>full path to output directory</td>
</tr>
<tr class="odd">
<td><code>mapfile</code></td>
<td>full path to mapping file</td>
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
<td><code>colors</code></td>
<td>(Optional) color vector - length equal to number of TreatmentGroups in mapfile</td>
</tr>
<tr class="even">
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
morphheatmap(datafile = "OTU_table.txt", outdir = "outputs/graphs", mapfile = "mapfile.txt", 
    sampdepth = 25000, taxlevel = c("Family", "seq"), tsvfile = TRUE)
## End(Not run)
```

### Source

[graphs.R](../R/graphs.R)

`pcoaplot`
----------

PCoA plots

### Description

PCoA plots

### Usage

``` r
pcoaplot(datafile, outdir, mapfile, amp = NULL, sampdepth = NULL, distm = "binomial", 
    filter_species = 0.1, rarefy = FALSE, colors = NULL, ...)
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
<td><code>datafile</code></td>
<td>full path to input OTU file (biom or see <a href="#readindata">readindata</a> )</td>
</tr>
<tr class="even">
<td><code>outdir</code></td>
<td>full path to output directory</td>
</tr>
<tr class="odd">
<td><code>mapfile</code></td>
<td>full path to map file</td>
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
<td>distance measure for PCoA. any that are supported by <a href="https://madsalbertsen.github.io/ampvis2/reference/amp_ordinate.html">amp_ordinate</a> except for unifrac, wunifrac, and none.</td>
</tr>
<tr class="odd">
<td><code>filter_species</code></td>
<td>Remove low abundant OTU's across all samples below this threshold in percent. Setting this to 0 may drastically increase computation time.</td>
</tr>
<tr class="even">
<td><code>rarefy</code></td>
<td>Logical. Rarefy the OTU table if sampdepth is specified.</td>
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

### Source

[graphs.R](../R/graphs.R)

`rarefactioncurve`
------------------

Make rarefaction curve graph

### Description

Make rarefaction curve graph

### Usage

``` r
rarefactioncurve(datafile, outdir, mapfile, amp = NULL, colors = NULL, ...)
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
<td><code>datafile</code></td>
<td>full path to input OTU file (biom or see <a href="#readindata">readindata</a> )</td>
</tr>
<tr class="even">
<td><code>outdir</code></td>
<td>full path to output directory</td>
</tr>
<tr class="odd">
<td><code>mapfile</code></td>
<td>full path mapping file</td>
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

### Source

[graphs.R](../R/graphs.R)

`readindata`
------------

Read in data

### Description

Read in data

### Usage

``` r
readindata(datafile, mapfile, tsvfile = FALSE, mincount = 10)
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
<td><code>datafile</code></td>
<td>full path to input data file. must be either biom file or tab delimited text file. See details. #' <span class="citation">@param</span> mapfile full path to mapfile. must contain SampleID, TreatmentGroup, and Description columns</td>
</tr>
<tr class="even">
<td><code>tsvfile</code></td>
<td>Logical. Is datafile a tab-delimited text file? See details.</td>
</tr>
<tr class="odd">
<td><code>mincount</code></td>
<td>minimum number of reads</td>
</tr>
</tbody>
</table>

### Details

datafile may be either biom file or text file. If text file, it should have ampvis2 OTU table format <https://madsalbertsen.github.io/ampvis2/reference/amp_load.html#the-otu-table> . If the number of reads is less than mincount, the function will give an error, as we cannot make graphs with so few counts.

### Value

ampvis2 object

### Source

[graphs.R](../R/graphs.R)

`trygraphwrapper`
-----------------

Wrapper for any graph function

### Description

This is a wrapper for any of the graph functions meant to be called using rpy2 in python.

### Usage

``` r
trygraphwrapper(datafile, outdir, mapfile, FUN, logfilename = "logfile.txt", info = TRUE, 
    ...)
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
<td><code>datafile</code></td>
<td>full path to input OTU file (biom or txt, see <a href="#readindata">readindata</a> )</td>
</tr>
<tr class="even">
<td><code>outdir</code></td>
<td>output directory for graphs</td>
</tr>
<tr class="odd">
<td><code>mapfile</code></td>
<td>full path to map file</td>
</tr>
<tr class="even">
<td><code>FUN</code></td>
<td>character string. name of function you would like to run. can be actual function object if run from R</td>
</tr>
<tr class="odd">
<td><code>logfilename</code></td>
<td>logfilename</td>
</tr>
<tr class="even">
<td><code>info</code></td>
<td>print sessionInfo to logfile</td>
</tr>
<tr class="odd">
<td><code>...</code></td>
<td>parameters needed to pass to FUN</td>
</tr>
</tbody>
</table>

### Value

Returns 0 if FUN succeeds and stops on error. In rpy2, it will throw rpy2.rinterface.RRuntimeError.

### Examples

``` r
## Not run:

# example with no optional arguments for running allgraphs
trygraphwrapper("/path/to/outputs/out.biom", "/path/to/outputs/", "/path/to/inputs/mapfile.txt", 
    "allgraphs")

# example with optional argument sampdepth and tsv file
trygraphwrapper("/path/to/outputs/OTU_table.txt", "/path/to/outputs/", "/path/to/inputs/mapfile.txt", 
    "allgraphs", sampdepth = 30000, tsvfile = TRUE)

# example of making heatmap with optional arguments
trygraphwrapper("/path/to/outputs/taxa_species.biom", "/path/to/outputs", "/path/to/inputs/mapfile.txt", 
    "morphheatmap", sampdepth = 30000, filter_level = 0.01, taxlevel = c("Family", 
        "seq"))
## End(Not run)
```

### Source

[graphs.R](../R/graphs.R)

Internal
========

`datavis16s-package`
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

### Source

[utilities.R](../R/utilities.R)

`gridCode`
----------

Format plotly grid code

### Description

Format data according to here: <https://plot.ly/export/>

### Usage

``` r
gridCode(data)
```

### Arguments

| Argument | Description                  |
|----------|------------------------------|
| `data`   | data to populate plotly grid |

### Value

list of 2 values:

-   `html` html for plotly export link
-   `javascript` js function for exporting data

### Source

[plotlyGrid.R](../R/plotlyGrid.R)

`highertax`
-----------

return tables at higher tax level

### Description

return tables at higher tax level

### Usage

``` r
highertax(amp, taxlevel)
```

### Arguments

| Argument   | Description                                   |
|------------|-----------------------------------------------|
| `amp`      | ampvis2 object                                |
| `taxlevel` | taxonomic level at which to sum up the counts |

### Value

ampvis2 object with otu table and taxa summed up to the taxlevel

### Source

[utilities.R](../R/utilities.R)

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

### Source

[utilities.R](../R/utilities.R)

`plotlyGrid`
------------

Add Plotly data export to Plotly graph

### Description

All functions create an output html plot with link which sends the data to a grid in the plotly chart studio.

`plotlyGrid` takes in a ggplot or plotly object and creates an output html plotly plot.

`htmlGrid` takes in an html tag object.

### Usage

``` r
plotlyGrid(pplot, filename, data = NULL, title = NULL, outlib = "lib")
htmlGrid(ht, filename, data, jquery = FALSE, title = NULL, outlib = "lib", styletags = NULL)
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
<td><code>ht</code></td>
<td>html tagList</td>
</tr>
<tr class="odd">
<td><code>jquery</code></td>
<td>should we load jquery</td>
</tr>
<tr class="even">
<td><code>styletags</code></td>
<td>html object with style tags for the tagList.</td>
</tr>
</tbody>
</table>

### Details

If jquery is needed, we use jquery-1.11.3 from the rmarkdown library. We also use rmarkdown's bootstrap-3.3.5 css to style the text elements.

### Value

html plot is saved to filename. external libraries are saved to outlib in same directory as filename.

### Source

[plotlyGrid.R](../R/plotlyGrid.R)

`print_ampvis2`
---------------

Print ampvis2 object summary

### Description

This is a copy of the internal ampvis2 function print.ampvis2. CRAN does not allow ':::' internal calling of function in package.

### Usage

``` r
print_ampvis2(data)
```

### Arguments

| Argument | Description    |
|----------|----------------|
| `data`   | ampvis2 object |

### Value

Prints summary stats about ampvis2 object

### Source

[utilities.R](../R/utilities.R)

`save_fillhtml`
---------------

Save an HTML object to a file

### Description

Save an HTML object to a file

### Usage

``` r
save_fillhtml(html, file, background = "white", libdir = "lib", bodystyle = "")
```

### Arguments

| Argument     | Description                       |
|--------------|-----------------------------------|
| `html`       | HTML content to print             |
| `file`       | File to write content to          |
| `background` | Background color for web page     |
| `libdir`     | Directory to copy dependencies to |
| `bodystyle`  | html style string                 |

### Value

save html to file

### Source

[plotlyGrid.R](../R/plotlyGrid.R)

`shortnames`
------------

shortnames for taxonomy

### Description

shortnames for taxonomy

### Usage

``` r
shortnames(taxtable)
```

### Arguments

| Argument   | Description                                       |
|------------|---------------------------------------------------|
| `taxtable` | taxonomy table object from ampvis2 object amp$tax |

### Value

data.frame taxonomy table object like ampvis2 amp$tax. taxonomy names are sanitized and formatted to be a bit nicer.

### Source

[utilities.R](../R/utilities.R)

`subsetamp`
-----------

Subset and rarefy OTU table.

### Description

Subset and/or rarefy OTU table.

### Usage

``` r
subsetamp(amp, sampdepth = NULL, rarefy = FALSE, ...)
```

### Arguments

| Argument    | Description                                      |
|-------------|--------------------------------------------------|
| `amp`       | ampvis2 object                                   |
| `sampdepth` | sampling depth. See details.                     |
| `rarefy`    | rarefy the OTU table in addition to subsetting   |
| `...`       | other parameters to pass to amp\_subset\_samples |

### Details

`sampdepth` will be used to filter out samples with fewer than this number of reads. If rarefy is TRUE, then it will also be used as the depth at which to subsample using vegan function rrarefy.

### Value

ampvis2 object

### Source

[graphs.R](../R/graphs.R)
