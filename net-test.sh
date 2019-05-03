#!/usr/bin/env bash
#?
# Net Test - Monitors network connectivity for downtime.
#
# Usage: net-test.sh 
#
# Attempts to connect to an internet service to verify internet connectivity 
# every second. Prints the status of this check in the format:
#
#	<Unix Time> <Internet Connectivity> <Fallback Number> <Ping Time>
#
# Where <Internet Connectivity> is a 0 or a 1. And <Fallback Number> is the 
# index of the site in test_sites which the internet connectivity status was 
# determined with.
#
# Options
#
#	--no-header: Makes script not print sites header
#       --site SITE: Site used testing connectivity
#?

# List of sites to test internet connectivity with
default_test_sites=("1.1.1.1" "8.8.8.8" "google.com" "wikipedia.com")
test_sites=()
test_interval=1

# Arguments
op_no_header="false"
while [ ! -z "$1" ]; do
    key="$1"
    shift

    case "$key" in
	--no-header)
	    op_no_header="true"
	    ;;
	--site)
	    if [ -z "$1" ]; then
		echo "Error: --site option requires a value" >&2
		exit 1
	    fi
	    test_sites+=("$1")
	    shift
	    ;;
	*)
	    echo "Error: unknown option \"$key\"" >&2
	    exit 1
	    ;;
    esac
done

if [ -z "$test_sites" ]; then
    test_sites=(${default_test_sites[@]})
fi

# Print site names
if [ "$op_no_header" != "true" ]; then
    for site in "${test_sites[@]}"; do
	echo "#$site"
    done
fi

# Check
while true; do
    current_time="$(date +%s)"
    internet_conn=0
    fallback_num=0
    ping_time="-1"

    # Try each test site until one succeeds
    for site in "${test_sites[@]}"; do
	ping_time_out=$((ping -c 1 "$site" | tail -1 | awk '{print $4}' | cut -d '/' -f 2) 2> /dev/null)
	if [ ! -z "$ping_time_out" ]; then
	    internet_conn=1
	    ping_time="$ping_time_out"
	    break
	fi
	fallback_num=$(("$fallback_num" + 1))
    done

    # Record
    echo "$current_time $internet_conn $fallback_num $ping_time"

    sleep "$test_interval"
done
