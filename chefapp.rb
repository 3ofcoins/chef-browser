require 'erubis'
require 'sinatra'
require 'ridley'

class ChefApp < Sinatra::Base
  set :erb, :escape_html => true

  def chef_server
    @chef_server ||= Ridley.new(
      server_url: "http://127.0.0.1:4000",
      client_name: "marta",
      client_key: File.join(File.dirname(__FILE__), 'features/fixtures/stub.pem'))
  end

  get '/' do
    erb :index
  end

  get '/nodes' do
    erb :node_list, locals: {
      nodes: chef_server.node.all,
      environments: chef_server.environment.all
    }
  end

  get '/node' do
    erb :node_details
  end

  get '/data_bags' do
    erb :data_bags
  end

  get '/:node_name' do
  #   take a :node_name and redirect the above URL to a dynamically created page w/the "node" layout,
  #   populated w/ details of the given node. Break it down into smaller steps:
  #     a. create a :node_name redirection & all of the URLs end in the
  #        "uncustomized" erb :node ==> done.
  #     b. remove the redundant array w/ node names; if a wrong node name is passed,
  #        it can be handled via an `if` statement. ==> done: array removed.
  #     C. create a "customized" view of node details in code below. ==> done.
  #     d. handle undefined method `[]' for nil:NilClass (basically = an `if` statement?)
  #     e. extract the code to an erb file (?)

    @nodes = chef_server.node.all
    @node_array = Array.new
    @node_name = request.path.delete "/"
    @nodes.each do |node|
      @node_array.push(node[:name])
    end

    code = %q{
      <h3><%= chef_server.node.find(@node_name)[:name] %></h3>
     <p><%= chef_server.node.find(@node_name)[:automatic][:fqdn] %> (<%= chef_server.node.find(@node_name)[:automatic][:ipaddress] %>)</p>
      <p>Environment: <%= chef_server.node.find(@node_name)[:chef_environment] %></p>
      <p>Tags:<ul class="inline"><% chef_server.node.find(@node_name)[:normal][:tags].each do |tag| %>
         <li><%= tag %></li>
       <% end %>
       </ul></p>
     <h4>Run list:</h4>
       <p><ul><% chef_server.node.find(@node_name)[:run_list].each do |run_list| %>
         <li><%= run_list %></li>
       <% end %>
       </ul></p>
     <h4>Attributes (JSON)</h4>
     <pre class="pre-scrollable"><%= JSON.pretty_generate(chef_server.node.find(@node_name)._attributes_, :indent => "  ", :array_nl => "\n") %></pre>
    }

    erb code
  end
end
