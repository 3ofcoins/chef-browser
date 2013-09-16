require 'bundler/setup'
require './chefapp'
require 'tinyconfig'

class ChefSettings < TinyConfig
  #use option method to define known options
  option :server_url, "http://127.0.0.1:4000"
  option :client_name, "marta"
  option :client_key, ::File.join(::File.dirname(__FILE__), 'features/fixtures/stub.pem')

  #details here...

end

server_details = ChefSettings.new

puts "#{server_details.server_url}, #{server_details.client_name}, #{server_details.client_key}"

#run ChefApp.new
