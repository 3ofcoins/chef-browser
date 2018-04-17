# -*- conf -*-
FROM ruby:2.5

RUN set -e -x ; \
    apt-get update ; \
    apt-get install --yes cmake python-virtualenv ; \
    rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/*

COPY . /opt/chef-browser
WORKDIR /opt/chef-browser
RUN set -e -x ; \
    bundle install --deployment --without development --binstubs ; \
    if [ -d .git ] ; then \
        git log -n 1 | tee public/REVISION.txt ; \
        rm -rf .git ; \
    fi ; \
    ln -s config/docker_settings.rb settings.rb ; \
    install -d -g www-data -m 1770 var

USER www-data
EXPOSE 9292
ENV TITLE Chef Browser
ENV CHEF_CLIENT_KEY /opt/chef-browser/client.pem
CMD [ "./bin/rackup", "-o", "0.0.0.0", "-p", "9292", "config.ru" ]
