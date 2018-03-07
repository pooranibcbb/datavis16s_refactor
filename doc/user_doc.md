16S Visualization Pipeline
================

-   [ampvis2 and Plotly](#ampvis2-and-plotly)
-   [Plots](#plots)
    -   [Rarefaction Curve](#rarefaction-curve)
    -   [PCoA](#pcoa)
    -   [Alpha diversity](#alpha-diversity)
    -   [Heatmap](#heatmap)
-   [Tools and References](#tools-and-references)

ampvis2 and Plotly
------------------

Nephele uses the [ampvis2 R package](https://madsalbertsen.github.io/ampvis2/) for statistical computation. We also make use of the [Plotly R interface](https://plot.ly/r/) for the [plotly.js](https://plot.ly) charting library. The plots can be minimally edited interactively. However, they also have a link to export the data to the [Plotly Chart Studio](https://plot.ly/online-chart-maker/) which allows for [making a variety of charts](https://help.plot.ly/tutorials/).

Plots
-----

### Rarefaction Curve

The rarefaction curves are made with the [amp\_rarecurve](https://madsalbertsen.github.io/ampvis2/reference/amp_rarecurve.html) function. The table is written to *rarecurve.txt* and the plot to *rarecurve.html*.

``` r
rarecurve <- amp_rarecurve(amp, color_by = "TreatmentGroup")
```

### PCoA

Principal coordinates analysis using binomial and Bray-Curtis distances is carried out using [amp\_ordinate](https://madsalbertsen.github.io/ampvis2/reference/amp_ordinate.html). Samples which fall below the specified sampling depth are removed from the OTU table using [amp\_subset\_samples](https://madsalbertsen.github.io/ampvis2/reference/amp_subset_samples.html) before the distance measures are computed. The binomial distance is able to handle varying sample sizes. However, for the Bray-Curtis PCoA, the OTU table is rarefied to the sampling depth using [rrarefy](https://www.rdocumentation.org/packages/vegan/versions/2.4-2/topics/rarefy) from the vegan R package. At least 3 samples are needed in the OTU table for the plot to be generated. The tables are written to *pcoa\_binomial.txt* and *pcoa\_bray.txt* and the plots to *pcoa\_binomial.html* and *pcoa\_bray.html*.

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

The Shannon diversity and Chao species richness are computed using [amp\_alphadiv](https://madsalbertsen.github.io/ampvis2/reference/amp_alphadiv.html). Samples which fall below the specified sampling depth are removed, and the OTU table is rarefied to the sampling depth before the diversity computation. The table is written to *alphadiv.txt*, and boxplots are output to *alphadiv.html*. At least 3 samples are needed to produce these plots.

``` r
alphadiv <- amp_alphadiv(amp, measure = "shannon", richness = TRUE, rarefy = sampdepth)
```

### Heatmap

The interactive heatmap is implemented using the [morpheus R API](https://github.com/cmap/morpheus.R) developed at the Broad Institute. A [tutorial](https://software.broadinstitute.org/morpheus/tutorial.html) for how to use the heatmap can be found on the [morpheus website](https://software.broadinstitute.org/morpheus/).

The OTU table is first normalized to represent the relative abundances using amp\_subset\_samples before the heatmap is made with morpheus. In order for the heatmap to be generated, the OTU table must be at least 2x2. The heatmaps are made from the raw OTU table (*seq\_heatmap.html*) and also at the family level (*Family\_heatmap.html*).

``` r
amp <- amp_subset_samples(amp, normalise = TRUE)
heatmap <- morpheus(amptax$abund, colorScheme = list(scalingMode = "fixed", values = values, 
    colors = colors, stepped = FALSE), columnAnnotations = amptax$metadata[, tg:desc])
```

Tools and References
--------------------

<p>
M A, SM K, AS Z, RH K and PH N (2015). “Back to Basics - The Influence of DNA Extraction and Primer Choice on Phylogenetic Analysis of Activated Sludge Communities.” <em>PLoS ONE</em>, <b>10</b>(7), pp. e0132783. <a href="http://dx.plos.org/10.1371/journal.pone.0132783">http://dx.plos.org/10.1371/journal.pone.0132783</a>.
</p>
    ## Warning in citation("morpheus"): no date field in DESCRIPTION file of
    ## package 'morpheus'

    ## Warning in citation("morpheus"): could not determine year for 'morpheus'
    ## from package DESCRIPTION file

<p>
person) (????). <em>morpheus: Interactive heat maps using 'morpheus.js' and 'htmlwidgets'</em>. R package version 0.1.1.1, <a href="https://github.com/cmap/morpheus.R">https://github.com/cmap/morpheus.R</a>.
</p>
<p>
Sievert C, Parmer C, Hocking T, Chamberlain S, Ram K, Corvellec M and Despouy P (2017). <em>plotly: Create Interactive Web Graphics via 'plotly.js'</em>. R package version 4.7.1, <a href="https://CRAN.R-project.org/package=plotly">https://CRAN.R-project.org/package=plotly</a>.
</p>
<p>
McMurdie PJ and Paulson JN (2016). <em>biomformat: An interface package for the BIOM file format</em>. <a href="https://github.com/joey711/biomformat/">https://github.com/joey711/biomformat/</a>.
</p>
