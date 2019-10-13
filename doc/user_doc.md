User docs
================

-   [ampvis2 and Plotly](#ampvis2-and-plotly)
-   [Plots](#plots)
-   [Output Files](#output-files)
-   [Tools and References](#tools-and-references)

## ampvis2 and Plotly

Nephele uses the [ampvis2 R package](https://madsalbertsen.github.io/ampvis2/) v2.3.2 for statistical computation. We also make use of the [Plotly R interface](https://plot.ly/r/) for the [plotly.js](https://plot.ly) charting library. The plots can be minimally edited interactively. However, they also have a link to export the data to the [Plotly Chart Studio](https://plot.ly/online-chart-maker/) which allows for [making a variety of charts](https://help.plot.ly/tutorials/). We have a tutorial for <a href="{{ url_for('show_tutorials') }}">making simple edits to the plots here</a>.

## Plots

### Rarefaction Curve

The rarefaction curves are made with the [amp\_rarecurve](https://madsalbertsen.github.io/ampvis2/reference/amp_rarecurve.html) function. The table is written to *rarecurve.txt* and the plot to *rarecurve.html*.

``` r
rarecurve <- amp_rarecurve(amp, color_by = "TreatmentGroup")
```

### Filtering and rarefying/subsampling OTU table

The **`sampling depth`** is used to filter out samples with few counts. Samples with counts which fall below the `sampling depth` are removed from the OTU table using [amp\_subset\_samples](https://madsalbertsen.github.io/ampvis2/reference/amp_subset_samples.html). The names of samples that are removed are output to *samples\_being\_ignored.txt*.

Additionally, the `sampling depth` is used to rarefy the counts for the Bray-Curtis PCoA and the alpha diversity plots. The OTU table is rarefied using [rrarefy](https://www.rdocumentation.org/packages/vegan/versions/2.4-2/topics/rarefy) from the vegan R package. The table of the filtered, rarefied counts is saved as *rarefied\_OTU\_table.txt*.

If you do not provide a `sampling depth`, the default value is **10000**.

``` r
ampsub <- amp_subset_samples(amp, minreads = sampdepth)
otu <- rrarefy(t(ampsub$abund), sampdepth)
amprare$abund <- t(otu)
```

### Heatmap

The interactive heatmap is implemented using the [morpheus R API](https://github.com/cmap/morpheus.R) developed at the Broad Institute. [Documentation](https://software.broadinstitute.org/morpheus/documentation.html) for how to use the heatmap can be found on the [morpheus website](https://software.broadinstitute.org/morpheus/).

The heatmap, *seq\_heatmap.html*, is made from the raw OTU table with the counts normalized to 100 to represent the relative abundances using [amp\_subset\_samples](https://madsalbertsen.github.io/ampvis2/reference/amp_subset_samples.html) before the heatmap is made with morpheus. If there are too many OTUs or sequence variants, then the heatmap is made at the species level instead. A heatmap is also made from the rarefied counts, *seq\_heatmap\_rarefied.html*.

``` r
amptax <- amp_subset_samples(amp, normalise = TRUE)
heatmap <- morpheus(amp$abund, columns = columns, rows = rows, 
    columnColorModel = list(type = as.list(colors)), 
    colorScheme = list(scalingMode = "fixed", stepped = FALSE), 
    columnAnnotations = amptax$metadata, rowAnnotations = amptax$tax)
```

### PCoA

Principal coordinates analysis using binomial and Bray-Curtis distances is carried out using [amp\_ordinate](https://madsalbertsen.github.io/ampvis2/reference/amp_ordinate.html). For more information on the formulae for the distance measures, see [`vegdist`](https://www.rdocumentation.org/packages/vegan/versions/2.4-2/topics/vegdist).

The binomial distance is able to handle varying sample sizes, so the raw counts from the OTU table are used. For the Bray-Curtis distance, the rarefied counts are used. The coordinates from the plots are written to *pcoa\_binomial.txt* and *pcoa\_bray.txt* and the plots to *pcoa\_binomial.html* and *pcoa\_bray.html*. At least 3 samples are needed for these plots.

``` r
pcoa_binomial <- amp_ordinate(amp, filter_species = 0.01, type = "PCOA", 
    distmeasure = "binomial", sample_color_by = "TreatmentGroup", 
    detailed_output = TRUE, transform = "none")

pcoa_bray <- amp_ordinate(amprare, filter_species = 0.01, type = "PCOA", 
    distmeasure = "bray", sample_color_by = "TreatmentGroup", 
    detailed_output = TRUE, transform = "none")
```

### Alpha diversity

The Shannon diversity and Chao species richness are computed using [amp\_alphadiv](https://madsalbertsen.github.io/ampvis2/reference/amp_alphadiv.html). The rarefied counts are used for this computation. The diversity values are saved in *alphadiv.txt*, and boxplots are output to *alphadiv.html*. At least 3 samples are needed to produce these plots.

``` r
alphadiv <- amp_alphadiv(amprare, measure = "shannon", richness = TRUE, rarefy = sampdepth)
```

## Output Files

Complete descriptions of the output files can be found in the [Plots section above](#plots). To learn how to edit the plots, see the <a href="{{ url_for('show_tutorials') }}">visualization tutorial</a>.

-   *rarecurve.html*: rarefaction curve plot
-   *rarecurve.txt*: tabular data used to make the rarefaction curve plot
-   *seq\_heatmap\*.html*: heatmap of OTU/sequence variant abundances
-   *samples\_being\_ignored.txt*: list of samples removed from the analysis
-   *pcoa\_\*.html*: PCoA plots
-   *pcoa\_\*.txt*: tabular data used to make the PCoA plots
-   *rarefied\_OTU\_table.txt*: rarefied OTU table used for Bray-Curtis PCoA and alpha diversity plots
-   *alphadiv.html*: alpha diversity boxplots
-   *alphadiv.txt*: tabular data used to make the alpha diversity plots

## Tools and References

<p>
M A, SM K, AS Z, RH K and PH N (2015). “Back to Basics - The Influence of DNA Extraction and Primer Choice on Phylogenetic Analysis of Activated Sludge Communities.” <em>PLoS ONE</em>, <b>10</b>(7), pp. e0132783. <a href="http://dx.plos.org/10.1371/journal.pone.0132783" target="_blank" rel="noopener noreferrer">http://dx.plos.org/10.1371/journal.pone.0132783</a>.
</p>
<p>
Gould J (2018). <em>morpheus: Interactive heat maps using ‘morpheus.js’ and ‘htmlwidgets’</em>. R package version 0.1.1.1, <a href="https://github.com/cmap/morpheus.R" target="_blank" rel="noopener noreferrer">https://github.com/cmap/morpheus.R</a>.
</p>
<p>
Sievert C, Parmer C, Hocking T, Chamberlain S, Ram K, Corvellec M and Despouy P (2017). <em>plotly: Create Interactive Web Graphics via ‘plotly.js’</em>. R package version 4.7.1, <a href="https://CRAN.R-project.org/package=plotly" target="_blank" rel="noopener noreferrer">https://CRAN.R-project.org/package=plotly</a>.
</p>
<p>
McMurdie PJ and Paulson JN (2016). <em>biomformat: An interface package for the BIOM file format</em>. <a href="https://github.com/joey711/biomformat/" target="_blank" rel="noopener noreferrer">https://github.com/joey711/biomformat/</a>.
</p>
<p>
Oksanen J, Blanchet FG, Friendly M, Kindt R, Legendre P, McGlinn D, Minchin PR, O’Hara RB, Simpson GL, Solymos P, Stevens MHH, Szoecs E, Wagner H (2019). <em>vegan: Community Ecology Package</em>. R package version 2.5-4, <a href="https://CRAN.R-project.org/package=vegan" target="_blank" rel="noopener noreferrer">https://CRAN.R-project.org/package=vegan</a>.
</p>
