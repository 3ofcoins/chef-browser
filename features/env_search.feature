Feature: Environment search

Background:
  Given a Chef server populated with following data:
    """json
      {
        "environments": {
          "_default": {
            "chef_type": "environment",
            "name": "_default",
            "attributes": ["First", "Second"]
          },
          "some-environment": {
            "chef_type": "environment",
            "name": "some-environment",
            "attributes": ["Third", "Fourth"]
          }
        }
      }
    """

Scenario: Search results
  When I visit "/environments"
  And I search for "name:_default"
  And I press "Search"
  Then I am at "/environments"
  And I can see "name:_default"
  And I can see "1 environment found"

Scenario: No search results found
  When I visit "/environments"
  And I search for "name:special"
  And I press "Search"
  Then I am at "/environments"
  And I can see "No matching results found"
