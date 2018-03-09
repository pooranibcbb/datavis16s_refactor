library(datavis16s)
## mothur

# outdir <-  "/Users/subramanianp4/git/nephele2/pipelines/datavis16s/testdata/mothur"
# dir.create(outdir, showWarnings = FALSE)
# ggg <- allgraphs(mapfile="testdata/vanessa_HF_mapfile.txt", datafile = "testdata/mothur.biom", outdir = outdir, sampdepth = 5713)
#
# outdir <-  "/Users/subramanianp4/git/nephele2/pipelines/datavis16s/testdata/greengenes"
# dir.create(outdir, showWarnings = FALSE)
# ggg <- allgraphs(mapfile="testdata/vanessa_HF_mapfile.txt", datafile = "testdata/greengenesOTU_table.biom", outdir = outdir, sampdepth = 47052)

outdir <-  "/Users/subramanianp4/git/nephele2/pipelines/datavis16s/testdata/graphs"
dir.create(outdir, showWarnings = FALSE)
#ggg <- allgraphs(mapfile="testdata/vanessa_HF_mapfile.txt", datafile = "testdata/taxa_species.biom", outdir = outdir, sampdepth = 36876)
amp <- readindata(mapfile="testdata/testmapfile.txt", datafile = "testdata/taxa_species.biom")
adivboxplot(amp=amp, outdir=outdir, sampdepth = 36876)
