require 'chef-browser/app'

module ChefBrowser
  class App < Sinatra::Base

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
    def with_jsonpath(obj, prefix = '$', &block)
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

    def search_query
      @search_query || params['q']
      @search_query ||= (params['q'] && params['q'].strip)
    end

    def search(search_query, resource, data_bag = nil)
      search_query = "tags:*#{search_query}* OR roles:*#{search_query}* OR fqdn:*#{search_query}* OR addresses:*#{search_query}*" unless search_query[':']
      if settings.rb.use_partial_search
        resource = data_bag.chef_id if data_bag
        results = chef_server.partial_search(resource, search_query, %w(chef_type name id))
        case resource
        when :node        then results
        when :role        then results.map { |attrs| Ridley::RoleObject.new(nil, attrs["data"]) }
        when :environment then results.map { |attrs| Ridley::EnvironmentObject.new(nil, attrs["data"]) }
        else                   results.map { |attrs| Ridley::DataBagItemObject.new(nil, data_bag, attrs["data"]) }
        end
      else
        if data_bag
          # For data bag search, Ridley returns untyped Hashie::Mash,
          # we want to augment it with our methods.
          chef_server.search(data_bag.chef_id, search_query).map { |attrs| Ridley::DataBagItemObject.new(nil, data_bag, attrs[:raw_data]) }
        else
          chef_server.search(resource, search_query)
        end
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
      when 'long_description' then GitHub::Markup.render('README.md', value)
      when 'attributes' then nil
      when 'maintainer_email' then "<dt>#{key.capitalize.gsub('_', ' ')}:</dt><dd><a href='mailto:#{value}'>#{value}</a><dd>"
      when 'platforms', 'dependencies', 'suggestions', 'conflicting', 'replacing', 'providing', 'recipes', 'recommendations', 'groupings'
        unless value.empty?
          list = "<dt>#{key.capitalize}:</dt><dd><ul class='list-unstyled'>"
          value.sort.each do |name, description|
            list << "<li>#{name}: #{description}</li>"
          end
          list << '</ul></dd>'
        end
      else "<dt>#{key.capitalize}:</dt><dd>#{value}</dd>"
      end
    end

    # returns a Hashie::Mash
    def find_file(file_name, file_type, cookbook)
      cookbook.send(file_type).each do |candidate|
        return candidate if candidate.name[file_name]
      end
    end

    def run_list_helper(run_list)
      if run_list.include? "role["
        "<a href='#{url("/role/#{run_list.gsub('role[', '').chop}")}'>#{run_list}</a>"
      elsif run_list.include? "recipe["
        if run_list.include? "::"
          run_list =~ /\[(.*)::(.*)\]/
        else
          run_list =~ /\[(.*)\]/
        end
        name = Regexp.last_match[1]
        recipe = Regexp.last_match[2]
        version = (chef_server.cookbook.all[name].first unless chef_server.cookbook.all[name].nil?) || nil
        if version
          "<a href='#{url("/cookbook/#{name}-#{version}/recipe/#{recipe || 'default'}.rb")}'>#{run_list}</a>"
        else
          "<a href='#{url("/cookbooks")}'>#{run_list}</a>"
        end
      else
        run_list
      end
    end
  end
end
