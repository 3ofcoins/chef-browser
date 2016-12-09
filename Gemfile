source 'https://rubygems.org'

gem "sinatra"
gem "erubis", "~> 2.7.0"
gem "ridley"
gem "tinyconfig", "~> 0.1"
gem "oj", platforms: :ruby         # to be used by multijson
gem "jrjackson", platforms: :jruby # to be used by multijson
gem "puma"
gem "rubysl", "~> 2.0", platforms: :rbx
gem "racc", platforms: :rbx
gem "deep_merge"
gem "kramdown"
gem "github-markup"
gem "coderay"
gem "pygments.rb"
gem "github-linguist", "~> 3.0"
gem 'rugged', '= 0.21.1b2'      # github-linguist specifies (~> 0.21.1b2), but 0.21.4 breaks
gem "buff-extensions", "< 2.0.0"

group :development do
  gem "capybara"
  gem "chef-zero"
  gem "cucumber"
  gem "rack-test"
  gem "wrong", "= 0.7.1"
  gem "pry"
  gem "rubysl-test-unit", "~> 2.0", platforms: :rbx
end

group :test do
  gem "rake"
end
