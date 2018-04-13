# frozen_string_literal: true

# require 'bundler/setup'

# Insert `lib/` subdirectory in front of require path
libfolder = File.join(File.dirname(__FILE__), 'lib')
$LOAD_PATH.unshift(libfolder) unless $LOAD_PATH.include?(libfolder)

require 'chef-browser'

run ChefBrowser::App.new
