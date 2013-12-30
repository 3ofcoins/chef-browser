@loggedin
Feature: Browse roles

Background:
  Given a Chef server populated with following data:
    """json
      {
        "roles": {
          "one-role": {
            "name": "one-role",
            "description": "A very important role",
            "run_list": ["recipe[default]", "recipe[mysql]", "role[another-role]"]
          },
          "another-role": {
            "name": "another-role",
            "description": "A not-so-important role",
            "run_list": ["recipe[default]", "recipe[mysql]"],
            "env_run_lists": {
              "Env1": ["recipe[mmm]", "recipe[uuu]"],
              "Env2": ["recipe[aaa]"]
            }
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

Scenario: Selecting roles
  When I visit "/roles"
  And I click on "one-role"
  Then I am at "/role/one-role"

Scenario: Visiting a non-existing role returns a 404 error
  When I visit "/role/one-rolee"
  Then this page doesn't exist
