Feature: Data bags page

Scenario: List of data bags
  When I visit "/data_bag_list"
  Then I can see "Data bag items"
