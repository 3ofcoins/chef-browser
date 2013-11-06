Feature: Node search

Background:
  Given a Chef server populated with following data:
    """json
      {
        "nodes": {
          "some-node-name": {
            "automatic": {
              "fqdn": "some-node-name.example.com",
              "ipaddress": "1.2.3.4",
              "tags": ["test", "db"],
              "environment": "production"
            }
          },
          "another-node-name": {
            "automatic": {
              "fqdn": "another-node-name.example.com",
              "ipaddress": "1.2.3.5",
              "tags": ["test"],
              "environment": "production"
            }
          }
        }
      }
    """

Scenario: Search results
  When I visit "/nodes"
  And I search for "name:some"
  And I press "Search"
  Then I am at "/nodes"
  And I can see "name:some"
  And I can see "1 node item found"

Scenario: No search results found
  When I visit "/nodes"
  And I search for "ipaddress:5.6.7.8"
  And I press "Search"
  Then I am at "/nodes"
  And I can see "No matching results found"

Scenario: Search similar nodes
  When I visit "/node/some-node-name"
  And I click on "db"
  Then I am at "/nodes"
  And I can see "tags:db"
  And I can see "1 node item found"
  And I can see "some-node-name"
