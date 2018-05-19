#!/usr/bin/env bash
#
#?
# Analyse - Provides insight into network test results
#
# Usage: analyse.sh
#
# Expects stdin to be network test output.
#?

# Counters
start_time=""
last_time=""

failed=0
succeeded=0

latency_total="0"

num_tests=0

# Source: https://stackoverflow.com/a/12199798/1478191
secs_to_duration() {
	((h=${1}/3600))
	((m=(${1}%3600)/60))
	((s=${1}%60))
	printf "%02d:%02d:%02d\n" $h $m $s
}

function print_summary() { # ()
	# Calculate avrg latency
	avrg_latency="0"
	if [ "$succeeded" != "0" ]; then
		avrg_latency=$(echo "scale=3; $latency_total / $succeeded" | bc)
	fi

	# Calculate fail / success percentages
	fail_percent=$(echo "($failed / $num_tests) * 100" | bc)
	success_percent=$(echo "($succeeded / $num_tests) * 100" | bc)

	# Calculate time
	delta_t=$(("$last_time" - "$start_time"))
	duration=$(secs_to_duration "$delta_t")

	echo "Total: $num_tests, Failed: ${fail_percent}% ($failed), Succeeded: ${success_percent}% ($succeeded)"
	echo "Running time: $duration, Avrg latency: $avrg_latency ms"
}

# For each line
while read line; do
	# Extract information
	if [ -z "$line" ]; then
		echo "Error: empty line" >&2
		exit 1
	elif [[ "$line" =~ "#" ]]; then
		# Skip commented lines
		continue
	fi

	parts=($line)

	t_time="${parts[0]}"
	t_status="${parts[1]}"
	t_site_index="${parts[2]}"
	t_latency="${parts[3]}"

	# Times
	if [ -z "$start_time" ]; then
		start_time="$t_time"
	fi
	last_time="$t_time"
	
	# Determine status
	if [ "$t_status" == "1" ]; then
		succeeded=$(("$succeeded" + 1))
	elif [ "$t_status" == "0" ]; then
		failed=$(("$failed" + 1))
	else
		echo "Error: unknown status \"$t_status\"" >&2
		exit 1
	fi

	# Latency
	if [ "$t_latency" != "-1" ]; then
		latency_total=$(echo "$latency_total + $t_latency" | bc)
	fi

	num_tests=$(("$num_tests" + 1))
done

print_summary
