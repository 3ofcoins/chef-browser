chef-browser
============

Easily browse through Chef data in a user-friendly format using your favorite browser. Chef-browser allows you to list nodes and data bags as well as view their details: basic information plus pre-formatted JSON data.

## Installation

To install chef-browser, run:

```
$ bundle install
```

## Usage

Start by configuring your server settings. Open `lib/chef-browser/settings.rb` and edit the following lines, providing your server url, client name and the path to the client key:

```ruby
module ChefBrowser
  class Settings < TinyConfig
    #use option method to define known options
    option :server_url, 'https://127.0.0.1'
    option :client_name, 'chef-webui'
    option :client_key, '/etc/chef-server/chef-webui.pem'
    option :connection, {}
  end
end
```

You can add additional connection options, but that's not necessary to run chef-browser properly. A full list of available options can be found in Ridley's [yard documentation](http://rubydoc.info/gems/ridley/Ridley/Client:initialize).

Run:

```
$ rackup config.ru
```

Go to https://127.0.0.1.

## Accessible data

Right now chef-browser allows you to access the following:
- nodes available on your server,
- details of each node:
    - name, ip address, fqdn, environment, tags, run list,
    - attributes presented using JSONpath in a handy table,
- data bags,
- data bag items with their attributes presented using JSONpath.

## Third party

Chef-browser is a Sinatra-based app. It uses [Ridley](http://github.com/RiotGames/ridley) to communicate with the Chef server. Handling configuration settings is done using the [Tinyconfig](http://github.com/3ofcoins/tinyconfig/) library. CSS & Javascript are provided by Twitter's Bootstrap.

## Safety

Any safety precautions are left on the side of the user. Chef browser is a minimal app that does not provide additional safety-enhancing features apart from what's built in Ridley.

## Ruby versions

Chef-browser works with Ruby 2.0.0.
