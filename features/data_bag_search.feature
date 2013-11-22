@javascript @search
Feature: Data bag search

Background:
  Given a Chef server populated with following data:
    """json
      {
        "data": {
          "some-data-bag": {
              "first-data-bag-item": {
                "name": "first-data-bag-item",
                "actions": ["add", "remove"]
              },
              "second-data-bag-item": {
                "name": "second-data-bag-item"
              }
          },
          "another-data-bag": {
            "another-data-bag-item": {
              "name": "another-data-bag-item"
            }
          }
        }
      }
    """

Scenario: Search results
  When I visit "/data_bag/some-data-bag"
  And I search for "name:first*"
  Then I am at "/data_bag/some-data-bag"
  And I can see "Search results (1)"

Scenario: No search results found
  When I visit "/data_bag/some-data-bag"
  And I search for "name:third*"
  Then I am at "/data_bag/some-data-bag"
  And I can see "No matching results found"
