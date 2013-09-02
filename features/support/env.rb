require 'rack/test'
require 'wrong'

require './chefapp'

# The `app` method is needed by rack-test
module ChefAppHelper
  def app
    ChefApp
  end
end

World(Rack::Test::Methods, Wrong, ChefAppHelper)
