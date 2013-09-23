require 'erubis'
require 'sinatra'
require 'ridley'

require 'chef-browser/settings'

module ChefBrowser
  class App < Sinatra::Base
    set :erb, :escape_html => true
    set :root, File.expand_path(File.join(File.dirname(__FILE__), '../..'))

    # It's named this way to have variables from the `settings.rb` file
    # visible from inside the app as `settings.rb.setting_name`
    set :rb, begin
               settings_rb = Settings.new
               settings_rb.load File.join(settings.root, 'settings.rb')
               settings_rb
             end

    def chef_server
      @chef_server ||= Ridley.new(
        server_url: settings.rb.server_url,
        client_name: settings.rb.client_name,
        client_key: settings.rb.client_key)
    end

    def json_to_path(json_dump, prefix='$')
      case json_dump
      when Array
        json_dump.each_with_index do |i, v|
          json_to_path(v, "#{prefix}[#{i}]")
        end
      when Hash
        json_dump.each do |k, v|
          json_to_path(v, "#{prefix}.#{k}")
        end
      else
        "#{prefix} = #{json_dump}"
      end
    end

    get '/' do
      redirect '/nodes'
    end

    get '/nodes' do
      erb :node_list, locals: {
        nodes: chef_server.node.all,
        environments: chef_server.environment.all
      }
    end

    get '/node/:node_name' do
      node = chef_server.node.find(params[:node_name])
      json_path = json_to_path(node._attributes_.to_hash)
      erb :node, locals: {
        node: node,
        json_path: json_path,
        attributes: node.chef_attributes
      }
    end

  end
end
