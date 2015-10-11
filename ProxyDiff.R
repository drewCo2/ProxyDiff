# ------------------------------------------------------------------------------------------------------
# ProxyDiff.R
# 10.3.2015 - Andrew A. Ritz
# See readme.md for more information.

# This is an open source script.  Please report issues + bugs.
# ------------------------------------------------------------------------------------------------------

# Libs
library(RCurl)
library(dplyr)
# library(tidyr)

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
final<-data.frame(Host=character(0),Path=character(0), stringsAsFactors = FALSE)

# SRC data.  each row has a unique ID.
# --> we don't need an ID, path/host form a natural key.
# PATH : HOST

# after we start doing work we will merge into it:
# so for each ID, we assign the time, and the sample count
# TIME : SAMPLE#

#so the final data is: note we no longer need the ID.
# PATH : HOST : TIME : SAMPLE#

# then we can apply factors to those data to group by paths / hosts, etc.

# that doesn't really work
hostList<-c(RealHost, ProxyHost)
for(h in hostList)
{

  urlCount<-0
  for (s in srcs)
  {
    final<-rbind(final, data.frame(Host=h, Path=s, stringsAsFactors = FALSE))
    urlCount<-urlCount + 1
    if (urlCount >= MaxUrls) 
    {
      message(paste("Stopping source list at max", MaxUrls))
      break 
    }
  }
}
rm("urlCount")

# We will loop through the list of urls according to the Request count.
# Each time we will randomize the order of the requests to prevent side effects from repeat requests, etc.
# You may configure a seed now if you need to repeat results.
# set.seed(10)

doRequest<-function(urlData, sampleNumber)
{

  url<-paste0(urlData["Host"],urlData["Path"])

  # We just download the url and measure the amount of time that it took.
  message(paste("GET:", url))
  t<-system.time(getURL(url))[["elapsed"]]

  data.frame(Host = urlData[1], Path=urlData[2], Time=t, Sample=sampleNumber)  
}

# Compile all of the times + data together.
allTimes<-data.frame(Host=character(), Path=character(), Time=numeric(), Sampel=numeric())
for(i in 1:RequestCount)
{
  # Randomize the order of the requests.
  useList = sample(final)
  for(j in 1:length(useList))
  {
    allTimes<-rbind(allTimes, doRequest(useList[j,], i))
  }
}

# Get a table that we will use for analysis purposes.
# df<-data.frame(times=allTimes, url=names(allTimes), stringsAsFactors=FALSE)
#timeTbl<-tbl_df(df)
# rm(df)

