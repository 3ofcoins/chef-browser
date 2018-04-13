# frozen_string_literal: true

source 'https://rubygems.org'

gem "coderay"
gem "deep_merge"
gem "erubis", "~> 2.7.0"
gem "github-linguist", "~> 3.0"
gem "github-markup"
gem "jrjackson", platforms: :jruby # to be used by multijson
gem "kramdown"
gem "oj", platforms: :ruby         # to be used by multijson
gem "puma"
gem "pygments.rb"
gem "racc", platforms: :rbx
gem "ridley", "~> 5.1.1"
gem "rubysl", "~> 2.0", platforms: :rbx
gem 'rugged', '= 0.21.1b2' # github-linguist specifies (~> 0.21.1b2), but 0.21.4 breaks
gem "sinatra"
gem "tinyconfig", "~> 0.1"

group :development do
  gem "capybara"
  gem "chef-zero", "~> 14.0.0"
  gem "cucumber"
  gem "ffi"
  gem "pry"
  gem "rack-test"
  gem "rubocop"
  gem "rubysl-test-unit", "~> 2.0", platforms: :rbx
  gem "wrong", "= 0.7.1"
end

group :test do
  gem "rake"
end
