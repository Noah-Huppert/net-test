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
#	--sites: Will only show the sites header from test output. Can not be 
#		 used with any other argument
#?

# Parse arguments
default_op_status=".*"
op_status="$default_op_status"
op_sites="false"

usage () {
	echo "usage: ${0##*/} [--sites | --status <pass,fail>]"
	exit
}

while [ ! -z "$1" ]; do
	key="$1"
	shift

	case "$key" in
		--help|-h|-?)
                        usage
                        ;;
		--status)
			if [ "$1" == "pass" ]; then
				op_status=1
			elif [ "$1" == "fail" ]; then
				op_status=0
			else
				echo "Error: --status argument expects either \"pass\" or \"fail\"" >&2
				exit 1
			fi
			shift
			;;
		--sites)
			op_sites="true"
			;;
		*)
			if [ -f $key ]
			then
				echo "Error: This program only reads from stdin"
				echo "To filter an existing file run \"filter.sh < test.log\""
				exit 1
			fi
			echo "Error: unknown argument \"$key\"" >&2
			exit 1
			;;
	esac
done

# Check --sites argument is only argument if passed
if [ "$op_status" != "$default_op_status" ] && [ "$op_sites" == "true" ]; then
	echo "Error: --sites argument can not be provided with any other arguments" >&2
	exit 1
fi

# If sites arg provided
if [ "$op_sites" == "true" ]; then
	# Read lines until no more sites headers
	while read -r line; do
		if [[ "$line" =~ ^# ]]; then
			echo "$line" | sed -e 's/^#\(.*\)/\1/'
		else
			exit 0
		fi
	done
else
	cat - | grep -P "^.* $op_status .* .*"
fi
