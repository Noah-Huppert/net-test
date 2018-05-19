# Net Test
Monitors network connectivity for downtime.

# Table Of Contents
- [Overview](#overview)
- [Usage](#usage)

# Overview
Set of scripts for analysing network connectivity.  

The `net-test.sh` tool will check network connectivity every second by 
pinging the following well known websites: 

- 1.1.1.1
- 8.8.8.8
- google.com
- wikipedia.com

The results of these tests will be recorded in the following format:

```
<Unix Time> <Connected?> <Website Index> <Latency>
```

- Unix Time: Time test was started, seconds since epoch
- Connected?: 1 if connected to internet, 0 if not
- Website Index: Which website was pinged, if the first connectivity check 
                 fails the tool will try to connect to the next well known 
		 website, a connectivity check will only fail if all websites 
		 can not be contacted. Index starts at 0.
- Latency: Time in milliseconds, -1 if test failed

The output of this command can then be passed into the `analyse.sh` command to 
display only failed ping tests.

# Usage
## Net Test
Usage: `net-test.sh`  

To save the output for later analysis: `net-test.sh > test.log`

## Analyse
Usage: `analyse.sh < test.log`  

Or directly pipe in the net test output: `net-test.sh | analyse.sh`
