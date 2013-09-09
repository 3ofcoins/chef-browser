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


end
