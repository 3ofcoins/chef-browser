FROM ubuntu:14.04

ADD config/docker_apt_preferences /etc/apt/preferences.d/brightbox-ruby-ng
# RUN echo 'deb http://archive.ubuntu.com/ubuntu trusty universe multiverse' > /etc/apt/sources.list.d/verse.list
RUN echo 'deb http://ppa.launchpad.net/brightbox/ruby-ng/ubuntu trusty main' > /etc/apt/sources.list.d/brightbox-ruby-ng.list
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv C3173AA6
RUN apt-get update
RUN apt-get install --yes ruby2.1 ruby2.1-dev git build-essential libssl-dev
RUN gem install bundler --no-rdoc --no-ri
ADD . /opt/chef-browser
WORKDIR /opt/chef-browser
RUN bundle install --deployment --without development --binstubs
RUN if [ -d .git ] ; then git log -n 1 | tee public/REVISION.txt && rm -rf .git ; fi
RUN ln -s config/docker_settings.rb settings.rb
RUN install -d -g www-data -m 1770 var
USER www-data
EXPOSE 9292
ENV TITLE Chef Browser
ENV CHEF_CLIENT_KEY /opt/chef-browser/client.pem
CMD [ "./bin/rackup", "config.ru" ]
