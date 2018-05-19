#!/usr/bin/env bash
#
#?
# Filter - Searches Net Test output for network connectivity tests with specific 
#          statuses
#
# Usage: filter.sh
#
# Expects stdin to be net-test.sh output
#
# Arguments:
#	--status (String): Filter output to only show tests which "pass" or 
#			   "fail"
#?

# Parse arguments
stat=".*"
while [ ! -z "$1" ]; do
	key="$1"
	shift

	case "$key" in
		--status)
			if [ "$1" == "pass" ]; then
				stat=1
			elif [ "$1" == "fail" ]; then
				stat=0
			else
				echo "Error: --status argument expects either \"pass\" or \"fail\""
				exit 1
			fi
			shift
			;;
		*)
			echo "Error: unknown argument \"$key\""
			exit 1
			;;
	esac
done

cat - | grep -P "^.* $stat .* .*"
