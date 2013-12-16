Feature: Fuzzy query

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

Scenario: Perform a fuzzy search
  When I visit "/nodes"
  And I search for "test"
  Then I am at "/nodes"
  And I can see "Search results (2)"
  And I can see "some-node-name"
