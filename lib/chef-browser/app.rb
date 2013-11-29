require 'erubis'
require 'sinatra'
require 'ridley'

require 'chef-browser/ridley_ext'
require 'chef-browser/settings'

module ChefBrowser
  class App < Sinatra::Base
    include Erubis::XmlHelper

    # Triples of [ title, list URL, item URL ]
    SECTIONS = [
      [ 'Nodes',        '/nodes',        '/node' ],
      [ 'Environments', '/environments', '/environment' ],
      [ 'Roles',        '/roles',        '/role' ],
      [ 'Data Bags',    '/data_bags',    '/data_bag' ]
    ]

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

    def resource_list(resource, data_bag_id=nil)
      if params['q'] && resource != :data_bag
        @title << params['q']
        @search_query = params['q']
        if data_bag_id
          # For data bag search, Ridley returns untyped Hashie::Mash, we want to augment it with our methods.
          data_bag = chef_server.data_bag.find(data_bag_id)
          resources = chef_server.search(data_bag_id, params['q']).map { |attrs| Ridley::DataBagItemObject.new(nil, data_bag, attrs[:raw_data]) }
        else
          resources = chef_server.search(resource, params['q'])
        end
      elsif data_bag_id
        resources = chef_server.data_bag.find(data_bag_id).item.all
      else
        resources = chef_server.send(resource).all
      end
      erb :resource_list, locals: { resources: resources.sort, data_bag_id: data_bag_id }
    end

    ##
    ## Filters
    ## -------

    before do
      @title = [ "Chef Browser" ]
    end

    SECTIONS.each do |section, list_route, item_route|
      before "#{item_route}*" do
        @search_url = list_route unless section == 'Data Bags' # Data bags are special.
        @search_for = section
        @title << section
        @section = section
      end
    end

    before "/data_bag/:data_bag_id*" do
      @search_url = "/data_bag/#{params[:data_bag_id]}"
      @search_for = params[:data_bag_id]
      @title << params[:data_bag_id]
    end

    settings.rb.node_search.each_pair do |search_name, query|
      before "/nodes/#{search_name}" do
        @search_url = '/nodes'
        @search_for = query
        @section = 'Nodes'
      end
    end

    ##
    ## Views
    ## -----

    get '/' do
      redirect '/nodes'
    end

    get '/nodes/?' do
      resource_list :node
    end

    get '/roles/?' do
      resource_list :role
    end

    get '/environments/?' do
      resource_list :environment
    end

    get '/data_bags/?' do
      resource_list :data_bag
    end

    get '/data_bag/:data_bag_id/?' do
      resource_list :data_bag_item, params[:data_bag_id]
    end

    get '/node/:node_name/?' do
      node = chef_server.node.find(params[:node_name])
      @title << params[:node_name]
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

    get '/environment/:env_name/?' do
      environment = chef_server.environment.find(params[:env_name])
      @title << params[:env_name]
      erb :environment, locals: { environment: environment }
    end

    get '/data_bag/:data_bag_id/:data_bag_item_id/?' do
      @title << params[:data_bag_item_id]
      data_bag_item = chef_server.data_bag.find(params[:data_bag_id]).item.find(params[:data_bag_item_id])
      erb :data_bag_item, locals: { data_bag_item: data_bag_item }
    end

    get '/role/:role_id/?' do
      @title << params[:role_id]
      role = chef_server.role.find(params[:role_id])
      erb :role, locals: { role: role }
    end

    get "/nodes/:search_name" do
      pass unless settings.rb.node_search.include?(::URI::decode_www_form_component(params[:search_name]))
      params['q'] = @search_for
      resource_list :node
    end
  end
end
