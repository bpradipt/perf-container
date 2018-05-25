FROM ubuntu:16.04

RUN apt-get update && apt-get install -y linux-tools-generic linux-tools-4.4.0-124-generic inotify-tools && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ADD entrypoint.sh /

ENTRYPOINT ["/entrypoint.sh"]
