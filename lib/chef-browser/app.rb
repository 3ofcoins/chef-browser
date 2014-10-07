require 'erubis'
require 'sinatra'
require 'ridley'
require 'deep_merge'
require 'github/markup'
require 'coderay'
require 'pygments.rb'
require 'linguist'

require 'chef-browser/ridley_ext'
require 'chef-browser/settings'
require 'chef-browser/version'
require 'chef-browser/file-content'
require 'chef-browser/helpers'

module ChefBrowser
  class App < Sinatra::Base
    include Erubis::XmlHelper

    # Triples of [title, list URL, item URL]
    SECTIONS = [
      ['Nodes',        '/nodes',        '/node'],
      ['Environments', '/environments', '/environment'],
      ['Roles',        '/roles',        '/role'],
      ['Data Bags',    '/data_bags',    '/data_bag'],
      ['Cookbooks',    '/cookbooks',    '/cookbook']
    ]

    ##
    ## Settings
    ## --------

    set :erb, escape_html: true
    set :root, Settings.app_root

    # It's named this way to have variables from the `settings.rb` file
    # visible from inside the app as `settings.rb.setting_name`
    set :rb, Settings.load

    use Rack::Session::Cookie, expire_after: settings.rb.cookie_time,
                               secret: settings.rb.cookie_secret

    ##
    ## Filters
    ## -------

    before do
      @title = [settings.rb.title]
      if settings.rb.login
        redirect url '/login' unless authorized? || request.path_info == '/login'
      end
    end

    SECTIONS.each do |section, list_route, item_route|
      before "#{item_route}*" do
        @search_url = list_route unless section == 'Data Bags' || section == 'Cookbooks' # Data bags and Cookbooks are special.
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

    before "download/*" do
      content_type 'application/octet-stream'
    end

    ##
    ## Views
    ## -----

    get '/' do
      redirect url '/nodes'
    end

    get '/login/?' do
      pass unless settings.rb.login
      erb :login_form, layout: :login_layout, locals: { wrong: false }
    end

    post '/login/?' do
      if chef_server.user.authenticate(params['username'], params['password'])
        session[:authorized] = params['username']
        redirect url '/'
      else
        session[:authorized] = false
        erb :login_form, layout: :login_layout, locals: { wrong: true }
      end
    end

    get '/logout/?' do
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
      erb :data_bag_item, locals: { data_bag_item: data_bag_item }
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

    get "/nodes/:search_name/?" do
      @search_query = settings.rb.node_search[::URI.decode_www_form_component(params[:search_name])]
      pass unless @search_query
      resource_list :node
    end

    get "/cookbooks/?" do
      resource_list :cookbook
    end

    # download a cookbook file
    get %r{download/cookbook/(.*)-([0-9]+\.[0-9]+\.[0-9]+)/(.*)/(.*\.*)} do
      cookbook = chef_server.cookbook.find(params[:captures][0], params[:captures][1])
      pass unless cookbook
      if params[:captures][2]['/']
        file_type = params[:captures][2].match(/.*?\//).to_s.chop
      else
        params[:captures][2] == 'recipe' ? file_type = 'recipes' : file_type = params[:captures][2]
      end
      file_name = params[:captures][3]
      file = find_file(file_name, file_type, cookbook)
      pass unless file
      @title << [cookbook.name, params[:captures][2], file_name]
      content = FileContent.new(file.name, file.url, (open(file.url) { |f| f.read }))
      attachment file_name
      content.data
    end

    # cookbook files
    get %r{/cookbook/(.*)-([0-9]+\.[0-9]+\.[0-9]+)/(.*)/(.*\.*)} do
      cookbook = chef_server.cookbook.find(params[:captures][0], params[:captures][1])
      pass unless cookbook
      if params[:captures][2]['/']
        file_type = params[:captures][2].match(/.*?\//).to_s.chop
      else
        params[:captures][2] == 'recipe' ? file_type = 'recipes' : file_type = params[:captures][2]
      end
      file_name = params[:captures][3]
      file = find_file(file_name, file_type, cookbook)
      pass unless file
      @title << [cookbook.name, params[:captures][2], file_name]
      content = FileContent.new(file.name, file.url, (open(file.url) { |f| f.read }))
      extname = File.extname(file_name).downcase
      metadata = cookbook.metadata
      versions = chef_server.cookbook.all[cookbook.chef_id]
      erb :file, layout: :cookbook_layout, locals: {
        cookbook_name: cookbook.chef_id,
        cookbook_version: cookbook.version,
        cookbook: cookbook,
        file_type: file_type,
        file_name: file_name,
        file: file,
        extname: extname,
        content: content,
        metadata: metadata,
        versions: versions
      }
    end

    # single cookbook
    get %r{/cookbook/(.*)-([0-9]+\.[0-9]+\.[0-9]+)/?} do
      cookbook = chef_server.cookbook.find(params[:captures].first, params[:captures].last)
      pass unless cookbook
      @title << cookbook.name
      metadata = cookbook.metadata
      versions = chef_server.cookbook.all[cookbook.chef_id]
      erb :cookbook, layout: :cookbook_layout, locals: {
        cookbook: cookbook,
        metadata: metadata,
        versions: versions,
        basic: %w(maintainer maintainer_email license platforms dependencies recommendations providing suggestions conflicting replacing groupings long_description),
        tabs: %w(metadata files recipes basic),
        file_types: %w(root_files attributes templates files definitions resources providers libraries)
      }
    end
  end
end
