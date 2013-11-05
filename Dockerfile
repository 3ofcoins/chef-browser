# chef-browser
#
# VERSION 0.1

# use the ubuntu base image provided by dotCloud
FROM ubuntu

# make sure the package repository is up to date
RUN echo "deb http://archive.ubuntu.com/ubuntu precise main universe" > /etc/apt/sources.list
RUN apt-get update

# prepare the environment
RUN apt-get install -y curl
RUN \curl -L https://get.rvm.io | bash -s stable --ruby
RUN source /usr/local/rvm/scripts/rvm
RUN apt-get install -y git wget unzip

# download & prepare chef-browser
RUN git clone git://github.com/3ofcoins/chef-browser.git
RUN bundle install --gemfile=chef-browser/Gemfile

# TODO: configure chef-browser settings

# start chef-browser when lauching the container
ENTRYPOINT cd chef-browser-develop && puma --environment production

# make the Puma port public
EXPOSE 9292
