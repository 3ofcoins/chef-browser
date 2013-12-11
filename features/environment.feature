Feature: Environment details

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

Scenario: Table of environment attributes
  When I visit "/environments"
  And I click on "some-environment"
  Then I am at "/environment/some-environment"
  And I see an attribute "$.third" with value "c"

Scenario: Tabs visible only when necessary
  When I visit "/environment/_default"
  Then I can see "Default"
  And I can't see "Override"

Scenario: Cookbooks are listed
  When I visit "/environment/some-environment"
  Then I can see "Cookbook Versions"
  And I can see "cookbook1"
  And I can see "version1"
