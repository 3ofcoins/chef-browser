_lib = File.realpath(File.join(File.dirname(__FILE__), '../../lib'))
$:.unshift(_lib) unless $:.include?(_lib)

ENV['CHEF_BROWSER_SETTINGS'] = File.expand_path(File.join(File.dirname(__FILE__),
    '../fixtures/settings.rb'))
ENV['CHEF_ZERO_PORT'] ||= '4001'

# `celluloid/test` needs to be required before chef-browser to prevent
# initializing Celluloid with its at_exit handlers by importing
# Celluloid from Ridley from Chef Browser.
require 'celluloid/test'

# `mime/types` needs to be required separately before Capybara,
# because for some reason if it's required by regular chain of imports
# from within Capybara, it blows up JRuby 1.7.8 with
# NullPointerException. Can't figure out why, let's just cargo cult
# the import here.
require 'mime/types'

require 'chef-browser'

require 'capybara/cucumber'

require 'net/http'

# Raise exception if `html_str` is not valid HTML according to
# http://html5.validator.nu/
def validate_html(html_str)
  resp = Net::HTTP.start('html5.validator.nu') do |http|
    http.post '/?out=text', html_str, { 'Content-Type' => 'text/html; charset=utf-8' }
  end
  resp.value                    # raise error if not 2xx
  unless resp.body =~ /^The document is valid HTML5/
    lines = []
    html_str.lines.each_with_index do |line, i|
      lines << "#{i+1}\t#{line}"
    end
    $stderr.puts "Invalid HTML:\n\n#{lines.join}\n\n#{resp.body.force_encoding('utf-8')}"
    raise "Invalid HTML"
  end
end

if ENV['VALIDATE_HTML']
  Capybara.app = lambda do |env|
    resp = ChefBrowser::App.call(env)
    resp[2] = [ resp[2].join ]
    validate_html(resp[2].first) if resp[0] == 200 && resp[1]['Content-Type'] =~ /^text\/html\s*(;.*)?$/
    resp
  end
else
  Capybara.app = ChefBrowser::App
end

require 'wrong'
World(Wrong)

Celluloid.boot
