Feature: Role search

Background:
  Given a Chef server populated with following data:
    """json
      {
        "roles": {
          "one-role": {
            "name": "one-role",
            "description": "A very important role",
            "run_list": ["recipe[default]", "recipe[mysql]"]
          },
          "another-role": {
            "name": "another-role",
            "description": "A not-so-important role",
            "run_list": ["recipe[default]", "recipe[mysql]"]
          }
        }
      }
    """

Scenario: Search results
  When I visit "/roles"
  And I search for "name:one"
  And I press "Search"
  Then I am at "/roles"
  And I can see "name:one"
  And I can see "1 role found"

Scenario: No search results found
  When I visit "/roles"
  And I search for "name:third*"
  And I press "Search"
  Then I am at "/roles"
  And I can see "No matching results found"
