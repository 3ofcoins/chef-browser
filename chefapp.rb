require 'sinatra'

class ChefApp < Sinatra::Base

  get '/' do
    erb :index
  end

  get '/nodes' do
    erb :nodes
  end

end
