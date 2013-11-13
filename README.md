chef-browser
============

Easily browse through Chef data in a user-friendly format using your favorite browser. Chef-browser allows you to list nodes and data bags as well as view their details: basic information plus pre-formatted JSON data.

## Installation

To install chef-browser, run:

```
$ bundle install
```

## Usage

Create a settings.rb file. Provide your server url, client name and the path to the client key. You can add additional connection options, but that's not necessary to run chef-browser properly. A full list of available options can be found in Ridley's [yard documentation](http://rubydoc.info/gems/ridley/Ridley/Client:initialize).

Run:

```
$ rackup config.ru
Puma 1.6.3 starting...
* Min threads: 0, max threads: 16
* Environment: development
* Listening on tcp://0.0.0.0:9292
```

Go to http://0.0.0.0:9292.

## Accessible data

Right now chef-browser allows you to access the following:
- nodes available on your server,
- details of each node:
    - name, ip address, fqdn, environment, tags, run list,
    - attributes presented using JSONpath in a handy table,
- data bags,
- data bag items with their attributes presented using JSONpath.

## Third party

Chef-browser is a Sinatra-based app. It uses [Ridley](http://github.com/RiotGames/ridley) to communicate with the Chef server. Handling configuration settings is done using the [Tinyconfig](http://github.com/3ofcoins/tinyconfig/) library. CSS & Javascript are provided by Twitter's Bootstrap. [jQuery.FilterTable](http://github.com/sunnywalker/jQuery.FilterTable) was used to help present data.

## Safety

Any safety precautions are left on the side of the user. Chef browser is a minimal app that does not provide additional safety-enhancing features apart from what's built in Ridley.

## Ruby versions

Chef-browser works with Ruby 1.9.3, Ruby 2.0.0, JRuby and RBX.
