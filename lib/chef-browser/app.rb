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


    def with_jsonpath(obj, prefix='$', &block)
      case obj
      when Array
        obj.each_with_index do |i, v|
          with_jsonpath(v, "#{prefix}[#{i}]", &block)
        end
      when Hash
        obj.each do |k, v|
          with_jsonpath(v, "#{prefix}.#{k}", &block)
        end
      else
        yield prefix, obj
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
      erb :node, locals: {
        node: node,
        attributes: node.chef_attributes
      }
    end

  end
end
