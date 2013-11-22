_lib = File.realpath(File.join(File.dirname(__FILE__), '../../lib'))
$:.unshift(_lib) unless $:.include?(_lib)

ENV['CHEF_BROWSER_SETTINGS'] = File.expand_path(File.join(File.dirname(__FILE__),
    '../fixtures/settings.rb'))
ENV['CHEF_ZERO_PORT'] ||= '4001'

require 'chef-browser'

require 'capybara/cucumber'
require 'capybara/webkit'
Capybara.app = ChefBrowser::App
Capybara.javascript_driver = :webkit

require 'wrong'
World(Wrong)
