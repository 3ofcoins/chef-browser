# frozen_string_literal: true

require 'ridley'
require 'tinyconfig'

module ChefBrowser
  class Settings < TinyConfig
    # use option method to define known options
    option :server_url, 'https://127.0.0.1'
    option :client_name, 'chef-webui'
    option :client_key, '/etc/chef-server/chef-webui.pem'
    option :connection, {}
    # Provide the desired saved searches in the following format:
    # {"displayed link name" => "query"}
    option :node_search, {}
    option :title, 'Chef Browser'
    # Disable if you use chef below 11.0; partial searches are used
    # to make searches less heavy on memory and bandwidth
    option :use_partial_search, true
    option :login, false
    # You can define your secret and session time, or use the default below
    option :cookie_secret, ::SecureRandom.base64(64)
    option :cookie_time, 3600

    # Returns a new Ridley connection, as configured by user
    def ridley
      ::Ridley.new({
        server_url: server_url,
        client_name: client_name,
        client_key: client_key
      }.merge(connection))
    end

    # Application root dir
    def self.app_root
      ::File.expand_path(::File.join(::File.dirname(__FILE__), '../..'))
    end

    # Load from config file
    def self.load
      settings_path = if ::ENV['CHEF_BROWSER_SETTINGS']
                        ::File.expand_path(::ENV['CHEF_BROWSER_SETTINGS'])
                      else
                        ::File.join(app_root, 'settings.rb')
                      end
      settings_rb = new
      settings_rb.load(settings_path)
      settings_rb
    end
  end
end
