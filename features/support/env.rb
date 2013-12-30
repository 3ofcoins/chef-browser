_lib = File.realpath(File.join(File.dirname(__FILE__), '../../lib'))
$:.unshift(_lib) unless $:.include?(_lib)

ENV['CHEF_BROWSER_SETTINGS'] = File.expand_path(File.join(File.dirname(__FILE__),
    '../fixtures/settings.rb'))
ENV['CHEF_ZERO_PORT'] ||= '4001'

# `celluloid/test` needs to be required before chef-browser to prevent
# initializing Celluloid with its at_exit handlers by importing
# Celluloid from Ridley from Chef Browser.
require 'celluloid/test'

# `mime/types` needs to be required separately before Capybara,
# because for some reason if it's required by regular chain of imports
# from within Capybara, it blows up JRuby 1.7.8 with
# NullPointerException. Can't figure out why, let's just cargo cult
# the import here.
require 'mime/types'

require 'chef-browser'

require 'capybara/cucumber'

Before('@loggedin') do
  json_data = JSON['{"users": {"admin": {"chef_type": "user","id": "admin","name": "admin","admin": true,"password": "admin"}}}']
  $chef_zero.load_data(json_data)
  step 'I visit "/login"'
  step 'I log in as "admin" with password "admin"'
end

require 'wrong'
World(Wrong)

Celluloid.boot
