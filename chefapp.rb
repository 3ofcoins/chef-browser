require 'erubis'
require 'sinatra'
require 'ridley'

class ChefApp < Sinatra::Base
  set :erb, :escape_html => true

  def chef_server
    @chef_server ||= Ridley.new(
      server_url: @server.server_url,
      client_name: @server.client_name,
      client_key: @server.client_key)
  end

  get '/' do
    erb :index
  end

  get '/nodes' do
    erb :node_list, locals: {
      nodes: chef_server.node.all,
      environments: chef_server.environment.all
    }
  end

  get '/data_bags' do
    erb :data_bag_list, locals: {
      bags: chef_server.data_bag
    }
  end

  get '/data_bag/:data_bag_name' do
    erb :data_bag, locals: {
      bags: chef_server.data_bag,
      data_bag_name: request.path.gsub("/data_bag/", "")
    }
  end

  get '/node/:node_name' do
    erb :node, locals: {
      nodes: chef_server.node.all,
      node_name: request.path.gsub("/node/", "")
    }
  end

end
