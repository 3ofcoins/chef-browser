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

Scenario: Wrong resource list url returns a 404 error
  When I visit "/roless"
  Then this page doesn't exist

Scenario: List roles
  When I visit "/roles"
  Then I can see "one-role"
  And I can see "another-role"

Scenario: Visiting a non-existing role returns a 404 error
  When I visit "/role/one-rolee"
  Then this page doesn't exist
