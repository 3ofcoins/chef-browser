require 'bundler/setup'
require './chefapp'
require 'tinyconfig'

class ChefSettings < TinyConfig
  #use option method to define known options
  option :server_url
  option :client_name
  option :client_key
end

@server = ChefSettings.new

@server.load("settings.rb.example")

puts "#{@server.server_url}, #{@server.client_name}, #{@server.client_key}"

run ChefApp.new
