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
  Then I see an attribute "$.chef_type" with value "environment"
  And I see an attribute "$.name" with value "_default"
