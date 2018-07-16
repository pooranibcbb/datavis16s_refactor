devtools::load_all()
outdir <- "/Users/subramanianp4/git/nephele2/pipelines/datavis16s/testdata/graphs"
#amp <- readindata(datafile="testdata/otu_table_mc2_w_tax_no_pynast_failures.biom", mapfile = "testdata/easton_corrected.txt")
#A <- read.delim("testdata/testmapfile.txt", check.names = F)
#write.tab.table(head(A, 2), "testdata/twosamplesmapfile.txt")
#amp <- readindata(datafile="testdata/taxa_species.biom", mapfile = "testdata/testmapfile.txt")

trygraphwrapper("testdata/taxa_species.biom", outdir=dirname(outdir), mapfile = "testdata/complete_corrected.txt", FUN="allgraphs", info=F, sampdepth=40000, logfilename = "/Users/subramanianp4/git/nephele2/pipelines/datavis16s/testdata/logfile.txt")
#allgraphs("testdata/taxa_species.biom", outdir=outdir, mapfile = "testdata/testmapfile.txt", sampdepth = 30000)


