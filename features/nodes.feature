Feature: Node list

Background:
  Given a Chef server populated with following data:
    """json
      {
        "nodes": {
          "some-node-name": {
            "automatic": {
              "fqdn": "some-node-name.example.com",
              "ipaddress": "1.2.3.4",
              "records": ["Manufacturer", "Version"]
            }
          },
          "another-node-name": {
            "automatic": {
              "fqdn": "another-node-name.example.com",
              "ipaddress": "1.2.3.5"
            }
          }
        }
      }
    """

Scenario: List of node names
  When I visit "/nodes"
  Then I can see "some-node-name"
  And I can see "another-node-name"

Scenario: Selecting a node
  When I visit "/nodes"
  And I click on "some-node-name"
  Then I am at "/node/some-node-name"
  And I can see "some-node-name.example.com (1.2.3.4)"
  
Scenario: List of node attributes
  When I visit "/node/some-node-name"
  Then I can see "$.automatic.records[0]"
  And I can see ""Manufacturer""

Scenario: Browsing through node attributes
  When I visit "/node/some-node-name"
  And I click on "Override"
  Then I can see "This node has no override attributes."

Scenario: Browsing through node attributes #2
  When I visit "/node/some-node-name"
  And I click on "Automatic"
  Then I can see "records[0]"
