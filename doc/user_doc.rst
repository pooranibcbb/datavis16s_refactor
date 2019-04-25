
16S Visualization Pipeline
==========================

-  `ampvis2 and Plotly <#ampvis2-and-plotly>`__
-  `Plots <#plots>`__
-  `Output Files <#output-files>`__
-  `Tools and References <#tools-and-references>`__

ampvis2 and Plotly
------------------

Nephele uses the `ampvis2 R package <https://madsalbertsen.github.io/ampvis2/>`__ v2.3.2 for statistical computation. We also make use of the `Plotly R interface <https://plot.ly/r/>`__ for the `plotly.js <https://plot.ly>`__ charting library. The plots can be minimally edited interactively. However, they also have a link to export the data to the `Plotly Chart Studio <https://plot.ly/online-chart-maker/>`__ which allows for `making a variety of charts <https://help.plot.ly/tutorials/>`__. We have a tutorial for making simple edits to the plots here.

Plots
-----

Rarefaction Curve
~~~~~~~~~~~~~~~~~

The rarefaction curves are made with the `amp_rarecurve <https://madsalbertsen.github.io/ampvis2/reference/amp_rarecurve.html>`__ function. The table is written to *rarecurve.txt* and the plot to *rarecurve.html*.

.. code:: r

   rarecurve <- amp_rarecurve(amp, color_by = "TreatmentGroup")

Heatmap
~~~~~~~

The interactive heatmap is implemented using the `morpheus R API <https://github.com/cmap/morpheus.R>`__ developed at the Broad Institute. `Documentation <https://software.broadinstitute.org/morpheus/documentation.html>`__ for how to use the heatmap can be found on the `morpheus website <https://software.broadinstitute.org/morpheus/>`__.

The heatmap is made from the raw OTU table which is then normalized to represent the relative abundances using ``amp_subset_samples`` before the heatmap is made with morpheus (*seq_heatmap.html*).

.. code:: r

   amptax <- amp_subset_samples(amp, normalise = TRUE)
   heatmap <- morpheus(amp$abund, columns = columns, rows = rows, 
       columnColorModel = list(type = as.list(colors)), 
       colorScheme = list(scalingMode = "fixed", stepped = FALSE), 
       columnAnnotations = amptax$metadata, rowAnnotations = amptax$tax)

PCoA
~~~~

Principal coordinates analysis using binomial and Bray-Curtis distances is carried out using `amp_ordinate <https://madsalbertsen.github.io/ampvis2/reference/amp_ordinate.html>`__. Samples which fall below the specified sampling depth are removed from the OTU table using `amp_subset_samples <https://madsalbertsen.github.io/ampvis2/reference/amp_subset_samples.html>`__ before the distance measures are computed. The names of samples that are removed are output to *samples_being_ignored.txt*.

The binomial distance is able to handle varying sample sizes. However, for the Bray-Curtis distance, the OTU table is rarefied to the sampling depth using `rrarefy <https://www.rdocumentation.org/packages/vegan/versions/2.4-2/topics/rarefy>`__ from the vegan R package. The table of the rarefied counts is saved as *rarefied_OTU_table.txt*. The coordinates from the plots are written to *pcoa_binomial.txt* and *pcoa_bray.txt* and the plots to *pcoa_binomial.html* and *pcoa_bray.html*. At least 3 samples are needed for these plots.

.. code:: r

   amp <- amp_subset_samples(amp, minreads = sampdepth)
   pcoa_binomial <- amp_ordinate(amp, filter_species = 0.01, type = "PCOA", 
       distmeasure = "binomial", sample_color_by = "TreatmentGroup", 
       detailed_output = TRUE, transform = "none")
   otu <- rrarefy(t(amp$abund), sampdepth)
   amp$abund <- t(otu)
   pcoa_bray <- amp_ordinate(amp, filter_species = 0.01, type = "PCOA", 
       distmeasure = "bray", sample_color_by = "TreatmentGroup", 
       detailed_output = TRUE, transform = "none")

Alpha diversity
~~~~~~~~~~~~~~~

The Shannon diversity and Chao species richness are computed using `amp_alphadiv <https://madsalbertsen.github.io/ampvis2/reference/amp_alphadiv.html>`__. The rarefied counts are used for this computation. The diversity values are saved in *alphadiv.txt*, and boxplots are output to *alphadiv.html*. At least 3 samples are needed to produce these plots.

.. code:: r

   alphadiv <- amp_alphadiv(amp, measure = "shannon", richness = TRUE, rarefy = sampdepth)

Output Files
------------

Complete descriptions of the output files can be found in the `Plots section above <#plots>`__. To learn how to edit the plots, see the visualization tutorial.

-  *rarecurve.html*: rarefaction curve plot
-  *rarecurve.txt*: tabular data used to make the rarefaction curve plot
-  *seq_heatmap.html*: heatmap of OTU/sequence variant abundances
-  *samples_being_ignored.txt*: list of samples removed from the analysis
-  *pcoa_*.html*: PCoA plots
-  *pcoa_*.txt*: tabular data used to make the PCoA plots
-  *rarefied_OTU_table.txt*: rarefied OTU table used for Bray-Curtis PCoA and alpha diversity plots
-  *alphadiv.html*: alpha diversity boxplots
-  *alphadiv.txt*: tabular data used to make the alpha diversity plots

Tools and References
--------------------

.. raw:: html

   <p>

M A, SM K, AS Z, RH K and PH N (2015). “Back to Basics - The Influence of DNA Extraction and Primer Choice on Phylogenetic Analysis of Activated Sludge Communities.” PLoS ONE, 10(7), pp. e0132783. http://dx.plos.org/10.1371/journal.pone.0132783.

.. raw:: html

   </p>

.. raw:: html

   <p>

Gould J (2018). morpheus: Interactive heat maps using ‘morpheus.js’ and ‘htmlwidgets’. R package version 0.1.1.1, https://github.com/cmap/morpheus.R.

.. raw:: html

   </p>

.. raw:: html

   <p>

Sievert C, Parmer C, Hocking T, Chamberlain S, Ram K, Corvellec M and Despouy P (2017). plotly: Create Interactive Web Graphics via ‘plotly.js’. R package version 4.7.1, https://CRAN.R-project.org/package=plotly.

.. raw:: html

   </p>

.. raw:: html

   <p>

McMurdie PJ and Paulson JN (2016). biomformat: An interface package for the BIOM file format. https://github.com/joey711/biomformat/.

.. raw:: html

   </p>
