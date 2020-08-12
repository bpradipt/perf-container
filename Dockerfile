FROM alpine:edge
RUN apk --no-cache add inotify-tools bash perf bcc-tools bpftrace-tools sysstat procps numactl-tools ethtool

ADD entrypoint.sh /
ENTRYPOINT ["/entrypoint.sh"]
