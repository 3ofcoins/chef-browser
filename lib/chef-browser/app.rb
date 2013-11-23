require 'erubis'
require 'sinatra'
require 'ridley'

require 'chef-browser/settings'

module ChefBrowser
  class App < Sinatra::Base
    include Erubis::XmlHelper

    ##
    ## Settings
    ## --------

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

    ##
    ## Helpers
    ## -------

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

    ##
    ## Filters
    ## -------

    { '/node*' => 'Nodes',
      '/role*' => 'Roles',
      '/environment*' => 'Environments' }.each do |route, tab|
      before route do
        @search_url = route.sub('*', 's')
        @search_for = tab
      end
    end

    before "/data_bag/:data_bag_id*" do
      @search_url = "/data_bag/#{params[:data_bag_id]}"
      @search_for = params[:data_bag_id]
    end

    ##
    ## Views
    ## -----

    get '/' do
      redirect '/nodes'
    end

    ['/nodes', '/roles', '/environments'].each do |path| # data bags & data bag items are a special case,
                                                         # so they're treated separately
      get path do
        resource_name = path[1...-1]
        search_query = params["q"]
        if search_query.blank?
          if resource_name == "node"
            resources = chef_server.node.all
          elsif resource_name == "role"
            resources = chef_server.role.all
          elsif resource_name == "environment"
            resources = chef_server.environment.all
          end
          erb :resource_list, locals: {
            resources: resources,
            search_query: search_query,
            resource_name: resource_name,
            resource_id: nil
          }
        else
          search_results = chef_server.search(resource_name.to_sym, search_query).sort_by {|k| k[:name]}
          erb "#{resource_name}_search".to_sym, locals: {
            search_query: search_query,
            search_results: search_results,
            resource_name: resource_name,
            resource_id: nil
          }
        end
      end
    end

    get '/node/:node_name' do
      search_query = params["q"]
      resource_name = "node"
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
        active_tab: 'merged',
        resource_name: resource_name,
        resource_id: params[:node_name],
        search_query: search_query
      }
    end

    get '/environment/:env_name' do
      resource_name = "environment"
      environment = chef_server.environment.find(params[:env_name])
      search_query = params["q"]
      erb :environment, locals: {
        environment: environment,
        resource_name: resource_name,
        resource_id: params[:env_name],
        search_query: search_query
      }
    end

    get '/data_bags' do
      resource_name = "data bags"
      resources = chef_server.data_bag.all.sort
      search_query = params["q"]
      erb :resource_list, locals: {
        resources: resources,
        resource_name: resource_name,
        resource_id: nil,
        search_query: search_query,
      }
    end

    get '/data_bag/:data_bag_id' do
      resource_name = "data bag items"
      search_query = params["q"]
      data_bag = params[:data_bag_id]
      resources = chef_server.data_bag.find(data_bag).item.all.sort
      if search_query.blank?
        erb :resource_list, locals: {
          data_bag: data_bag,
          resources: resources,
          resource_name: resource_name,
          resource_id: params[:data_bag_id],
          search_query: search_query
        }
      else
        search_results = chef_server.search(data_bag, search_query).sort_by {|k| k[:name]}
        erb :data_search, locals: {
          search_query: search_query,
          search_results: search_results,
          data_bag: data_bag,
          resource_name: resource_name,
          resource_id: nil
        }
      end
    end

    get '/data_bag/:data_bag_id/:data_bag_item_id' do
      resource_name = "data bag item"
      data_bag = params[:data_bag_id]
      search_query = params["q"]
      data_bag_item = chef_server.data_bag.find(data_bag).item.find(params[:data_bag_item_id])
      erb :data_bag_item, locals: {
        data_bag: data_bag,
        data_bag_item: data_bag_item,
        resource_name: resource_name,
        resource_id: params[:data_bag_item_id],
        search_query: search_query
      }
    end

    get '/role/:role_id' do
      search_query = params["q"]
      resource_name = "role"
      role = chef_server.role.find(params[:role_id])
      erb :role, locals: {
        role: role,
        resource_name: resource_name,
        resource_id: params[:role_id],
        search_query: search_query
      }
    end
  end
end
