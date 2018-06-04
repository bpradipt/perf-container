#!/bin/bash
declare -a PIDS
PIDS=($(ps -A -o pid=))

#Remove last element as it's the PID of the 'ps' command
unset PIDS[-1]
echo "Monitored PIDs: " "${PIDS[*]}"

#Convert array to comma separated list
PERF_PIDS=`(IFS=$','; echo "${PIDS[*]}")`

function start_perf() {
   timeout -t 60  /perf stat -a -p $PERF_PIDS -x ',' -I 1000
}

while read i; do if [ "$i" = startperf ]; then start_perf; break; fi; done \
< <(inotifywait  -e create,open,modify --format '%f' --monitor /tmp)

