module Ridley
  class ChefObject
    def url
      "#{url_prefix}/#{chef_id}"
    end

    def url_prefix
      "/#{chef_type}"
    end
  end

  class DataBagObject
    def url_prefix
      'data_bag'
    end
  end

  class DataBagItemObject
    def url_prefix
      data_bag.url
    end
  end
end
