FROM ubuntu:16.04
RUN apt-get update && apt-get install -y wget build-essential bison flex
RUN wget https://cdn.kernel.org/pub/linux/kernel/v4.x/linux-4.17.tar.xz
RUN tar xvf linux-4.17.tar.xz
RUN cd linux-4.17/tools/perf && export LDFLAGS=-static; make

FROM alpine:latest
COPY --from=0 /linux-4.17/tools/perf/perf /
RUN apk --no-cache add inotify-tools bash

ADD entrypoint.sh /

ENTRYPOINT ["/entrypoint.sh"]
