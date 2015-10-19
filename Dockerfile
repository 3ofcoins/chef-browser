# -*- conf -*-
FROM ubuntu:14.04

COPY config/docker_apt_preferences /etc/apt/preferences.d/brightbox-ruby-ng
RUN set -e -x ; \
    echo 'deb http://ppa.launchpad.net/brightbox/ruby-ng/ubuntu trusty main' > /etc/apt/sources.list.d/brightbox-ruby-ng.list ; \
    apt-key adv --keyserver keyserver.ubuntu.com --recv C3173AA6 ; \
    apt-get update ; \
    apt-get install --yes ruby2.2 ruby2.2-dev git build-essential libssl-dev libicu-dev cmake pkg-config ; \
    gem install bundler --no-rdoc --no-ri ; \
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
CMD [ "./bin/rackup", "config.ru" ]
