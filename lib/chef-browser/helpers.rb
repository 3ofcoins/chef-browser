# frozen_string_literal: true

require 'chef-browser/app'

module ChefBrowser
  module Helpers
    COOKBOOK_FILE_TYPES = %w[attributes templates files definitions resources providers libraries]
                          .map(&:freeze).freeze

    def chef_server
      @chef_server ||= settings.rb.ridley
    end

    def authorized?
      session[:authorized]
    end

    def logout
      session[:authorized] = false
    end

    def verify_none?
      settings.rb.connection[:ssl] && settings.rb.connection[:ssl][:verify] == false
    end

    def uri_options
      if verify_none?
        { ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE }
      else
        {}
      end
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
    def with_jsonpath(obj, prefix = '$', &block)
      case obj
      when Array
        obj.each_with_index do |value, index|
          with_jsonpath(value, "#{prefix}[#{index}]", &block)
        end
      when Hash
        obj.each do |key, value|
          with_jsonpath(value, "#{prefix}.#{key}", &block)
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

    def search_query
      @search_query || params['q']
      @search_query ||= (params['q']&.strip)
    end

    def map_resource(results, resource, data_bag = nil)
      case resource
      when :node        then results
      when :role        then results.map { |attrs| Ridley::RoleObject.new(nil, attrs["data"]) }
      when :environment then results.map { |attrs| Ridley::EnvironmentObject.new(nil, attrs["data"]) }
      else                   results.map { |attrs| Ridley::DataBagItemObject.new(nil, data_bag, attrs["data"]) }
      end
    end

    def search(search_query, resource, data_bag = nil)
      unless search_query[':']
        search_query = "tags:*#{search_query}* OR roles:*#{search_query}* OR \
                        fqdn:*#{search_query}* OR addresses:*#{search_query}*"
      end
      if settings.rb.use_partial_search
        resource = data_bag.chef_id if data_bag
        results = chef_server.partial_search(resource, search_query, %w[chef_type name id])
        map_resource(results, resource, data_bag)
      elsif data_bag
        # For data bag search, Ridley returns untyped Hashie::Mash,
        # we want to augment it with our methods.
        chef_server.search(data_bag.chef_id, search_query).map do |attrs|
          Ridley::DataBagItemObject.new(nil, data_bag, attrs[:raw_data])
        end
      else
        chef_server.search(resource, search_query)
      end
    end

    def resource_list(resource, data_bag = nil)
      if search_query && resource != :data_bag
        @title << search_query
        resources = search(search_query, resource, data_bag)
      elsif data_bag
        resources = data_bag.item.all
      else
        resources = chef_server.send(resource).all
      end
      erb :resource_list, locals: { resources: resources, data_bag: data_bag }
    end

    def pretty_metadata(key, value)
      case key
      when 'long_description' then GitHub::Markup.render_s(GitHub::Markups::MARKUP_MARKDOWN, value)
      when 'attributes' then nil
      when 'maintainer_email'
        "<dt>#{key.capitalize.tr('_', ' ')}:</dt><dd><a href='mailto:#{value}'>#{value}</a><dd>"
      when 'issues_url', 'source_url'
        "<dt>#{key.capitalize.tr('_', ' ')}:</dt><dd><a href='#{value}'>#{value}</a><dd>"
      when 'platforms', 'dependencies', 'suggestions', 'conflicting',
           'replacing', 'providing', 'recipes', 'recommendations', 'groupings'
        unless value.empty?
          list = +"<dt>#{key.capitalize}:</dt><dd><ul class='list-unstyled'>"
          value.sort.each do |name, description|
            list << "<li>#{name}: #{description}</li>"
          end
          list << '</ul></dd>'
        end
      else "<dt>#{key.capitalize}:</dt><dd>#{value}</dd>"
      end
    end

    COOKBOOK_RX = /^(.*)-([0-9\.]+)$/
    def cookbook
      @cookbook ||=
        begin
          halt 404 unless params[:cookbook] =~ COOKBOOK_RX
          cookbook = chef_server.cookbook.find(Regexp.last_match[1], Regexp.last_match[2])
          halt 404 unless cookbook
          @title << cookbook.name
          cookbook
        end
    end

    def cookbook_versions
      chef_server.cookbook.versions(cookbook.chef_id).sort_by { |version| Semverse::Version.new(version) }.reverse
    end

    COOKBOOK_FILE_TYPE_RX = /^(?:(#{Regexp.union('recipes', *COOKBOOK_FILE_TYPES)})\/)?/
    def cookbook_file
      @cookbook_file ||=
        begin
          path = params[:splat].first
          file_type = COOKBOOK_FILE_TYPE_RX.match(path)[1] || 'root_files'
          file = cookbook.send(file_type).find { |f| f.path == path }
          halt 404 unless file
          file.type = file_type
          file
        end
    end

    def cookbook_file?
      !@cookbook_file.nil?
    end

    def run_list_helper(run_list_element)
      if run_list_element.include?("role[")
        "<a href='#{url("/role/#{run_list_element.gsub('role[', '').chop}")}'>#{run_list_element}</a>"
      elsif run_list_element.include?("recipe[")
        run_list_element =~ if run_list_element.include? "::"
                              /\[(.*)::(.*)\]/
                            else
                              /\[(.*)\]/
                            end
        name = Regexp.last_match[1]
        recipe = Regexp.last_match[2]
        version = (chef_server.cookbook.all[name]&.first) || nil
        if version
          "<a href='#{url("/cookbook/#{name}-#{version}/recipes/#{recipe || 'default'}.rb")}'>#{run_list_element}</a>"
        else
          "<a href='#{url('/cookbooks')}'>#{run_list_element}</a>"
        end
      else
        run_list_element
      end
    end
  end
end
