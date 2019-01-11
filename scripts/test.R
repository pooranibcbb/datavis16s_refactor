devtools::load_all()
outdir <- "/Users/subramanianp4/git/nephele2/pipelines/datavis16s/testdata/graphs"
#amp <- readindata(datafile="testdata/otu_table_mc2_w_tax_no_pynast_failures.biom", mapfile = "testdata/easton_corrected.txt")
#A <- read.delim("testdata/testmapfile.txt", check.names = F)
#write.tab.table(head(A, 2), "testdata/twosamplesmapfile.txt")
#amp <- readindata(datafile="testdata/taxa_species.biom", mapfile = "testdata/testmapfile.txt")
datafile <- "testdata/combo.trim.contigs.good.unique.good.filter.unique.precluster.pick.opti_mcc.0.03.biom"
mapfile <- "testdata/N2_16S_example_mapping_file.txt.no_gz"
#datafile <- "testdata/otu_table_mc2_w_tax_no_pynast_failures.biom"

biom <- read_biom(datafile)
otu <- as.data.frame(as.matrix(biomformat::biom_data(biom)))
tax <- biomformat::observation_metadata(biom)


#vvv <- trygraphwrapper(datafile, outdir=dirname(outdir), mapfile = mapfile, FUN="allgraphs", info=F, sampdepth=100000, logfilename = "/Users/subramanianp4/git/nephele2/pipelines/datavis16s/testdata/logfile.txt")
allgraphs(datafile, outdir=outdir, mapfile = mapfile, sampdepth = 12000)


