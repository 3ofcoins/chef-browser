Feature: Node details

Background:
  Given a Chef server populated with following data:
    """json
      {
        "nodes": {
          "some-node-name": {
            "chef_environment": "production",
            "automatic": {
              "fqdn": "some-node-name.example.com",
              "ipaddress": "1.2.3.4",
              "records": ["Manufacturer", "Version"]
            },
            "run_list": [
              "role[a-role]",
              "recipe[a-recipe]"
            ]
          },
          "another-node-name": {
            "automatic": {
              "fqdn": "another-node-name.example.com",
              "ipaddress": "1.2.3.5",
              "policy_name": "my-policy"
            }
          }
        }
      }
    """

Scenario: Show main attributes without policy
  When I visit "/node/some-node-name"
  Then I can't see "Policy:"
  And I can see "Environment: production"

Scenario: Show main attributes with policy
  When I visit "/node/another-node-name"
  Then I can see "Policy: my-policy"
  And I can see "Environment: _default"

Scenario: List of node attributes
  When I visit "/node/some-node-name"
  Then I can see "$.automatic.records[0]"
  And I can see ""Manufacturer""

Scenario: Table of node attributes and their JSONPath selectors
  When I visit "/node/some-node-name"
  And I click on "Automatic"
  Then I see an automatic attribute "$.ipaddress" with value "1.2.3.4"
  And I see an automatic attribute "$.records[0]" with value "Manufacturer"

Scenario: No attributes of some class
  When I visit "/node/some-node-name"
  And I click on "Override"
  Then I can see "This node has no override attributes."

Scenario: Linking to roles
  When I visit "/node/some-node-name"
  Then I can see "recipe[a-recipe]"
  And I can see "role[a-role]"
  And I click on "role[a-role]"
  Then I am at "/role/a-role"
