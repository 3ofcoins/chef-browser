@loggedin
Feature: Fuzzy query

Background:
  Given a Chef server populated with following data:
    """json
      {
        "nodes": {
          "some-node-test-name": {
            "automatic": {
              "fqdn": "some-node-test-name.example.com",
              "ipaddress": "1.2.3.4",
              "tags": ["db"],
              "chef_environment": "production"
            }
          },
          "another-node-name": {
            "automatic": {
              "fqdn": "another-node-name.example.com",
              "ipaddress": "1.2.3.5",
              "tags": ["test"],
              "chef_environment": "production"
            }
          },
          "this-node-should-not-be-found": {
            "automatic": {
              "fqdn": "this-node-should-not-be-found.example.com",
              "ipaddress": "1.2.3.7",
              "tags": ["whatever", "another"]
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
  And I can see "some-node-test-name"

Scenario: Perform a fuzzy search with whitespace around
  When I visit "/nodes"
  And I search for "  test"
  Then I am at "/nodes"
  And I can see "Search results (2)"
  And I can see "some-node-test-name"
