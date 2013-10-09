chef-browser
============

Easily browse through Chef data in a user-friendly format using your favorite browser. Chef-browser allows you to list nodes and data bags as well as view their details: basic information plus pre-formatted JSON data.

Chef-browser uses Ridley (http://github.com/RiotGames/ridley) to communicate with the Chef server & Twitter Bootstrap for css & Javascript.

## Usage ##

1. Run `$ bundle install`.
2. Configure your server settings. Open `lib/chef-browser/settings.rb` and edit the following lines, providing your server url, client name and the client key:

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

You can add additional connection options, but that's not necessary to run chef-browser properly.

3. Run `$ rackup config.ru`.
4. Go to https://127.0.0.1.

## Accessible data ##

Right now chef-browser allows you to browse the following:
- nodes available on your server,
- details of each node:
    - name, ip address, fqdn, environment, tags, run list,
    - its attributes presented using JSONpath in a handy table,
- data bags,
- data bag items with their attributes presented using JSONpath.

## Ruby versions ##

Chef-browser works with Ruby 2.0.0.
