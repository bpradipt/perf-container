#!/bin/bash
#entrypoint.sh <stat|record|probe> <trigger[1|0]> <max-run-time[X]> <repeat-count[N]> <extra-perf-args>
PERF=/usr/bin/perf
PERF_TYPE=${1:-record}
TRIGGER=${2:-0}
TIMEOUT=${3:-60}
COUNT=${4:-1}
EXTRA_PERF_ARGS=$5
OUT_SUFFIX=${HOSTNAME:+-$HOSTNAME}

declare -a PIDS
PIDS=($(ps -A -o pid=))

#Remove last element as it's the PID of the 'ps' command
unset PIDS[-1]
echo "Monitored PIDs: " "${PIDS[*]}"

#Convert array to comma separated list
PERF_PIDS=`(IFS=$','; echo "${PIDS[*]}")`

function start_perf_stat() {
   for (( i=1; i<=${COUNT}; i++ ))
   do
     echo "timeout -t ${TIMEOUT}  ${PERF} stat -a -p $PERF_PIDS -x ',' -I 1000  -A -o /out/perf-stat-output${OUT_SUFFIX} --append ${EXTRA_PERF_ARGS}"
     timeout -t ${TIMEOUT}  ${PERF} stat -a -p $PERF_PIDS -x ',' -I 1000  -A -o /out/perf-stat-output${OUT_SUFFIX} --append ${EXTRA_PERF_ARGS}
   done
}

function start_perf_record() {
   for (( i=1; i<=${COUNT}; i++ ))
   do
     echo "timeout -t ${TIMEOUT}  ${PERF} record -a -g -p $PERF_PIDS -o /out/perf-record-output${OUT_SUFFIX} ${EXTRA_PERF_ARGS}"
     timeout -t ${TIMEOUT}  ${PERF} record -a -p $PERF_PIDS -o /out/perf-record-output${OUT_SUFFIX} ${EXTRA_PERF_ARGS}
   done
}


case ${PERF_TYPE} in 
  stat )
     if [ "${TRIGGER}" == "1" ]
     then
         #Trigger perf collection if /tmp/startperf is present
         while read i; do if [ "$i" = startperf ]; then start_perf_stat; break; fi; done \
         < <(inotifywait  -e create,open,modify --format '%f' --monitor /tmp)
     else
         start_perf_stat
     fi
     ;;
  record ) 
     if [ "${TRIGGER}" == "1" ]
     then
         #Trigger perf collection if /tmp/startperf is present
         while read i; do if [ "$i" = startperf ]; then start_perf_record; break; fi; done \
         < <(inotifywait  -e create,open,modify --format '%f' --monitor /tmp)
     else
         start_perf_record
     fi
     ;;
   
esac

#Long sleep :-)
sleep 1000000000d
