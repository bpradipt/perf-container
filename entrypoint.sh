#!/bin/bash
TIMEOUT=${1:-60}
COUNT=${2:-1}
OUT_SUFFIX=${HOSTNAME:+-$HOSTNAME}
declare -a PIDS
PIDS=($(ps -A -o pid=))

#Remove last element as it's the PID of the 'ps' command
unset PIDS[-1]
echo "Monitored PIDs: " "${PIDS[*]}"

#Convert array to comma separated list
PERF_PIDS=`(IFS=$','; echo "${PIDS[*]}")`

function start_perf() {
   for (( i=1; i<=${COUNT}; i++ ))
   do
     timeout -t ${TIMEOUT}  /perf stat -a -p $PERF_PIDS -x ',' -I 1000  -A -o /out/perf-stat-output${OUT_SUFFIX} --append
   done
}


#Trigger perf collection if /tmp/startperf is present
while read i; do if [ "$i" = startperf ]; then start_perf; break; fi; done \
< <(inotifywait  -e create,open,modify --format '%f' --monitor /tmp)

#Long sleep :-)
sleep 1000000000d
