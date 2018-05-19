#!/usr/bin/env bash
#
#?
# Analyse - Searches Net Test output for failed network connectivity tests
#
# Usage: analyse.sh
#
# Expects stdin to be net-test.sh output
#?
cat - | grep -P '.* 0 .* .*'
