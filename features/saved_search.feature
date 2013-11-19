Feature: Saved search

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

Scenario: Using a node saved search
  When I visit "/nodes"
  And I click on "Database tag"
  Then I am at "/nodes"
  And I can see "tags:db"
  And I can see "1 node found"
