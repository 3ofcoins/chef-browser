require 'sinatra'
require 'ridley'
require 'chef_zero/server'

include ERB::Util

class ChefApp < Sinatra::Base

  get '/' do
    erb :index
  end

  get '/all_nodes' do
    erb :all_nodes
  end

  get '/node' do
    erb :node
  end

  get '/data_bags' do
    erb :data_bags
  end

  get '/:node_name' do
  #   take a :node_name and redirect the above URL to a dynamically created page w/the "node" layout,
  #   populated w/ details of the given node. Break it down into smaller steps:
  #     a. create a :node_name redirection & all of the URLs end in the
  #        "uncustomized" erb :node
  #     b. create a "customized" view in node.erb for the node that's
  #        specified in the URL avobe.

    my_server = Ridley.new(server_url: "http://127.0.0.1:4000", client_name: "marta", client_key: "/home/marta/.chef/marta.pem")
    @nodes = my_server.node.all
    @node_array = Array.new
    @node_name = request.path.delete "/"
    @nodes.each do |node|
      @node_array.push(node[:name])
    end

    if @node_array == nil
        "Sorry, the node you're looking for doesn't exist."
      else
        p my_server.node.find(@node_name)[:name] + my_server.node.find(@node_name)[:automatic][:fqdn] + my_server.node.find(@node_name)[:name] + my_server.node.find(@node_name)[:automatic][:ipaddress]
    end
  end
end
