# Example script for initializing variables for the ProxyDiff.R script.
# Create a script file "ProxyDiff.R" to create and set the required environment variables.
# You may copy and paste the contents of this file to get started.


# The proxy host / url fragment.
ProxyHost<-"http://someproxy"

# The real host / url fragment.
RealHost<-"http://realhost"


# The list of source url fragments that will be used.
SourceList<-"MyUrls.txt"    

# The max number of urls that will be used from each source.
MaxUrls<-5

# Each URL will be tried once.  we recommend that you leave this at 1.
RequestCount<-1

# The amount of time to delay between each request.  A random time between these
# times will be chosen to help represent a real user.
DelayMin<-0.25
DelayMax<-1.00

# How the label the real/proxy items on the plots.
PlotLabels = c("a","b")

