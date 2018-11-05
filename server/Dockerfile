FROM python:3.6-jessie
MAINTAINER SPARCS SSO TEAM <sparcssso@sparcs.org>

# Packages installation
RUN apt-get update
RUN apt-get install -y \
    openssh-server \
    sudo \
    vim \
    tmux \
    locales \
    cron \
	git \
	mysql-client \
	libmysqlclient-dev \
	sendmail-bin \
	sendmail \
	gettext \
    nginx

# Creating users
RUN adduser --gecos "" --disabled-password sysop
RUN usermod -G sudo sysop
RUN adduser --gecos "" --disabled-password wheel
RUN usermod -G sudo wheel

# Locale configuration
RUN sed -i -e 's/# ko_KR.UTF-8 UTF-8/ko_KR.UTF-8 UTF-8/' /etc/locale.gen
RUN dpkg-reconfigure --frontend=noninteractive locales
RUN update-locale LANG=ko_KR.UTF-8
RUN echo "export LANG=ko_KR.UTF-8" >> /etc/environment
RUN echo "export LANGUAGE=ko_KR.UTF-8" >> /etc/environment
RUN echo "export LC_ALL=ko_KR.UTF-8" >> /etc/environment

# Certbot installation
RUN wget https://dl.eff.org/certbot-auto
RUN chmod u+x certbot-auto

# Downloading AWS RDS certificates
RUN wget https://s3.amazonaws.com/rds-downloads/rds-ca-2015-root.pem
RUN wget https://s3.amazonaws.com/rds-downloads/rds-ca-2015-ap-northeast-2.pem
RUN cat /rds-ca-2015-ap-northeast-2.pem /rds-ca-2015-root.pem > /rds-ca-2015.pem

# Nginx configuration
RUN sed -i -e "s/# server_tokens/server_tokens/" /etc/nginx/nginx.conf
COPY ./dhparam.pem /etc/nginx/dhparam.pem
COPY ./sso-test /etc/nginx/sites-available/sso
COPY ./sso /etc/nginx/sites-available/sso

# uWSGI configuration
RUN pip install uwsgi
RUN mkdir -p /etc/uwsgi/sites
COPY ./sso.ini /etc/uwsgi/sites/sso.ini
COPY ./scripts/uwsgi /etc/init.d/uwsgi
RUN chmod u+x /etc/init.d/uwsgi

# Repository cloning and pip installation
RUN git clone https://github.com/sparcs-kaist/sparcssso.git /data/sso
COPY ./local_settings.py /data/sso/sparcssso/local_settings.py
COPY ./media /data/sso/media
COPY ./letters /data/sso/letters
WORKDIR /data/sso
RUN pip install -r requirements.txt
RUN python manage.py makemigrations core
RUN python manage.py migrate
RUN python manage.py compilemessages

# Crontab installation
RUN mkdir /data/scripts
COPY ./scripts/update.sh /data/scripts/update.sh
COPY ./scripts/db.sh /backup/script/db.sh
COPY ./scripts/renewal.sh /renewal.sh
RUN chown sysop:sysop /data/scripts/update.sh /backup/script/db.sh /renewal.sh
RUN chmod 700 /data/scripts/update.sh /backup/script/db.sh /renewal.sh
RUN echo "# m h dom mon dow command" > mycron
RUN echo "  0 */8 *  *   *  . /data/sso/manage.py collect-logs > /dev/null" >> mycron
RUN echo "  0 0  *   *   *  . /data/sso/manage.py collect-stats > /dev/null" >> mycron
RUN echo "  0 6  *   *   *  . /data/sso/manage.py clearsessions > /dev/null" >> mycron
RUN echo "  30 6 *   *   *  . /data/sso/manage.py remove-users > /dev/null" >> mycron
RUN echo "  0 7  *   *   *  . /backup/script/db.sh > /dev/null 2>> /backup/log/cron.db.log" >> mycron
RUN echo "  0 9  *   *   0  . /renewal.sh > /dev/null" >> mycron
RUN crontab -u sysop mycron
RUN rm mycron

# Creating archive and permission settings
RUN mkdir -p /data/archive/buffer /data/archive/logs
RUN touch /data/archive/stats.txt
RUN chown sysop:www-data /data/archive /data/archive/buffer /data/archive/stats.txt
RUN chown sysop:sysop /data/archive/logs /data/scripts /data/scripts/update.sh
RUN chmod 750 /backup
RUN chmod 770 /data/archive/buffer
RUN chmod 640 /data/archive/stats.txt
RUN chmod 700 /data/archive/logs /data/scripts /data/scripts/update.sh
RUN chown -R sysop:www-data /data/sso
RUN chmod -R o-rwx /data/sso

CMD /bin/bash -c "service ssh start && service cron start && service uwsgi start && /bin/bash"
