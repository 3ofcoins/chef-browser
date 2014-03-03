Feature: Full search

Background:
  Given a settings.rb configuration:
    """ruby
      use_partial_search false
    """
  And a Chef server populated with following data:
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
              "fqdn": "some-node-name.example.com",
              "ipaddress": "1.2.3.4",
              "records": ["Manufacturer", "Version"]
            }
          }
        }
      }
    """

Scenario: Full search works when partial search disabled
  When I visit "/nodes"
  And I search for "name:some-node-name"
  Then I am at "/nodes"
  And I can see "Search results (1)"
