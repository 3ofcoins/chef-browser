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

   def pretty_JSON(vv, prefix='') 
     case vv 
     when Array 
       vv.each_with_index do |i, v| 
         pretty_JSON(v, "#{prefix}[#{i}]") 
       end 
     when Hash 
       vv.each do |k, v| 
         pretty_JSON(v, "#{prefix}.#{k}") 
       end 
     else 
      "#{prefix} = #{vv}" 
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
      erb :node, locals: {
        nodes: chef_server.node.all,
        node_name: request.path.gsub("/node/", "")
      }
    end

  end
end
