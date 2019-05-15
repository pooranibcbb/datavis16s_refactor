devtools::load_all()
outdir <- "/Users/subramanianp4/git/nephele2/pipelines/datavis16s/testdata/graphs"

allgraphs(datafile="/Users/subramanianp4/HuMeta/Boss_09202018_v4/PipelineResults.f03c9e33f86d/OTU_table.txt", outdir=outdir, mapfile="/Users/subramanianp4/HuMeta/Boss_09202018_v4/Jia_mapfile.txt", tsvfile=T, sampdepth = 30000)
