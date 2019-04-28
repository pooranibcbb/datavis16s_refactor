devtools::load_all()
outdir <- "/Users/subramanianp4/git/nephele2/pipelines/datavis16s/testdata/graphs"


allgraphs(datafile="testdata/decipher_outputs/OTU_table.txt", mapfile="testdata/decipher_outputs/mayank.txt.no_gz", outdir=outdir, sampdepth = 10000, tsvfile=T)

# amp <- readindata(datafile = "testdata/decipher_outputs/OTU_table.txt", mapfile="testdata/decipher_outputs/mayank.txt.no_gz", tsvfile = T)
# amp <- subsetamp(amp, sampdepth=84000, outdir = outdir)
# tt <- cbind.data.frame(amp$abund, amp$tax)
# tt$OTU <- NULL
# write.table(tt, file.path(outdir, 'test.txt'), quote = FALSE, sep = '\t', col.names = NA, na = "")
# write.tab.table(amp$metadata, file.path(outdir, "testmetadata.txt"))

# aa <- readindata(datafile =   "testdata/graphs/test.txt", mapfile="testdata/graphs/testmetadata.txt", tsvfile = T)
#
# allgraphs(datafile =  "testdata/graphs/test.txt", outdir=outdir, mapfile="testdata/graphs/testmetadata.txt", tsvfile = T)

# adiv <- adivboxplot(amp=amp, sampdepth=10000, outdir=outdir)

