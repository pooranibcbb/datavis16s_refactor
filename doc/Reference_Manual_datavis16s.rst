
datavis16s R functions
======================

Poorani Subramanian

-  `DESCRIPTION <#description>`__
-  `Exported <#exported>`__

   -  `adivboxplot <#adivboxplot>`__
   -  `allgraphs <#allgraphs>`__
   -  `morphheatmap <#morphheatmap>`__
   -  `pcoaplot <#pcoaplot>`__
   -  `rarefactioncurve <#rarefactioncurve>`__
   -  `readindata <#readindata>`__
   -  `trygraphwrapper <#trygraphwrapper>`__

-  `Internal <#internal>`__

   -  `amp_rarecurvefix <#amp_rarecurvefix>`__
   -  `datavis16s-package <#datavis16s-package>`__
   -  `filterlowabund <#filterlowabund>`__
   -  `gridCode <#gridcode>`__
   -  `highertax <#highertax>`__
   -  `logoutput <#logoutput>`__
   -  `plotlyGrid <#plotlygrid>`__
   -  `print_ampvis2 <#print_ampvis2>`__
   -  `read_biom <#read_biom>`__
   -  `save_fillhtml <#save_fillhtml>`__
   -  `shortnames <#shortnames>`__
   -  `subsetamp <#subsetamp>`__

.. raw:: html

   <!-- toc -->

April 28, 2019

DESCRIPTION
-----------

::

   Package: datavis16s
   Title: Graphs for Nephele 16S Pipelines
   Version: 0.1.2
   Date: 2019-04-28 18:25:21 UTC
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
       rmarkdown,
       shiny,
       stringr,
       vegan
   Suggests:
       testthat
   Encoding: UTF-8
   LazyData: true
   RoxygenNote: 6.1.1

Exported
--------

``adivboxplot``
~~~~~~~~~~~~~~~

Alpha diversity boxplot

.. _description-1:

Description
^^^^^^^^^^^

Plots exploding boxplot of shannon diversity and Chao species richness. If sampling depth is NULL, rarefies OTU table to the minimum readcount of any sample. If this is low, then the plot will fail.

Usage
^^^^^

::

   adivboxplot(datafile, outdir, mapfile, amp = NULL, sampdepth = NULL, 
       colors = NULL, cats = NULL, filesuffix = NULL, ...)

Arguments
^^^^^^^^^

+-------------------------------+--------------------------------------+
| Argument                      | Description                          |
+===============================+======================================+
| ``datafile``                  | full path to input OTU file          |
+-------------------------------+--------------------------------------+
| ``outdir``                    | full path to output directory        |
+-------------------------------+--------------------------------------+
| ``mapfile``                   | full path to map file                |
+-------------------------------+--------------------------------------+
| ``amp``                       | ampvis2 object. may be specified     |
|                               | instead of mapfile and datafile      |
+-------------------------------+--------------------------------------+
| ``sampdepth``                 | sampling depth. see details.         |
+-------------------------------+--------------------------------------+
| ``colors``                    | colors to use for plots              |
+-------------------------------+--------------------------------------+
| ``cats``                      | categories/columns in mapping file   |
|                               | to use as groups. If NULL (default), |
|                               | will use all columns starting with   |
|                               | TreatmentGroup to (but not           |
|                               | including) Description               |
+-------------------------------+--------------------------------------+
| ``filesuffix``                | (Optional) suffix for output         |
|                               | filename                             |
+-------------------------------+--------------------------------------+
| ``...``                       | other parameters to pass to          |
|                               | `readindata <#readindata>`__         |
+-------------------------------+--------------------------------------+

Details
^^^^^^^

If ``sampdepth`` is NULL, the sampling depth is set to the size of the smallest sample.

Value
^^^^^

Save alpha diversity boxplots to outdir.

Source
^^^^^^

`graphs.R <https://github.niaid.nih.gov/bcbb/nephele2/tree/master/pipelines/datavis16s/R/graphs.R>`__

``allgraphs``
~~~~~~~~~~~~~

Pipeline function

.. _description-2:

Description
^^^^^^^^^^^

Make all 4 types of graphs

.. _usage-1:

Usage
^^^^^

::

   allgraphs(datafile, outdir, mapfile, sampdepth = 10000, ...)

.. _arguments-1:

Arguments
^^^^^^^^^

+-------------------------------+--------------------------------------+
| Argument                      | Description                          |
+===============================+======================================+
| ``datafile``                  | full path to input OTU file (biom or |
|                               | txt file see                         |
|                               | `readindata <#readindata>`__ for     |
|                               | format)                              |
+-------------------------------+--------------------------------------+
| ``outdir``                    | full path to output directory        |
+-------------------------------+--------------------------------------+
| ``mapfile``                   | full path to map file                |
+-------------------------------+--------------------------------------+
| ``sampdepth``                 | sampling depth. default: 10000       |
+-------------------------------+--------------------------------------+
| ``...``                       | other parameters to pass to          |
|                               | `readindata <#readindata>`__         |
+-------------------------------+--------------------------------------+

.. _value-1:

Value
^^^^^

graphs are saved to outdir. See `user doc <../doc/user_doc.md>`__.

This value is used to remove samples before for alpha diversity and PCoA plots. Also, to rarefy OTU table for the alpha diversity and Bray-Curtis distance PCoA.

.. _source-1:

Source
^^^^^^

`graphs.R <https://github.niaid.nih.gov/bcbb/nephele2/tree/master/pipelines/datavis16s/R/graphs.R>`__

``morphheatmap``
~~~~~~~~~~~~~~~~

Morpheus heatmap

.. _description-3:

Description
^^^^^^^^^^^

Creates heatmaps using Morpheus R API https://software.broadinstitute.org/morpheus/ . The heatmaps are made using relative abundances.

.. _usage-2:

Usage
^^^^^

::

   morphheatmap(datafile, outdir, mapfile, amp = NULL, sampdepth = NULL, 
       rarefy = FALSE, filter_level = NULL, taxlevel = c("seq"), 
       colors = NULL, rowAnnotations = NULL, force = FALSE, filesuffix = NULL, 
       ...)

.. _arguments-2:

Arguments
^^^^^^^^^

+-------------------------------+--------------------------------------+
| Argument                      | Description                          |
+===============================+======================================+
| ``datafile``                  | full path to input OTU file (biom or |
|                               | see `readindata <#readindata>`__ )   |
+-------------------------------+--------------------------------------+
| ``outdir``                    | full path to output directory        |
+-------------------------------+--------------------------------------+
| ``mapfile``                   | full path to mapping file            |
+-------------------------------+--------------------------------------+
| ``amp``                       | (Optional) ampvis2 object. may be    |
|                               | specified instead of mapfile and     |
|                               | datafile                             |
+-------------------------------+--------------------------------------+
| ``sampdepth``                 | sampling depth                       |
+-------------------------------+--------------------------------------+
| ``rarefy``                    | Logical. Rarefy the OTU table if     |
|                               | sampdepth is specified.              |
+-------------------------------+--------------------------------------+
| ``filter_level``              | minimum abundance to show in the     |
|                               | heatmap                              |
+-------------------------------+--------------------------------------+
| ``taxlevel``                  | vector of taxonomic levels to graph. |
|                               | must be subset of c(“Kingdom”,       |
|                               | “Phylum”, “Class”, “Order”,          |
|                               | “Family”, “Genus”, “Species”,        |
|                               | “seq”). See Details.                 |
+-------------------------------+--------------------------------------+
| ``colors``                    | (Optional) color vector - length     |
|                               | equal to number of TreatmentGroups   |
|                               | in mapfile                           |
+-------------------------------+--------------------------------------+
| ``filesuffix``                | (Optional) suffix for output         |
|                               | filename                             |
+-------------------------------+--------------------------------------+
| ``...``                       | parameters to pass to                |
|                               | `readindata <#readindata>`__         |
+-------------------------------+--------------------------------------+

.. _details-1:

Details
^^^^^^^

For the ``taxlevel`` parameter, each level is made into a separate heatmap. “seq” makes the heatmap with no collapsing of taxonomic levels.

.. _value-2:

Value
^^^^^

Saves heatmaps to outdir.

Examples
^^^^^^^^

::

   morphheatmap(datafile = "OTU_table.txt", outdir = "outputs/graphs", 
       mapfile = "mapfile.txt", sampdepth = 25000, taxlevel = c("Family", 
           "seq"), tsvfile = TRUE)

.. _source-2:

Source
^^^^^^

`graphs.R <https://github.niaid.nih.gov/bcbb/nephele2/tree/master/pipelines/datavis16s/R/graphs.R>`__

``pcoaplot``
~~~~~~~~~~~~

PCoA plots

.. _usage-3:

Usage
^^^^^

::

   pcoaplot(datafile, outdir, mapfile, amp = NULL, sampdepth = NULL, 
       distm = "binomial", filter_species = 0.1, rarefy = FALSE, 
       colors = NULL, filesuffix = NULL, ...)

.. _arguments-3:

Arguments
^^^^^^^^^

+-------------------------------+--------------------------------------+
| Argument                      | Description                          |
+===============================+======================================+
| ``datafile``                  | full path to input OTU file (biom or |
|                               | see `readindata <#readindata>`__ )   |
+-------------------------------+--------------------------------------+
| ``outdir``                    | full path to output directory        |
+-------------------------------+--------------------------------------+
| ``mapfile``                   | full path to map file                |
+-------------------------------+--------------------------------------+
| ``amp``                       | ampvis2 object. may be specified     |
|                               | instead of mapfile and datafile      |
+-------------------------------+--------------------------------------+
| ``sampdepth``                 | sampling depth                       |
+-------------------------------+--------------------------------------+
| ``distm``                     | distance measure for PCoA. any that  |
|                               | are supported by                     |
|                               | `amp_ordinate <https://madsalbertse% |
|                               | 20n.github.io/ampvis2/reference/amp_ |
|                               | or%20dinate.html>`__                 |
|                               | except for unifrac, wunifrac, and    |
|                               | none.                                |
+-------------------------------+--------------------------------------+
| ``filter_species``            | Remove low abundant OTU’s across all |
|                               | samples below this threshold in      |
|                               | percent. Setting this to 0 may       |
|                               | drastically increase computation     |
|                               | time.                                |
+-------------------------------+--------------------------------------+
| ``rarefy``                    | Logical. Rarefy the OTU table if     |
|                               | sampdepth is specified.              |
+-------------------------------+--------------------------------------+
| ``colors``                    | (Optional) color vector - length     |
|                               | equal to number of TreatmentGroups   |
|                               | in mapfile                           |
+-------------------------------+--------------------------------------+
| ``filesuffix``                | (Optional) suffix for output         |
|                               | filename                             |
+-------------------------------+--------------------------------------+
| ``...``                       | parameters to pass to                |
|                               | `readindata <#readindata>`__         |
+-------------------------------+--------------------------------------+

.. _value-3:

Value
^^^^^

Saves pcoa plots to outdir.

.. _source-3:

Source
^^^^^^

`graphs.R <https://github.niaid.nih.gov/bcbb/nephele2/tree/master/pipelines/datavis16s/R/graphs.R>`__

``rarefactioncurve``
~~~~~~~~~~~~~~~~~~~~

Make rarefaction curve graph

.. _usage-4:

Usage
^^^^^

::

   rarefactioncurve(datafile, outdir, mapfile, amp = NULL, colors = NULL, 
       cat = "TreatmentGroup", stepsize = 1000, ...)

.. _arguments-4:

Arguments
^^^^^^^^^

+-------------------------------+--------------------------------------+
| Argument                      | Description                          |
+===============================+======================================+
| ``datafile``                  | full path to input OTU file (biom or |
|                               | see `readindata <#readindata>`__ )   |
+-------------------------------+--------------------------------------+
| ``outdir``                    | full path to output directory        |
+-------------------------------+--------------------------------------+
| ``mapfile``                   | full path mapping file               |
+-------------------------------+--------------------------------------+
| ``amp``                       | (Optional) ampvis2 object. may be    |
|                               | specified instead of mapfile and     |
|                               | datafile                             |
+-------------------------------+--------------------------------------+
| ``colors``                    | (Optional) color vector - length     |
|                               | equal to number of TreatmentGroups   |
|                               | in mapfile                           |
+-------------------------------+--------------------------------------+
| ``cat``                       | Category/column in mapping file by   |
|                               | which to color the curves in the     |
|                               | graph. (default TreatmentGroup)      |
+-------------------------------+--------------------------------------+
| ``stepsize``                  | for rarefaction plotting.            |
+-------------------------------+--------------------------------------+
| ``...``                       | parameters to pass to                |
|                               | `readindata <#readindata>`__         |
+-------------------------------+--------------------------------------+

.. _value-4:

Value
^^^^^

Saves rarefaction curve plot to output directory.

.. _source-4:

Source
^^^^^^

`graphs.R <https://github.niaid.nih.gov/bcbb/nephele2/tree/master/pipelines/datavis16s/R/graphs.R>`__

``readindata``
~~~~~~~~~~~~~~

Read in data

.. _usage-5:

Usage
^^^^^

::

   readindata(datafile, mapfile, tsvfile = FALSE, mincount = 10)

.. _arguments-5:

Arguments
^^^^^^^^^

+-------------------------------+--------------------------------------+
| Argument                      | Description                          |
+===============================+======================================+
| ``datafile``                  | full path to input data file. must   |
|                               | be either biom file or tab delimited |
|                               | text file. See details.              |
+-------------------------------+--------------------------------------+
| ``mapfile``                   | full path to mapfile. must contain   |
|                               | SampleID, TreatmentGroup, and        |
|                               | Description columns                  |
+-------------------------------+--------------------------------------+
| ``tsvfile``                   | Logical. Is datafile a tab-delimited |
|                               | text file? See details.              |
+-------------------------------+--------------------------------------+
| ``mincount``                  | minimum number of reads              |
+-------------------------------+--------------------------------------+

.. _details-2:

Details
^^^^^^^

datafile may be either biom file or text file. If text file, it should have ampvis2 OTU table format https://madsalbertsen.github.io/ampvis2/reference/amp_load.html#the-otu-table . If the number of reads is less than mincount, the function will give an error, as we cannot make graphs with so few counts.

.. _value-5:

Value
^^^^^

ampvis2 object

.. _source-5:

Source
^^^^^^

`graphs.R <https://github.niaid.nih.gov/bcbb/nephele2/tree/master/pipelines/datavis16s/R/graphs.R>`__

``trygraphwrapper``
~~~~~~~~~~~~~~~~~~~

Wrapper for any graph function

.. _description-4:

Description
^^^^^^^^^^^

This is a wrapper for any of the graph functions meant to be called using rpy2 in python.

.. _usage-6:

Usage
^^^^^

::

   trygraphwrapper(datafile, outdir, mapfile, FUN, logfilename = "logfile.txt", 
       info = TRUE, tsvfile = FALSE, ...)

.. _arguments-6:

Arguments
^^^^^^^^^

+-------------------------------+--------------------------------------+
| Argument                      | Description                          |
+===============================+======================================+
| ``datafile``                  | full path to input OTU file (biom or |
|                               | txt, see                             |
|                               | `readindata <#readindata>`__ for     |
|                               | format of txt file)                  |
+-------------------------------+--------------------------------------+
| ``outdir``                    | output directory for graphs          |
+-------------------------------+--------------------------------------+
| ``mapfile``                   | full path to map file                |
+-------------------------------+--------------------------------------+
| ``FUN``                       | character string. name of function   |
|                               | you would like to run. can be actual |
|                               | function object if run from R        |
+-------------------------------+--------------------------------------+
| ``logfilename``               | logfilename                          |
+-------------------------------+--------------------------------------+
| ``info``                      | print sessionInfo to logfile         |
+-------------------------------+--------------------------------------+
| ``tsvfile``                   | Is datafile a tab-delimited text     |
|                               | file? Default FALSE                  |
+-------------------------------+--------------------------------------+
| ``...``                       | parameters needed to pass to FUN     |
+-------------------------------+--------------------------------------+

.. _value-6:

Value
^^^^^

Returns 0 if FUN succeeds and stops on error. In rpy2, it will throw rpy2.rinterface.RRuntimeError.

.. _examples-1:

Examples
^^^^^^^^

::

   # example with no optional arguments for running allgraphs
   trygraphwrapper("/path/to/outputs/out.biom", "/path/to/outputs/", 
       "/path/to/inputs/mapfile.txt", "allgraphs")

   # example with sampdepth argument for running allgraphs
   trygraphwrapper("/path/to/outputs/out.biom", "/path/to/outputs/", 
       "/path/to/inputs/mapfile.txt", "allgraphs", sampdepth = 30000)


   # example with optional argument sampdepth and tsv file
   trygraphwrapper("/path/to/outputs/OTU_table.txt", "/path/to/outputs/", 
       "/path/to/inputs/mapfile.txt", "allgraphs", sampdepth = 30000, 
       tsvfile = TRUE)

   # example of making heatmap with optional arguments
   trygraphwrapper("/path/to/outputs/taxa_species.biom", "/path/to/outputs", 
       "/path/to/inputs/mapfile.txt", "morphheatmap", sampdepth = 30000, 
       filter_level = 0.01, taxlevel = c("Family", "seq"))

.. _source-6:

Source
^^^^^^

`graphs.R <https://github.niaid.nih.gov/bcbb/nephele2/tree/master/pipelines/datavis16s/R/graphs.R>`__

Internal
--------

``amp_rarecurvefix``
~~~~~~~~~~~~~~~~~~~~

Rarefaction curve

.. _description-5:

Description
^^^^^^^^^^^

This function replaces the ampvis2 function amp_rarecurve to fix subsampling labeling bug in vegan

.. _usage-7:

Usage
^^^^^

::

   amp_rarecurvefix(data, stepsize = 1000, color_by = NULL)

.. _arguments-7:

Arguments
^^^^^^^^^

+-------------------------------+--------------------------------------+
| Argument                      | Description                          |
+===============================+======================================+
| ``data``                      | (required) Data list as loaded with  |
|                               | amp_load.                            |
+-------------------------------+--------------------------------------+
| ``stepsize``                  | Step size for the curves. Lower is   |
|                               | prettier but takes more time to      |
|                               | generate. (default: 1000)            |
+-------------------------------+--------------------------------------+
| ``color_by``                  | Color curves by a variable in the    |
|                               | metadata.                            |
+-------------------------------+--------------------------------------+

.. _value-7:

Value
^^^^^

A ggplot2 object.

.. _source-7:

Source
^^^^^^

`utilities.R <https://github.niaid.nih.gov/bcbb/nephele2/tree/master/pipelines/datavis16s/R/utilities.R>`__

``datavis16s-package``
~~~~~~~~~~~~~~~~~~~~~~

dataviz16s: A package for Nephele 16S pipeline visualization

``filterlowabund``
~~~~~~~~~~~~~~~~~~

Filter low abundant taxa

.. _usage-8:

Usage
^^^^^

::

   filterlowabund(amp, level = 0.01, persamp = 0, abs = FALSE, toptaxa = NULL)

.. _arguments-8:

Arguments
^^^^^^^^^

+-------------------------------+--------------------------------------+
| Argument                      | Description                          |
+===============================+======================================+
| ``amp``                       | ampvis2 object                       |
+-------------------------------+--------------------------------------+
| ``level``                     | level at which to filter             |
+-------------------------------+--------------------------------------+
| ``persamp``                   | percent of samples which must have   |
|                               | taxa in common                       |
+-------------------------------+--------------------------------------+
| ``abs``                       | is level an absolute count? if       |
|                               | false, will use level as relative    |
|                               | percent.                             |
+-------------------------------+--------------------------------------+
| ``toptaxa``                   | number of seqvar to include sorted   |
|                               | by max count across all samples; if  |
|                               | NULL all will be included.           |
+-------------------------------+--------------------------------------+

.. _value-8:

Value
^^^^^

filtered ampvis2 object

.. _source-8:

Source
^^^^^^

`utilities.R <https://github.niaid.nih.gov/bcbb/nephele2/tree/master/pipelines/datavis16s/R/utilities.R>`__

``gridCode``
~~~~~~~~~~~~

Format plotly grid code

.. _description-6:

Description
^^^^^^^^^^^

Format data according to here: https://plot.ly/export/

.. _usage-9:

Usage
^^^^^

::

   gridCode(data)

.. _arguments-9:

Arguments
^^^^^^^^^

+----------+------------------------------+
| Argument | Description                  |
+==========+==============================+
| ``data`` | data to populate plotly grid |
+----------+------------------------------+

.. _value-9:

Value
^^^^^

list of 2 values:

-  ``html`` html for plotly export link
-  ``javascript`` js function for exporting data

.. _source-9:

Source
^^^^^^

`plotlyGrid.R <https://github.niaid.nih.gov/bcbb/nephele2/tree/master/pipelines/datavis16s/R/plotlyGrid.R>`__

``highertax``
~~~~~~~~~~~~~

return tables at higher tax level

.. _usage-10:

Usage
^^^^^

::

   highertax(amp, taxlevel)

.. _arguments-10:

Arguments
^^^^^^^^^

+------------+-----------------------------------------------+
| Argument   | Description                                   |
+============+===============================================+
| ``amp``    | ampvis2 object                                |
+------------+-----------------------------------------------+
| ``taxlevel | taxonomic level at which to sum up the counts |
| ``         |                                               |
+------------+-----------------------------------------------+

.. _value-10:

Value
^^^^^

ampvis2 object with otu table and taxa summed up to the taxlevel

.. _source-10:

Source
^^^^^^

`utilities.R <https://github.niaid.nih.gov/bcbb/nephele2/tree/master/pipelines/datavis16s/R/utilities.R>`__

``logoutput``
~~~~~~~~~~~~~

write log output

.. _description-7:

Description
^^^^^^^^^^^

Prints time along with log message.

.. _usage-11:

Usage
^^^^^

::

   logoutput(c, bline = 0, aline = 0, type = NULL)

.. _arguments-11:

Arguments
^^^^^^^^^

+----------+-------------------------------------------------------+
| Argument | Description                                           |
+==========+=======================================================+
| ``c``    | String. Log message/command to print.                 |
+----------+-------------------------------------------------------+
| ``bline` | Number of blank lines to precede output.              |
| `        |                                                       |
+----------+-------------------------------------------------------+
| ``aline` | Number of blank lines to follow output.               |
| `        |                                                       |
+----------+-------------------------------------------------------+
| ``type`` | String. Must be one of “WARNING”, or “ERROR” or NULL. |
+----------+-------------------------------------------------------+

.. _source-11:

Source
^^^^^^

`utilities.R <https://github.niaid.nih.gov/bcbb/nephele2/tree/master/pipelines/datavis16s/R/utilities.R>`__

``plotlyGrid``
~~~~~~~~~~~~~~

Add Plotly data export to Plotly graph

.. _description-8:

Description
^^^^^^^^^^^

All functions create an output html plot with link which sends the data to a grid in the plotly chart studio.

``plotlyGrid`` takes in a ggplot or plotly object and creates an output html plotly plot.

``htmlGrid`` takes in an html tag object.

.. _usage-12:

Usage
^^^^^

::

   plotlyGrid(pplot, filename, data = NULL, title = NULL, outlib = "lib")
   htmlGrid(ht, filename, data, jquery = FALSE, title = NULL, outlib = "lib", 
       styletags = NULL)

.. _arguments-12:

Arguments
^^^^^^^^^

+-------------------------------+--------------------------------------+
| Argument                      | Description                          |
+===============================+======================================+
| ``pplot``                     | plotly or ggplot object              |
+-------------------------------+--------------------------------------+
| ``filename``                  | output filename (fullpath)           |
+-------------------------------+--------------------------------------+
| ``data``                      | data frame to export to plotly grid  |
|                               | (optional for plotlyGrid)            |
+-------------------------------+--------------------------------------+
| ``title``                     | title of html page                   |
+-------------------------------+--------------------------------------+
| ``outlib``                    | (Optional) name of external lib      |
|                               | directory for non-selfcontained      |
|                               | html. Useful for multiple graphs     |
|                               | sharing the same lib.                |
+-------------------------------+--------------------------------------+
| ``ht``                        | html tagList                         |
+-------------------------------+--------------------------------------+
| ``jquery``                    | should we load jquery                |
+-------------------------------+--------------------------------------+
| ``styletags``                 | html object with style tags for the  |
|                               | tagList.                             |
+-------------------------------+--------------------------------------+

.. _details-3:

Details
^^^^^^^

If jquery is needed, we use jquery-1.11.3 from the rmarkdown library. We also use shiny’s bootstrap-3.3.7 css to style the text elements.

.. _value-11:

Value
^^^^^

html plot is saved to filename. external libraries are saved to outlib in same directory as filename. Invisibly returns the plotly html widget.

.. _source-12:

Source
^^^^^^

`plotlyGrid.R <https://github.niaid.nih.gov/bcbb/nephele2/tree/master/pipelines/datavis16s/R/plotlyGrid.R>`__

``print_ampvis2``
~~~~~~~~~~~~~~~~~

Print ampvis2 object summary

.. _description-9:

Description
^^^^^^^^^^^

This is a copy of the internal ampvis2 function print.ampvis2. CRAN does not allow ‘:::’ internal calling of function in package.

.. _usage-13:

Usage
^^^^^

::

   print_ampvis2(data)

.. _arguments-13:

Arguments
^^^^^^^^^

+----------+----------------+
| Argument | Description    |
+==========+================+
| ``data`` | ampvis2 object |
+----------+----------------+

.. _value-12:

Value
^^^^^

Prints summary stats about ampvis2 object

.. _source-13:

Source
^^^^^^

`utilities.R <https://github.niaid.nih.gov/bcbb/nephele2/tree/master/pipelines/datavis16s/R/utilities.R>`__

``read_biom``
~~~~~~~~~~~~~

biomformat read_biom

.. _description-10:

Description
^^^^^^^^^^^

This function replaces the biomformat function read_biom to deal with reading in crappy hdf5 biom file.

.. _usage-14:

Usage
^^^^^

::

   read_biom(biom_file)

.. _arguments-14:

Arguments
^^^^^^^^^

+-------------+-------------+
| Argument    | Description |
+=============+=============+
| ``biom_file |             |
| ``          |             |
+-------------+-------------+

.. _value-13:

Value
^^^^^

biom object

``save_fillhtml``
~~~~~~~~~~~~~~~~~

Save an HTML object to a file

.. _usage-15:

Usage
^^^^^

::

   save_fillhtml(html, file, background = "white", libdir = "lib", 
       bodystyle = "")

.. _arguments-15:

Arguments
^^^^^^^^^

+--------------+-----------------------------------+
| Argument     | Description                       |
+==============+===================================+
| ``html``     | HTML content to print             |
+--------------+-----------------------------------+
| ``file``     | File to write content to          |
+--------------+-----------------------------------+
| ``background | Background color for web page     |
| ``           |                                   |
+--------------+-----------------------------------+
| ``libdir``   | Directory to copy dependencies to |
+--------------+-----------------------------------+
| ``bodystyle` | html style string                 |
| `            |                                   |
+--------------+-----------------------------------+

.. _value-14:

Value
^^^^^

save html to file

.. _source-14:

Source
^^^^^^

`plotlyGrid.R <https://github.niaid.nih.gov/bcbb/nephele2/tree/master/pipelines/datavis16s/R/plotlyGrid.R>`__

``shortnames``
~~~~~~~~~~~~~~

shortnames for taxonomy

.. _usage-16:

Usage
^^^^^

::

   shortnames(taxtable)

.. _arguments-16:

Arguments
^^^^^^^^^

+------------+---------------------------------------------------+
| Argument   | Description                                       |
+============+===================================================+
| ``taxtable | taxonomy table object from ampvis2 object amp$tax |
| ``         |                                                   |
+------------+---------------------------------------------------+

.. _value-15:

Value
^^^^^

data.frame taxonomy table object like ampvis2 amp$tax. taxonomy names are sanitized and formatted to be a bit nicer.

.. _source-15:

Source
^^^^^^

`utilities.R <https://github.niaid.nih.gov/bcbb/nephele2/tree/master/pipelines/datavis16s/R/utilities.R>`__

``subsetamp``
~~~~~~~~~~~~~

Subset and rarefy OTU table.

.. _description-11:

Description
^^^^^^^^^^^

Subset and/or rarefy OTU table.

.. _usage-17:

Usage
^^^^^

::

   subsetamp(amp, sampdepth = NULL, rarefy = FALSE, printsummary = T, 
       outdir = NULL, ...)

.. _arguments-17:

Arguments
^^^^^^^^^

+-------------------------------+--------------------------------------+
| Argument                      | Description                          |
+===============================+======================================+
| ``amp``                       | ampvis2 object                       |
+-------------------------------+--------------------------------------+
| ``sampdepth``                 | sampling depth. See details.         |
+-------------------------------+--------------------------------------+
| ``rarefy``                    | rarefy the OTU table in addition to  |
|                               | subsetting                           |
+-------------------------------+--------------------------------------+
| ``printsummary``              | Logical. print ampvis2 summary of    |
|                               | OTU table                            |
+-------------------------------+--------------------------------------+
| ``outdir``                    | Output directory. If not null, and   |
|                               | samples are removed from amp, the    |
|                               | sample names will be output to       |
|                               | outdir/samples_being_ignored.txt     |
+-------------------------------+--------------------------------------+
| ``...``                       | other parameters to pass to          |
|                               | amp_subset_samples                   |
+-------------------------------+--------------------------------------+

.. _details-4:

Details
^^^^^^^

``sampdepth`` will be used to filter out samples with fewer than this number of reads. If rarefy is TRUE, then it will also be used as the depth at which to subsample using vegan function rrarefy.

.. _value-16:

Value
^^^^^

ampvis2 object

.. _source-16:

Source
^^^^^^

`graphs.R <https://github.niaid.nih.gov/bcbb/nephele2/tree/master/pipelines/datavis16s/R/graphs.R>`__
