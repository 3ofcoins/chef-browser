chef-browser
============

Easily browse through Chef data in a user-friendly format using your favorite browser. Chef-browser allows you to list nodes and data bags for your server as well as view their details: basic information plus pre-formatted JSON data.

## Usage ##

1. Run `$ bundle install`.
2. Configure your server settings. Open `lib/chef-browser/settings.rb` and edit the following lines, providing your server url, client name and the client key:

```ruby
    option :server_url, 'https://127.0.0.1'
    option :client_name, 'chef-webui'
    option :client_key, '/etc/chef-server/chef-webui.pem'
    option :connection, {}
```

3. Run `$ rackup config.ru`.
4. Go to http://localhost:9292.

## Accessible information ##

Right now chef-browser allows you to access the following data in a user-friendly format:
- a list of nodes available on your server,
- details of each node: name, ip address, fqdn, environment, tags, run list and JSON attributes,
- a list of data bags available on your server,
- a list of environments.

## Ruby versions ##

Chef-browser works with Ruby 2.0.0.
