require 'json'

Given(/^a Chef server populated with following data:$/) do |json_data|
  $chef_zero.load_data(JSON[json_data])
end

Given(/^a node is populated with following data:$/) do |node_data|
  $chef_zero.load_data(JSON[node_data])
end
