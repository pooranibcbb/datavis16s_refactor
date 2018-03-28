devtools::load_all()

amp <- readindata(mapfile="testdata/vanessa_HF_mapfile.txt", datafile = "testdata/taxa_species.biom")
sn <- datavis16s:::shortnames(amp$tax)
outdir <- "/Users/subramanianp4/git/nephele2/pipelines/datavis16s/testdata"
morphheatmap(amp = amp, outdir = outdir)
stop()
unlink(file.path(outdir, "graphs"), recursive = TRUE)
unlink(file.path(outdir, "logfile.txt"), recursive = TRUE)
trygraphwrapper(datafile = "testdata/SILVA_OTU_table.biom", outdir = outdir, mapfile = "testdata/SILVA_mapfile.txt", allgraphs,  logfilename = file.path(outdir, "logfile.txt"))
# datafile = "testdata/SILVA_OTU_table.biom"
# mapfile =  "testdata/SILVA_mapfile.txt"
# amp <- readindata(datafile=datafile, mapfile = mapfile)
#pcp <- pcoaplot(amp = amp, outdir = file.path(outdir, "graphs"))
