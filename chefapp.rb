require 'sinatra'
require 'ridley'
require 'chef_zero/server'
#require 'chef'

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

  #get 'node/:node_name' do
  #take a :node_name from a node_list[] using the .each method
  #and redirect to a "customized" node.erb file w/ the above URL,
  #populated w/ details of the given node:
  # erb :node
  #end

end
