@loggedin
Feature: Role details

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
          },
          "third-role": {
            "name": "third-role",
            "description": "A third role",
            "env_run_lists": {
              "Env1": ["recipe[ddd]", "recipe[bbb]"],
              "Env2": ["recipe[fff]"]
            }
          }
        }
      }
    """

Scenario: Run List without env_run_lists
  When I visit "/role/one-role"
  And I can see "Run List"
  And I can see "recipe[default]"
  And I can't see "Default"

Scenario: Role has run list and env_run_lists
  When I visit "/role/another-role"
  Then I can see "Run List"
  And I can see "Default"
  And I can see "Env1"
  And I can see "recipe[uuu]"

Scenario: Role has only env_run_lists
  When I visit "/role/third-role"
  Then I can see "Run List"
  And I can't see "Default"
  And I can see "recipe[ddd]"
  And I click on "Env2"
  Then I can see "recipe[fff]"

Scenario: Clickable tabs
  When I visit "/role/another-role"
  And I click on "Env1"
  Then I am at "/role/another-role"
  Then I can see "recipe[mmm]"
  And I can see "recipe[uuu]"

Scenario: Linking to other roles
  When I visit "/role/one-role"
  And I click on "role[another-role]"
  Then I am at "/role/another-role"
  And I can see "recipe[default]"
