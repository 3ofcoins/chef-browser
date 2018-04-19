# frozen_string_literal: true

server_url "http://127.0.0.1:#{::ENV['CHEF_ZERO_PORT']}"
client_name "stub"
client_key ::File.join(::File.dirname(__FILE__), 'stub.pem')
node_search['Database tag'] = 'tags:db'
