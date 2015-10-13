# ------------------------------------------------------------------------------------------------------
# ProxyDiff.R
# 10.3.2015 - Andrew A. Ritz
# See readme.md for more information.

# This is an open source script.  Please report issues + bugs.
# ------------------------------------------------------------------------------------------------------

# Libs
library(RCurl)
library(dplyr)

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
options(sec.digits=3)
doRequest<-function(urlData, sampleNumber)
{
  url<-paste0(urlData["Host"],urlData["Path"])

  # We just download the url and measure the amount of time that it took.
  message(paste("GET:", url))
  t<-system.time(getURL(url))[["elapsed"]]

  data.frame(Host = urlData[1], Path=urlData[2], Time=t, Sample=sampleNumber, Timestamp=as.character(Sys.time()))
}

# Compile all of the times + data together.
allTimes<-data.frame(Host=character(), Path=character(), Time=numeric(), Sample=numeric(), Timestamp=character())

# Delays between requests...
allDelays<-runif(nrow(final), DelayMin, DelayMax)

for(i in 1:RequestCount)
{
  # Randomize the order of the requests.
  useList<-final[sample(1:nrow(final)),]
  useDelays<-sample(allDelays)
  for(j in 1:nrow(useList))
  {
    # We make the request, and sleep a bit.
    allTimes<-rbind(allTimes, doRequest(useList[j,], i))
    
    #Sleep.  This is to simulate a real user, rather than flooding the endpoints with instant requests.
    Sys.sleep(useDelays[i])
  }
}




# Get the data ready for processing...
pathCount<-length(unique(allTimes$Path))
data<-mutate(allTimes, PathID=factor(allTimes$Path, labels=1:pathCount), Timestamp=as.character(Timestamp))
data<-tbl_df(data)

ByHost = group_by(data, Host)
summarize(ByHost, mean(Time))

ByReal<-filter(data, Host==RealHost)
ByProxy<-filter(data, Host==ProxyHost)


# Init graph options.
par(mfrow=c(2,1))
yRange<-c(-0.5,max(data$Time)+1)


applyLegend<-function()
{
  legend("topright", col=c("red","blue"), legend=PlotLabels, pch=1)
}

# Plot the samples, organized by the path ID.  This way we can see the times
# for each the real/proxy endpoints.
plotByPath<-function()
{
  plot(x=as.numeric(ByReal$PathID), y=ByReal$Time, col="red", pch=1, xlab="PathID", ylab="Time", ylim=yRange, main="Time By Path")
  lines(x=as.numeric(ByProxy$PathID), y=ByProxy$Time, col="blue", type="p")
  applyLegend()
}
plotByPath()


# Now show all of the urls by time.
plotByTime<-function()
{
  timeString<-"%Y-%M-%d %H:%M:%OS"
  realTimes<-strptime(ByReal$Timestamp, timeString)
  proxyTimes<-strptime(ByProxy$Timestamp, timeString)
  
  plot(x=realTimes, y=ByReal$Time, col="red", pch=1, xlab="Timestamp (sec)", ylab="Time", ylim=yRange, main="All Requests")

  lines(x=proxyTimes, y=ByProxy$Time, col="blue", type="p")
  applyLegend()
}
plotByTime()


# Let's splat that to disk.
dataDir<-"./Data"
if (!dir.exists(dataDir)) { dir.create(dataDir) }
baseName<-format(Sys.time(), "%m%d%Y-%H%M%S")
csvPath<-paste0(dataDir, "/data-", baseName, ".csv")
imgPath<-paste0(dataDir, "/plot-", baseName, ".png")

#Write the Raw Data to a CSV file.
csvData<-mutate(data,Time=format(Time, digits=3))
write.csv(csvData, csvPath)

# Write the plot to disk...
minWidth<-500
width=nrow(allTimes) * 3
if (width<minWidth) { width = minWidth }


png(imgPath, width=width, height=1000, units="px")
par(mfrow=c(2,1))
plotByPath()
plotByTime()
dev.off()

