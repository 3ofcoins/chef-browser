require 'sinatra'

class ChefApp < Sinatra::Base

  get '/' do
    erb :index
  end
  
end

#ChefApp.run!

