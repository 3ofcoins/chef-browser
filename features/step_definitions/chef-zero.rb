# frozen_string_literal: true

require 'json'

Given(/^a Chef server populated with following data:$/) do |json_data|
  $chef_zero.load_data(JSON[json_data])
end
