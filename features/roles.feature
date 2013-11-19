Feature: Browse roles

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

Scenario: List roles
  When I visit "/roles"
  Then I can see "one-role"
  And I can see "another-role"
