# ------------------------------------------------------------------------------------------------------
# ProxyDiff.R
# 10.3.2015 - Andrew A. Ritz
# See readme.md for more information.

# This is an open source script.  Please report issues + bugs.
# ------------------------------------------------------------------------------------------------------

# Libs
library(RCurl)
library(dplyr)
library(tidyr)

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
final<-data.frame(ID=numeric(0), Host=character(0),Path=character(0), stringsAsFactors = FALSE)

curID<-0
hostList<-c(RealHost, ProxyHost)
for(h in hostList)
{

  urlCount<-0
  for (s in srcs)
  {
    curID<-curID+1
    final<-rbind(final, data.frame(ID=curID, Host=h, Path=s, stringsAsFactors = FALSE))
    urlCount<-urlCount + 1
    if (urlCount >= MaxUrls) 
    {
      message(paste("Stopping source list at max", MaxUrls))
      break 
    }
  }
}


# We will loop through the list of urls according to the Request count.
# Each time we will randomize the order of the requests to prevent side effects from repeat requests, etc.
# You may configure a seed now if you need to repeat results.
# set.seed(10)

doRequest<-function(url)
{
  # We just download the url and measure the amount of time that it took.
  message(paste("GET:", url))
  t<-system.time(getURL(url))
  t[["elapsed"]]
}

allTimes<-list()
for(i in 1:RequestCount)
{
  useList = sample(final)
  allTimes<-sapply(useList, doRequest)
}

# Get a table that we will use for analysis purposes.
df<-data.frame(times=allTimes, url=names(allTimes), stringsAsFactors=FALSE)
timeTbl<-tbl_df(df)
rm(df)

