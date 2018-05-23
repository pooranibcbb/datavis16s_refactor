devtools::load_all()
outdir <- "/Users/subramanianp4/git/nephele2/pipelines/datavis16s/testdata/graphs"
#amp <- readindata(mapfile="testdata/sjogren_gz_mapfile.txt", datafile = "testdata/taxa_species.biom")
#
# allgraphs(datafile = "testdata/taxa_species.biom", outdir=outdir, mapfile="testdata/vanessa_HF_mapfile.txt", sampdepth = 40000)

outdir <- "/Users/subramanianp4/git/nephele2/pipelines/datavis16s/testdata/graphsbig"
# amp <- readindata(mapfile="testdata/complete_corrected.txt", datafile = "testdata/otu_table.biom")
allgraphs( datafile = "testdata/otu_table.biom",mapfile="testdata/complete_corrected.txt", outdir = outdir, sampdepth = 20969 )

#Sys.setlocale('LC_ALL','C')
amp <- readindata(mapfile="testdata/complete_corrected.txt", datafile = "testdata/otu_table.biom")
#morphheatmap(amp = amp, sampdepth=19058, outdir = outdir)



