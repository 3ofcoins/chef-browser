require 'bundler/setup'

# Insert `lib/` subdirectory in front of require path
$:.unshift(File.join(File.dirname(__FILE__), 'lib'))

require 'chef-browser'

run ChefBrowser::App.new
