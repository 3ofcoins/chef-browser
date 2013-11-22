_lib = File.realpath(File.join(File.dirname(__FILE__), '../../lib'))
$:.unshift(_lib) unless $:.include?(_lib)

ENV['CHEF_BROWSER_SETTINGS'] = File.expand_path(File.join(File.dirname(__FILE__),
    '../fixtures/settings.rb'))
ENV['CHEF_ZERO_PORT'] ||= '4001'

require 'chef-browser'

require 'capybara/cucumber'
require 'capybara/webkit'

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
    $stderr.puts "Invalid HTML:\n\n#{lines.join}\n\n#{resp.body}"
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

Capybara.javascript_driver = :webkit

require 'wrong'
World(Wrong)
