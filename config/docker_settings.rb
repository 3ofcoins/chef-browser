# frozen_string_literal: true

server_url ::ENV['CHEF_SERVER_URL']
client_name ::ENV['CHEF_CLIENT_NAME']
client_key ::ENV['CHEF_CLIENT_KEY']
connection[:ssl] = { verify: false } if ::ENV['INSECURE_SSL']
title ::ENV['TITLE']
use_partial_search !::ENV['NO_PARTIAL_SEARCH']
login ::ENV['LOGIN']

::File.write('var/secret', ::SecureRandom.base64(64)) unless ::File.exist?('var/secret')
cookie_secret ::File.read('var/secret')
