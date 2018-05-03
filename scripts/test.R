devtools::load_all()
outdir <- "/Users/subramanianp4/git/nephele2/pipelines/datavis16s/testdata/graphs"
amp <- readindata(mapfile="testdata/vanessa_HF_mapfile.txt", datafile = "testdata/taxa_species.biom")

adivboxplot(amp = amp, sampdepth = 40000, outdir=outdir)

testfunction <- function() {
  dv <-   bpexploder(A, settings = list(groupVar = "TreatmentGroup", yVar = "Shannon", tipText = list(SampleID = "SampleID", Shannon = "Shannon Index", Description = "Desc"), relativeWidth = 0.8, levelColors = c("red", "blue")))
  print(dv$sizingPolicy)
}

stop()
unlink(file.path(outdir, "graphs"), recursive = TRUE)
unlink(file.path(outdir, "logfile.txt"), recursive = TRUE)
trygraphwrapper(datafile = "testdata/taxa_species.biom", outdir = outdir, mapfile = "testdata/vanessa_HF_mapfile.txt", allgraphs,  logfilename = file.path(outdir, "logfile.txt"), sampdepth=36876)
# datafile = "testdata/SILVA_OTU_table.biom"
# mapfile =  "testdata/SILVA_mapfile.txt"
# amp <- readindata(datafile=datafile, mapfile = mapfile)
#pcp <- pcoaplot(amp = amp, outdir = file.path(outdir, "graphs"))
