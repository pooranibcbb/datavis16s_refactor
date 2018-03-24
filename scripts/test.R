devtools::load_all()

#amp <- readindata(mapfile="testdata/vanessa_HF_mapfile.txt", datafile = "testdata/taxa_species.biom")
#sn <- datavis16s:::shortnames(amp$tax[1216:1220,])
outdir <- "/Users/subramanianp4/git/nephele2/pipelines/datavis16s/testdata"
# tl <- "Family"
# if (tl != "seq") {
#   amptax <- highertax(amp, taxlevel=tl)
# } else {
#   amptax <- amp
# }
#
# amptax <- filterlowabund(amptax, level = 0.1)
# stop()
# sntax <- ifelse(tl == "seq", "Species", tl)
# sn <- shortnames(amptax$tax, taxa = sntax)
# sn <- paste(amptax$tax$OTU, sn)
#
# mm <- max(amptax$abund)
# values <-  c(0,expm1(seq(log1p(filter_level), log1p(100), length.out = 99)))
# w <- which(values > 10)
# values[w] <- round(values[w], digits = 1)
# #    message(paste(values))
# mat <- amptax$abund
# row.names(mat) <- sn
#
# mat <- mat[,amptax$metadata$SampleID]
#

# mp <- allgraphs(mapfile="testdata/vanessa_HF_mapfile.txt", datafile = "testdata/taxa_species.biom", outdir = outdir)
#newmp <- trygraphwrapper(mapfile = "testdata/SILVA_mapfile.txt", datafile = "testdata/SILVA_OTU_table.biom", outdir = outdir, allgraphs, logfilename = file.path(outdir, "logfile.txt"))

unlink(file.path(outdir, "graphs"), recursive = TRUE)
trygraphwrapper("testdata/SILVA_OTU_table.biom", outdir,  "testdata/SILVA_mapfile.txt", allgraphs,  logfilename = file.path(outdir, "logfile.txt"))
