# ------------------------------------------------------------------------------------------------------
# ProxyDiff.R
# 10.3.2015 - Andrew A. Ritz
# See readme.md for more information.

# This is an open source script.  Please report issues + bugs.
# ------------------------------------------------------------------------------------------------------

# Clear + initialize.
rm(list=ls())
if (!file.exists("ProxyDiffInit.R"))
{
  stop("No initialization script detected.  Please follow instructions in 'ProxyDiffInit-Example.R'")
}
source("ProxyDiffInit.R")

# Assemble the list of urls that will be created.
con<-file(SourceList)
srcs<-readLines(con)
close(con)
rm(con)

# Assemble the final list of urls that will be hit.
final<-vector(mode="character")
for(h in HostList)
{
  for (s in srcs)
  {
    final<-c(final, paste0(h,s))
  }
}



