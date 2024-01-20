#!/bin/bash
#
# compare ripgrep to grep
#

file="$1"
pattern="$2"

start=""
end=""
duration=""

start_m() {
	start=$(date +%s)
}

calc_m() {
	duration="$(($end-$start)) s"
	echo "took: $duration"
}

stop_m() {
	end=$(date +%s)
	calc_m
}

grep_() {
	start_m

	grep "$pattern" "$file"

	stop_m
}

ripgrep_() {
	start_m

	rg "$pattern" "$file"

	stop_m
}

echo "grep test"
grep_

echo "ripgrep test"
ripgrep_
