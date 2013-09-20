_lib = File.realpath(File.join(File.dirname(__FILE__), '../../lib'))
$:.unshift(_lib) unless $:.include?(_lib)

require 'chef-browser'

require 'capybara/cucumber'
Capybara.app = ChefBrowser::App

require 'wrong'
World(Wrong)
