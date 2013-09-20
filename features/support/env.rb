require 'rack/test'
require 'wrong'

_lib = File.realpath(File.join(File.dirname(__FILE__), '../../lib'))
$:.unshift(_lib) unless $:.include?(_lib)

require 'chef-browser'

# The `app` method is needed by rack-test
module ChefBrowser
  module SpecHelper
    def app
      App
    end
  end
end

World(Rack::Test::Methods, Wrong, ChefBrowser::SpecHelper)
