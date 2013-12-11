require 'bundler/setup'

# Insert `lib/` subdirectory in front of require path
_lib = File.join(File.dirname(__FILE__), 'lib')
$:.unshift(_lib) unless $:.include?(_lib)

require 'chef-browser'

run ChefBrowser::App.new
