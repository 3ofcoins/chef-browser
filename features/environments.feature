Feature: Environment details

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

Scenario: List of environments
  When I visit "/environments"
  Then I can see "some-environment"
  And I can see "_default"

Scenario: Table of environment attributes
  When I visit "/environments"
  And I click on "some-environment"
  Then I am at "/environment/some-environment"
  And I see an attribute "$.name" with value "some-environment"

Scenario: Visiting a non-existing environment returns a 404 error
  When I visit "/environment/some-environmentt"
  Then this page doesn't exist
