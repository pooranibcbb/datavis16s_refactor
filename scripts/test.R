devtools::load_all()
outdir <- "/Users/subramanianp4/git/nephele2/pipelines/datavis16s/testdata/graphs"
amp <- readindata(datafile="testdata/otu_table_mc2_w_tax_no_pynast_failures.biom", mapfile = "testdata/easton_corrected.txt")

# library(rhdf5)
#
# infile <- "testdata/otu_table_mc2_w_tax_no_pynast_failures.biom"
# H5close()
# H5garbage_collect()
# #tax <- h5read(infile, "/observation/metadata/taxonomy")
# fid <- H5Fopen(infile)
# obs <- H5Gopen(fid, "observation")
# obsmet <- H5Gopen(obs, "metadata")
# taxopt <- H5Dopen(obsmet, "taxonomy")
# tax <- H5Dread(taxopt)
# #H5close()
# H5garbage_collect()
