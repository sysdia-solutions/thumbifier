FROM ubuntu:15.10

RUN apt-get -q -y update
RUN apt-get -q -y install imagemagick ghostscript ffmpeg supervisor openssh-server

RUN wget http://download.gna.org/wkhtmltopdf/obsolete/linux/wkhtmltopdf-0.9.9-static-amd64.tar.bz2
RUN tar -xjf wkhtmltopdf-0.9.9-static-amd64.tar.bz2
RUN rm wkhtmltopdf-0.9.9-static-amd64.tar.bz2
RUN mkdir /opt/wkhtmltopdf
RUN mv wkhtmltopdf-amd64 /opt/wkhtmltopdf/wkhtmltopdf-0.9.9
RUN ln -s /opt/wkhtmltopdf/wkhtmltopdf-0.9.9 /opt/wkhtmltopdf/latest
RUN ln -s /opt/wkhtmltopdf/latest /usr/bin/wkhtmltopdf

RUN mkdir -p /var/log/supervisor

RUN echo "[supervisord] \n\
nodaemon=true \n\
\n\
[program:thumbifier] \n\
command=/root/bin/thumbifier start" > /etc/supervisor/conf.d/supervisord.conf

ADD rel/thumbifier/releases/0.0.1/thumbifier.tar.gz /root/

EXPOSE 80

CMD ["/usr/bin/supervisord"]
