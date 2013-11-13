require 'erubis'
require 'sinatra'
require 'ridley'

require 'chef-browser/settings'

module ChefBrowser
  class App < Sinatra::Base
    include Erubis::XmlHelper

    set :erb, :escape_html => true
    set :root, File.expand_path(File.join(File.dirname(__FILE__), '../..'))

    # It's named this way to have variables from the `settings.rb` file
    # visible from inside the app as `settings.rb.setting_name`
    set :rb, begin
               settings_path = ENV['CHEF_BROWSER_SETTINGS'] ?
                 File.expand_path(ENV['CHEF_BROWSER_SETTINGS']) :
                   File.join(settings.root, 'settings.rb')
               settings_rb = Settings.new
               settings_rb.load(settings_path)
               settings_rb
             end

    def chef_server
      @chef_server ||= settings.rb.ridley
    end

    # This method takes any nested hash/array `obj`, and then
    # calls provided block with two arguments:
    # each value's jsonpath selector, and the value itself.
    #
    # Example:
    #   with_jsonpath({'foo' => {'bar' => 23, 'baz' => -1}, 'xyzzy' => [5,4,3,2]}) { |k, v| p [k, v] }
    # will print:
    #   ["$.foo.bar", 23]
    #   ["$.foo.baz", -1]
    #   ["$.xyzzy[5]", 0]
    #   ["$.xyzzy[4]", 1]
    #   ["$.xyzzy[3]", 2]
    #   ["$.xyzzy[2]", 3]
    def with_jsonpath(obj, prefix='$', &block)
      case obj
      when Array
        obj.each_with_index do |v, i|
          with_jsonpath(v, "#{prefix}[#{i}]", &block)
        end
      when Hash
        obj.each do |k, v|
          with_jsonpath(v, "#{prefix}.#{k}", &block)
        end
      else
        yield prefix, obj
      end
    end

    def pretty_value(value)
      case value
      when true    then '<span class="label label-success">true</span>'
      when false   then '<span class="label label-important">false</span>'
      when nil     then '<em class="text-muted">nil</em>'
      when Numeric then value.to_s
      when String
        if value.include?("\n") || value.length > 150
          "<pre>#{html_escape(value)}</pre>"
        else
          "<code>#{html_escape(value.to_json)}</code>"
        end
      else
        "<code>#{html_escape(value.to_json)}</code>"
      end
    end

    get '/' do
      redirect '/nodes'
    end

    get '/nodes' do
      search_query = params["q"]
      if search_query.blank?
        erb :node_list, locals: {
          nodes: chef_server.node.all.sort,
          search_query: search_query
        }
      else
        search_results = chef_server.search(:node, search_query).sort_by {|k| k[:name]}
        erb :node_search, locals: {
          search_query: search_query,
          search_results: search_results
        }
      end
    end

    get '/node/:node_name' do
      node = chef_server.node.find(params[:node_name])
      merged_attributes = node.chef_attributes
      erb :node, locals: {
        node: node,
        attributes: merged_attributes,
        tabs: {
          'merged' => merged_attributes,
          'default' => node[:default],
          'normal' => node[:normal],
          'override' => node[:override],
          'automatic' => node[:automatic],
          'full' => node._attributes_
        },
        active_tab: 'merged'
      }
    end

    get '/environments' do
      environments = chef_server.environment.all
      erb :environment_list, locals: {
        environments: environments
      }
    end

    get '/environment/:env_name' do
      environment = chef_server.environment.find(params[:env_name])
      erb :environment, locals: {
        environment: environment
      }
    end

    get '/data_bags' do
      bags = chef_server.data_bag
      erb :data_bag_list, locals: {
        bags: bags
      }
    end

    get '/data_bag/:data_bag_id' do
      search_query = params["q"]
      data_bag = params[:data_bag_id]
      bags = chef_server.data_bag
      if search_query.blank?
        erb :data_bag, locals: {
          data_bag: data_bag,
          bags: bags
        }
      else
        search_results = chef_server.search(data_bag, search_query).sort_by {|k| k[:name]}
        erb :data_search, locals: {
          search_query: search_query,
          search_results: search_results,
          data_bag: data_bag
        }
      end
    end

    get '/data_bag/:data_bag_id/:data_bag_item_id' do
      data_bag = params[:data_bag_id]
      data_bag_item = chef_server.data_bag.find(data_bag).item.find(params[:data_bag_item_id])
      erb :data_bag_item, locals: {
        data_bag: data_bag,
        data_bag_item: data_bag_item
      }
    end

    get '/roles' do
      search_query = params["q"]
      roles = chef_server.role.all
      erb :role_list, locals: {
        roles: roles
      }
    end

    get '/role/:role_id' do
      role = chef_server.role.find(params[:role_id])
      erb :role, locals: {
        role: role
      }
    end
  end
end
