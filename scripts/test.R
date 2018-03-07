library(datavis16s)

amp <- readindata(mapfile="testdata/vanessa_HF_mapfile.txt", datafile = "testdata/mothur.biom")
outdir <-  "/Users/subramanianp4/git/nephele2/pipelines/datavis16s/testdata/mothur"
dir.create(outdir, showWarnings = FALSE)
#ggg <- allgraphs(mapfile="testdata/vanessa_HF_mapfile.txt", datafile = "testdata/mothur.biom", outdir = outdir, sampdepth = 5713)
#ggg <- pcoaplot(amp=amp, sampdepth = 47052, outdir=outdir)
#morphheatmap(outdir = outdir, amp = amp, taxlevel = c("Family", "seq"))


withCallingHandlers({
  ggplotly(ggiris)
}, message=function(c) {
  if (startsWith(conditionMessage(c), "We recommend that you use the dev version of ggplot2"))
    invokeRestart("muffleMessage")
})
