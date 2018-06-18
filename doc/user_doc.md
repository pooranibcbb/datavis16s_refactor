16S Visualization Pipeline
================

-   [ampvis2 and Plotly](#ampvis2-and-plotly)
-   [Plots](#plots)
-   [Output Files](#output-files)
-   [Tools and References](#tools-and-references)

ampvis2 and Plotly
------------------

Nephele uses the <a href="https://madsalbertsen.github.io/ampvis2/" target="_blank" rel="noopener noreferrer">ampvis2 R package</a> v2.3.2 for statistical computation. We also make use of the <a href="https://plot.ly/r/" target="_blank" rel="noopener noreferrer">Plotly R interface</a> for the <a href="https://plot.ly" target="_blank" rel="noopener noreferrer">plotly.js</a> charting library. The plots can be minimally edited interactively. However, they also have a link to export the data to the <a href="https://plot.ly/online-chart-maker/" target="_blank" rel="noopener noreferrer">Plotly Chart Studio</a> which allows for <a href="https://help.plot.ly/tutorials/" target="_blank" rel="noopener noreferrer">making a variety of charts</a>. We have a tutorial for <a href="{{ url_for('show_tutorials') }}">making simple edits to the plots here</a>.

Plots
-----

### Rarefaction Curve

The rarefaction curves are made with the <a href="https://madsalbertsen.github.io/ampvis2/reference/amp_rarecurve.html" target="_blank" rel="noopener noreferrer">amp_rarecurve</a> function. The table is written to *rarecurve.txt* and the plot to *rarecurve.html*.

``` r
rarecurve <- amp_rarecurve(amp, color_by = "TreatmentGroup")
```

### PCoA

Principal coordinates analysis using binomial and Bray-Curtis distances is carried out using <a href="https://madsalbertsen.github.io/ampvis2/reference/amp_ordinate.html" target="_blank" rel="noopener noreferrer">amp_ordinate</a>. Samples which fall below the specified sampling depth are removed from the OTU table using <a href="https://madsalbertsen.github.io/ampvis2/reference/amp_subset_samples.html" target="_blank" rel="noopener noreferrer">amp_subset_samples</a> before the distance measures are computed. The names of samples that are removed are output to *samples\_being\_ignored.txt*.

The binomial distance is able to handle varying sample sizes. However, for the Bray-Curtis distance, the OTU table is rarefied to the sampling depth using <a href="https://www.rdocumentation.org/packages/vegan/versions/2.4-2/topics/rarefy" target="_blank" rel="noopener noreferrer">rrarefy</a> from the vegan R package. At least 3 samples are needed in the OTU table for the plot to be generated. The tables are written to *pcoa\_binomial.txt* and *pcoa\_bray.txt* and the plots to *pcoa\_binomial.html* and *pcoa\_bray.html*.

``` r
amp <- amp_subset_samples(amp, minreads = sampdepth)
pcoa_binomial <- amp_ordinate(amp, filter_species = 0.01, type = "PCOA", distmeasure = "binomial", 
    sample_color_by = "TreatmentGroup", detailed_output = TRUE, transform = "none")
otu <- rrarefy(t(amp$abund), sampdepth)
amp$abund <- t(otu)
pcoa_bray <- amp_ordinate(amp, filter_species = 0.01, type = "PCOA", distmeasure = "bray", 
    sample_color_by = "TreatmentGroup", detailed_output = TRUE, transform = "none")
```

### Alpha diversity

The Shannon diversity and Chao species richness are computed using <a href="https://madsalbertsen.github.io/ampvis2/reference/amp_alphadiv.html" target="_blank" rel="noopener noreferrer">amp_alphadiv</a>. Samples which fall below the specified sampling depth are removed, and the OTU table is rarefied to the sampling depth before the diversity computation. The table is written to *alphadiv.txt*, and boxplots are output to *alphadiv.html*. At least 3 samples are needed to produce these plots.

``` r
alphadiv <- amp_alphadiv(amp, measure = "shannon", richness = TRUE, rarefy = sampdepth)
```

### Heatmap

The interactive heatmap is implemented using the <a href="https://github.com/cmap/morpheus.R" target="_blank" rel="noopener noreferrer">morpheus R API</a> developed at the Broad Institute. <a href="https://software.broadinstitute.org/morpheus/documentation.html" target="_blank" rel="noopener noreferrer">Documentation</a> for how to use the heatmap can be found on the <a href="https://software.broadinstitute.org/morpheus/" target="_blank" rel="noopener noreferrer">morpheus website</a>.

The OTU table is first normalized to represent the relative abundances using amp\_subset\_samples before the heatmap is made with morpheus. In order for the heatmap to be generated, the OTU table must be at least 2x2. The heatmap is made from the raw OTU table (*seq\_heatmap.html*).

``` r
amptax <- amp_subset_samples(amp, normalise = TRUE)
heatmap <- morpheus(amp$abund, columns = columns, columnAnnotations = amptax$metadata, 
    columnColorModel = list(type = as.list(colors)), colorScheme = list(scalingMode = "fixed", 
        stepped = FALSE), rowAnnotations = amptax$tax, rows = rows)
```

Output Files
------------

Complete descriptions of the output files can be found in the [Plots section above](#plots). To learn how to edit the plots, see the <a href="{{ url_for('show_tutorials') }}">visualization tutorial</a>.

-   *rarecurve.html*: rarefaction curve plot
-   *rarecurve.txt*: tabular data used to make the rarefaction curve plot
-   *samples\_being\_ignored.txt*: list of samples removed from the analysis
-   *pcoa\_\*.html*: PCoA plots
-   *pcoa\_\*.txt*: tabular data used to make the PCoA plots
-   *alphadiv.html*: alpha diversity boxplots
-   *alphadiv.txt*: tabular data used to make the alpha diversity plots
-   *seq\_heatmap.html*: heatmap of OTU/sequence variant abundances

Tools and References
--------------------

<p>
M A, SM K, AS Z, RH K and PH N (2015). "Back to Basics - The Influence of DNA Extraction and Primer Choice on Phylogenetic Analysis of Activated Sludge Communities." <em>PLoS ONE</em>, <b>10</b>(7), pp. e0132783. <a href="http://dx.plos.org/10.1371/journal.pone.0132783" target="_blank" rel="noopener noreferrer">http://dx.plos.org/10.1371/journal.pone.0132783</a>.
</p>
<p>
Gould J (2018). <em>morpheus: Interactive heat maps using 'morpheus.js' and 'htmlwidgets'</em>. R package version 0.1.1.1, <a href="https://github.com/cmap/morpheus.R" target="_blank" rel="noopener noreferrer">https://github.com/cmap/morpheus.R</a>.
</p>
<p>
Sievert C, Parmer C, Hocking T, Chamberlain S, Ram K, Corvellec M and Despouy P (2017). <em>plotly: Create Interactive Web Graphics via 'plotly.js'</em>. R package version 4.7.1, <a href="https://CRAN.R-project.org/package=plotly" target="_blank" rel="noopener noreferrer">https://CRAN.R-project.org/package=plotly</a>.
</p>
<p>
McMurdie PJ and Paulson JN (2016). <em>biomformat: An interface package for the BIOM file format</em>. <a href="https://github.com/joey711/biomformat/" target="_blank" rel="noopener noreferrer">https://github.com/joey711/biomformat/</a>.
</p>
