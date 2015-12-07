FROM ubuntu:15.10

RUN apt-get -q -y update
RUN apt-get -q -y install imagemagick ghostscript ffmpeg supervisor openssh-server

RUN mkdir -p /var/log/supervisor

RUN echo "[supervisord] \n\
nodaemon=true \n\
\n\
[program:thumbifier] \n\
command=/root/bin/thumbifier start" > /etc/supervisor/conf.d/supervisord.conf

ADD rel/thumbifier/releases/0.0.1/thumbifier.tar.gz /root/

EXPOSE 80

CMD ["/usr/bin/supervisord"]
