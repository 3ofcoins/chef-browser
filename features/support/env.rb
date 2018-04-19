# frozen_string_literal: true

lib = File.realpath(File.join(File.dirname(__FILE__), '../../lib'))
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

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

require 'wrong'
World(Wrong)

Celluloid.boot
