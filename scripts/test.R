devtools::load_all()
outdir <- "/Users/subramanianp4/git/nephele2/pipelines/datavis16s/testdata/graphs"


allgraphs(datafile="/Users/subramanianp4/FASTA/SILVA_outputs/OTU_table.txt", mapfile="/Users/subramanianp4/FASTA/SILVA_outputs/mayank.txt.no_gz", outdir=outdir, sampdepth = 10000, tsvfile=T)
#amp <- readindata("/Users/subramanianp4/FASTA/SILVA_outputs/OTU_table.txt", "/Users/subramanianp4/FASTA/SILVA_outputs/mayank.txt.no_gz", tsvfile = T)

#morphheatmap(amp=amp, outdir=outdir, sampdepth = 10000)
