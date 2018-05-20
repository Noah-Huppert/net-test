# Net Test
Monitors network connectivity for downtime.

# Table Of Contents
- [Overview](#overview)
- [Output](#output)
	- [Sites](#sites)
	- [Test Results](#test-results)
- [Usage](#usage)
	- [Net Test](#net-test)
	- [Filter](#filter)
	- [Analyse](#analyse)

# Overview
Set of scripts for analysing network connectivity.  

The `net-test.sh` tool will check network connectivity every second by 
pinging well known websites.  

If the tool fails to connect to one well known website it will try to connect 
to the next well known website. A network connectivity test will only fail if 
all websites can not be contacted.

# Output
## Sites
The sites which the tool checks connectivity by connecting to will be printed 
out in order of precedence when `net-test.sh` is started.

Each site will appear on a new line, which will start with a `#`.  

This behavior can be disabled by passing the `--no-header` argument to 
`net-test.sh`.

## Test Results
The results of connectivity tests will be recorded in the following format:

```
<Unix Time> <Connected?> <Website Index> <Latency>
```

- Unix Time: Time test was started, seconds since epoch
- Connected?: 1 if connected to internet, 0 if not
- Website Index: Which website was successfully connected to. Index starts at 0
- Latency: Time in milliseconds, -1 if test failed

The output of this command can then be passed into the `filter.sh` command to 
display separate out tests which pass from tests which fail.  

Output can also be passed to `analyse.sh` to see statistics about the test.

# Usage
## Net Test
Runs network connectivity tests every second.  

Usage: `net-test.sh`  

Arguments:

- `--no-header`: Don't print the list of sites the script contacts when the 
	        script begins. This can be used if one wishes to continue 
		appending statements to an existing log file.

To save the output for later analysis: `net-test.sh >> test.log`.  

Example output:

```
#1.1.1.1
#8.8.8.8
#google.com
#wikipedia.com
1526769729 1 0 7.395
1526769730 1 0 10.374
1526769731 1 0 10.385
1526769732 1 0 5.797
1526769733 1 0 7.082
1526769734 1 0 8.669
1526769735 1 0 20.135
1526769736 1 0 20.029
```

## Filter
Filters network connectivity output to only show specific types of test output.  

Usage: `filter.sh < test.log`  

Arguments:
- `--status` (String): Filter tests which pass or fail. Accepted values: 
                      `pass`, `fail`
- `--sites`: Displays sites header from test output, must be only argument 
	   provided to filter.

To directly pipe in the net test output: `net-test.sh | filter.sh`  

Or to filter log file output in real time: `tail -f test.log | filter.sh`

## Analyse
Display statistics about test output.  

Usage: `analyse.sh < test.log`  

The number of successful and failed tests along average latency will be printed 
out.  

Example output:

```
Total: 49807, Failed: 0% (0), Succeeded: 100% (49807)
Running time: 14:36:56, Avrg latency: 10.448 ms
```
