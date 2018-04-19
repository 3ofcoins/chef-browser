# frozen_string_literal: true

$rack_app = ChefBrowser::App

if ENV['RACK_SCRIPT_PATH']
  $rack_script_path = ENV['RACK_SCRIPT_PATH'].sub(/\/*$/, '')
  $rack_app = Rack::URLMap.new($rack_script_path => $rack_app)
end

if ENV['VALIDATE_HTML']
  app_before_validate = $rack_app
  $rack_app = lambda do |env|
    resp = app_before_validate.call(env)
    resp[2] = [resp[2].join]
    validate_html(resp[2].first) if resp[0] == 200 && resp[1]['Content-Type'] =~ /^text\/html\s*(;.*)?$/
    resp
  end
end

Capybara.app = $rack_app
