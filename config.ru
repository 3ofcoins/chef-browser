require 'bundler/setup'
require './chefapp'
require 'tinyconfig'

class ChefSettings < TinyConfig
  #use option method to define known options
  option :server_url
  option :client_name
  option :client_key
end

run ChefApp.new
