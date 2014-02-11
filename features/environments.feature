Feature: Browse environments

Background:
  Given a Chef server populated with following data:
    """json
      {
        "environments": {
          "_default": {
            "chef_type": "environment",
            "name": "_default",
            "default_attributes": {
              "First": "A",
              "Second": "B"
            }
          },
          "some-environment": {
            "chef_type": "environment",
            "name": "some-environment",
            "default_attributes": {
              "third" : "c", 
              "fourth": "d"
            },
            "override_attributes": {
              "fifth": "e",
              "sixth": "f"
            },
            "cookbook_versions": {
              "cookbook1": "version1",
              "cookbook2": "version2"
            }
          }
        }
      }
    """

Scenario: Wrong resource list url returns a 404 error
  When I visit "/environmentss"
  Then this page doesn't exist

Scenario: List environments
  When I visit "/environments"
  Then I can see "some-environment"
  And I can see "_default"

Scenario: Selecting an environment
  When I visit "/environments"
  And I click on "some-environment"
  Then I am at "/environment/some-environment"

Scenario: Visiting a non-existing environment returns a 404 error
  When I visit "/environment/some-environmentt"
  Then this page doesn't exist
