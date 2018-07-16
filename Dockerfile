FROM ubuntu:xenial
MAINTAINER Lars Kellogg-Stedman <lars@oddbit.com>

ENV SQUEEZE_VOL /srv/squeezebox
ENV LANG C.UTF-8
ENV DEBIAN_FRONTEND noninteractive
ENV BASESERVER_URL=http://downloads.slimdevices.com/nightly/7.9/sc/

RUN apt-get update && \
	apt-get -y install curl wget faad flac lame sox libio-socket-ssl-perl tzdata && \
	apt-get clean
	
RUN echo $TZ > /etc/timezone && \
	rm /etc/localtime && \
	dpkg-reconfigure -f noninteractive tzdata

RUN 	RELEASE=`curl -Lsf -o - "${BASESERVER_URL}?C=M;O=A" | grep DIR | sed -e '$!d' -e 's/.*href="//' -e 's/".*//'` && \
	MEDIAFILE=`curl -Lsf -o - "${BASESERVER_URL}${RELEASE}" | grep _amd64.deb | sed -e '$!d' -e 's/.*href="//' -e 's/".*//'` && \
	MEDIASERVER_URL="${BASESERVER_URL}${RELEASE}${MEDIAFILE}" && \
	curl -Lsf -o /tmp/logitechmediaserver.deb $MEDIASERVER_URL && \
	dpkg -i /tmp/logitechmediaserver.deb && \
	rm -f /tmp/logitechmediaserver.deb && \
	apt-get clean

# This will be created by the entrypoint script.
RUN userdel squeezeboxserver

VOLUME $SQUEEZE_VOL
EXPOSE 3483 3483/udp 9000 9090

COPY entrypoint.sh /entrypoint.sh
COPY start-squeezebox.sh /start-squeezebox.sh
RUN chmod 755 /entrypoint.sh /start-squeezebox.sh
ENTRYPOINT ["/entrypoint.sh"]
