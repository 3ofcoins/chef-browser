require 'erubis'
require 'sinatra'
require 'ridley'
require 'deep_merge'

require 'chef-browser/ridley_ext'
require 'chef-browser/settings'
require 'chef-browser/version'

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

    use Rack::Session::Cookie, expire_after: settings.rb.cookie_time,
                               secret: settings.rb.cookie_secret
    ##
    ## Helpers
    ## -------

    def chef_server
      @chef_server ||= settings.rb.ridley
    end

    def authorized?
      session[:authorized]
    end

    def logout
      session[:authorized] = false
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
      when false   then '<span class="label label-warning">false</span>'
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

    def resource_list(resource, data_bag=nil)
      if search_query && resource != :data_bag
        @title << search_query
        raw_query = search_query
        raw_query = "tags:*#{raw_query}* OR roles:*#{raw_query}* OR fqdn:*#{raw_query}* OR addresses:*#{raw_query}*" unless raw_query[':']
        if data_bag
          # For data bag search, Ridley returns untyped Hashie::Mash, we want to augment it with our methods.
          resources = chef_server.search(data_bag.chef_id, raw_query).map { |attrs| Ridley::DataBagItemObject.new(nil, data_bag, attrs[:raw_data]) }
        else
          resources = chef_server.search(resource, raw_query)
        end
      elsif data_bag
        resources = data_bag.item.all
      else
        resources = chef_server.send(resource).all
      end
      erb :resource_list, locals: { resources: resources, data_bag: data_bag }
    end

    def search_query
      @search_query || params['q']
      @search_query ||= ( params['q'] && params['q'].strip )
    end

    def search(search_query, resource, data_bag=nil)
      if settings.rb.use_partial_search
        resource = data_bag.chef_id if data_bag
        results = chef_server.partial_search(resource, search_query, ["chef_type", "name", "id"])
        case resource
        when :node        then results
        when :role        then results.map { |attrs| Ridley::RoleObject.new(nil, attrs["data"]) }
        when :environment then results.map { |attrs| Ridley::EnvironmentObject.new(nil, attrs["data"]) }
        else                   results.map { |attrs| Ridley::DataBagItemObject.new(nil, data_bag, attrs["data"]) }
        end
      else
        if data_bag
          # For data bag search, Ridley returns untyped Hashie::Mash, we want to augment it with our methods.
          resources = chef_server.search(data_bag.chef_id, search_query).map { |attrs| Ridley::DataBagItemObject.new(nil, data_bag, attrs[:raw_data]) }
        else
          chef_server.search(resource, search_query)
        end
      end
    end

    def encrypted?(data_bag_item)
      if data_bag_item.attributes.values.last.is_a?(Hash) && data_bag_item.attributes.values.last.has_key?("cipher")
        true
      end
    end

    ##
    ## Filters
    ## -------

    before do
      @title = [ settings.rb.title ]
      if settings.rb.login
        redirect url '/login' unless authorized? || request.path_info == '/login'
      end
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

    ##
    ## Views
    ## -----

    get '/login' do
      pass unless settings.rb.login
      erb :login_form, layout: :login
    end

    get '/' do
      redirect url '/nodes'
    end

    post '/login' do
      if chef_server.user.authenticate(params['username'], params['password'])
        session[:authorized] = params['username']
        redirect url '/'
      else
        session[:authorized] = false
        erb :not_logged_in, layout: :login
      end
    end

    get '/logout' do
      session[:authorized] = false
      redirect url '/login'
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
      data_bag = chef_server.data_bag.find(params[:data_bag_id])
      pass unless data_bag
      resource_list :data_bag_item, data_bag
    end

    get '/node/:node_name/?' do
      node = chef_server.node.find(params[:node_name])
      pass unless node
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

    get '/environment/:environment_name/?' do
      environment = chef_server.environment.find(params[:environment_name])
      pass unless environment
      @title << params[:environment_name]
      tabs = {}
      tabs['default'] = environment.default_attributes unless Array(environment.default_attributes).empty?
      tabs['override'] = environment.override_attributes unless Array(environment.override_attributes).empty?
      erb :environment, locals: {
        environment: environment,
        tabs: tabs
      }
    end

    get '/data_bag/:data_bag_id/:data_bag_item_id/?' do
      data_bag_item = chef_server.data_bag.find(params[:data_bag_id]).item.find(params[:data_bag_item_id])
      pass unless data_bag_item
      @title << params[:data_bag_item_id]
      erb :data_bag_item, locals: { data_bag_item: data_bag_item, decrypted: false, alert: false }
    end

    post '/data_bag/:data_bag_id/:data_bag_item_id/?' do
      data_bag_item = chef_server.data_bag.find(params[:data_bag_id]).item.find(params[:data_bag_item_id])
      pass unless data_bag_item
      @title << params[:data_bag_item_id]
      if params["key"] != "" || params["upload"] != nil
        pasted = params["key"] unless params["key"] == ""
        file =  File.open(params["upload"][:tempfile]).read if params['upload']
        encrypted_data_bag_secret = pasted || file
        if params['upload'] # let's get rid of this as soon as possible
          params['upload'][:tempfile].close
          params['upload'][:tempfile].unlink
        end
        ::Ridley.open({
          server_url: settings.rb.server_url,
          client_name: settings.rb.client_name,
          client_key: settings.rb.client_key,
          encrypted_data_bag_secret: encrypted_data_bag_secret
          }.merge(settings.rb.connection)) do |server|
          begin
            data_bag_item = server.data_bag.find(params[:data_bag_id]).item.find(params[:data_bag_item_id])
            data_bag_item.decrypt
            erb :data_bag_item, locals: { data_bag_item: data_bag_item, decrypted: true, alert: false }
          rescue OpenSSL::Cipher::CipherError => e
            erb :data_bag_item, locals: { data_bag_item: data_bag_item, decrypted: false, alert: true }
          end
        end
      else
        erb :data_bag_item, locals: { data_bag_item: data_bag_item, decrypted: false, alert: false }
      end
    end

    get '/role/:role_id/?' do
      role = chef_server.role.find(params[:role_id])
      pass unless role
      @title << params[:role_id]
      tabs = {}
      tabs['default'] = role.default_attributes unless Array(role.default_attributes).empty?
      tabs['override'] = role.override_attributes unless Array(role.override_attributes).empty?
      erb :role, locals: {
        role: role,
        tabs: tabs
       }
    end

    get "/nodes/:search_name" do
      @search_query = settings.rb.node_search[::URI::decode_www_form_component(params[:search_name])]
      pass unless @search_query
      resource_list :node
    end
  end
end
