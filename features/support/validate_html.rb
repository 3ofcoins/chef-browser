# frozen_string_literal: true

require 'net/http'

# Raise exception if `html_str` is not valid HTML according to
# http://validator.w3.org/nu/
def validate_html(html_str)
  resp = Net::HTTP.start('validator.w3.org') do |http|
    http.post '/nu/?out=text', html_str, 'Content-Type' => 'text/html; charset=utf-8'
  end
  resp.value # raise error if not 2xx
  return if resp.body.rstrip.end_with?("The document validates according to the specified schema(s).")
  lines = []
  html_str.lines.each_with_index { |line, i| lines << "#{i + 1}\t#{line}" }
  warn "Invalid HTML:\n\n#{lines.join}\n\n#{resp.body.force_encoding('utf-8')}"
  raise "Invalid HTML"
end
