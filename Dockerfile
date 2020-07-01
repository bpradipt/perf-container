FROM alpine:edge
RUN apk --no-cache add inotify-tools bash perf bcc-tools bpftrace-tools

ADD entrypoint.sh /
ENTRYPOINT ["/entrypoint.sh"]
