require 'sinatra'
require 'ridley'
require 'chef_zero/server'

include ERB::Util

class ChefApp < Sinatra::Base

  get '/' do
    erb :index
  end

  get '/nodes' do
    erb :nodes
  end

end
