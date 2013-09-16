require 'bundler/setup'
require './chefapp'
require 'tinyconfig'

class ChefSettings < TinyConfig
  #use option method to define known options
  option :server_url
  option :client_name
  option :client_key

  #details here...

end

server_details = ChefSettings.new

server_details.load("settings.rb.example")

puts "#{server_details.server_url}, #{server_details.client_name}, #{server_details.client_key}"

run ChefApp.new
