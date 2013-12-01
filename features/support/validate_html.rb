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
