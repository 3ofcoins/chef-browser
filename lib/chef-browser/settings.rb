require 'ridley'
require 'tinyconfig'

module ChefBrowser
  class Settings < TinyConfig
    #use option method to define known options
    option :server_url, 'https://127.0.0.1'
    option :client_name, 'chef-webui'
    option :client_key, '/etc/chef-server/chef-webui.pem'
    option :connection, {}

    # Returns a new Ridley connection, as configured by user
    def ridley
      ::Ridley.new({
          server_url: server_url,
          client_name: client_name,
          client_key: client_key
        }.merge(connection))
    end
  end
end
