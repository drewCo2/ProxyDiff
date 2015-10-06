#ProxyDiff

###Purpose
The purpose of this script it to measure the difference in wait times of HTTP requests between a proxy server and a normal server.  This is useful in cases where you have the endpoints of both the proxy and real endpoints, but not direct access to the servers and software on which they run.
  
  
###To Use
####Variables
The following varaibles should be set in your environment before executing the script:  
1. HostList --  The list of host fragments.  Each will be applied to each item in 'SourceList'
2. SourceList -- A text file where each line is a url fragment to be applied to each host. 
3. RequestCount