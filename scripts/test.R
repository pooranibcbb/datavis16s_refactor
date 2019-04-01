devtools::load_all()
outdir <- "/Users/subramanianp4/git/nephele2/pipelines/datavis16s/testdata/graphs"


allgraphs(datafile="testdata/decipher_outputs/OTU_table.txt", mapfile="testdata/decipher_outputs/mayank.txt.no_gz", outdir=outdir, sampdepth = 10000, tsvfile=T)

# amp <- readindata(datafile = "testdata/decipher_outputs/OTU_table.txt", mapfile="testdata/decipher_outputs/mayank.txt.no_gz", tsvfile = T)


# adiv <- adivboxplot(amp=amp, sampdepth=10000, outdir=outdir)

