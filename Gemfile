source 'https://rubygems.org'

gem "sinatra"
gem "haml"
gem "app"
gem "erubis", "~> 2.7.0"
gem "bootstrap-sass"
gem "ridley"
gem "tinyconfig", git: "https://github.com/3ofcoins/tinyconfig.git", branch: "develop"
gem "puma"

group :development do
  gem "capybara"
  gem "capybara-webkit" # if `bundle install` throws a Gem::Installer::ExtensionBuildError
                        # when installing 'capybara-webkit', follow these instructions:
                        # https://github.com/thoughtbot/capybara-webkit/wiki/Installing-Qt-and-compiling-capybara-webkit
  gem "chef-zero"
  gem "cucumber"
  gem "rack-test"
  gem "wrong", git: "https://github.com/sconover/wrong.git"
  gem "pry"
end
