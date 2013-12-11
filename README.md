chef-browser
============

Easily browse through Chef data in a user-friendly format using your favorite browser. Chef-browser allows you to list (and search through) nodes, environments, roles and data bags (and items) as well as view their details: basic information plus pre-formatted JSON data. Shorten the time necessary to access often used information with saved searches.

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

You can define saved searches. To do that, open your settings.rb file and follow this syntax:

```ruby
node_search['MySQL Servers'] = 'mysql_server_root_password:*'
node_search['Staging'] = 'chef_environment:staging'
```

You can define as many saved searches as you like. Your saved searches will appear as a dropdown list next to the search box. Right now this option works only for nodes.

## Accessible data

Chef-browser allows you to access the following:
- nodes, environments, roles and data bags available on your server,
- details of each node:
    - name, ip address, fqdn, environment, tags, run list,
    - attributes presented using JSONpath in a handy, filterable table,
- details of each environment:
    - cookbooks and their versions,
    - default and override attributes,
- details of each role:
    - run lists and env_run_lists (if present),
    - default and override attributes,
- details of bags and data bag items.

Where possible, tags, environment names and role views link to appropriate nodes, while run list elements link to other roles.

## Third party

Chef-browser is a Sinatra-based app. It uses [Ridley](http://github.com/RiotGames/ridley) to communicate with the Chef server. Handling configuration settings is done using the [Tinyconfig](http://github.com/3ofcoins/tinyconfig/) library. CSS & Javascript are provided by Twitter's Bootstrap. [jQuery.FilterTable](http://github.com/sunnywalker/jQuery.FilterTable) was used to help present data.

## Safety

Any safety precautions are left on the side of the user. Chef browser is a minimal app that does not provide additional safety-enhancing features apart from what's built in Ridley.

## Ruby versions

Chef-browser works with Ruby 1.9.3, Ruby 2.0.0, JRuby and RBX.

## Contributing

* Fork the repo.
* Create a branch from the develop branch and name it 'feature/name-of-feature': `git checkout -b feature/my-new-feature` (We follow [this branching model] (http://nvie.com/posts/a-successful-git-branching-model/))
* Make sure you test your new feature.
* Commit your changes together with specs for them: `git commit -am 'Add some feature'`
* Push your changes to your feature branch.
* Submit a pull request to the develop repository. Describe your feature in the pull request. Make sure you commit the specs.
* A pull request does not necessarily need to represent the final, finished feature. Feel free to treat it as a base for discussion.
