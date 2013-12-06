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

Scenario: List roles
  When I visit "/roles"
  Then I can see "one-role"
  And I can see "another-role"

Scenario: Run List without env_run_lists
  When I visit "/roles"
  And I click on "one-role"
  Then I am at "/role/one-role"
  And I can see "Run List"
  And I can see "recipe[default]"
  And I can't see "Default"

Scenario: Role has env_run_lists
  When I visit "/role/another-role"
  Then I can see "Run List"
  And I can see "Default"
  And I can see "Env1"
  And I can see "recipe[uuu]"

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
