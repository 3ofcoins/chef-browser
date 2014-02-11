Feature: Browse data bags

Background:
  Given a Chef server populated with following data:
    """json
      {
        "data": {
          "some-data-bag": {
              "first-data-bag-item": {
                "name": "first-data-bag-item",
                "actions": ["add", "remove"]
              },
              "second-data-bag-item": {
                "name": "second-data-bag-item"
              }
          },
          "another-data-bag": {
            "another-data-bag-item": {
              "name": "another-data-bag-item"
            }
          }
        }
      }
    """

Scenario: Wrong resource list url returns a 404 error
  When I visit "/data_bagss"
  Then this page doesn't exist

Scenario: List data bags
  When I visit "/data_bags"
  Then I can see "some-data-bag"
  And I can see "another-data-bag"

Scenario: List of data bag items
  When I visit "/data_bags"
  And I click on "some-data-bag"
  Then I am at "/data_bag/some-data-bag"
  And I can see "first-data-bag-item"

Scenario: Data bag item attributes
  When I visit "/data_bag/some-data-bag/first-data-bag-item"
  Then I see an attribute "$.name" with value "first-data-bag-item"
  And I see an attribute "$.actions[0]" with value "add"

Scenario: Visiting a non-existing data bag returns a 404 error
  When I visit "/data_bag/some-data-bagg"
  Then this page doesn't exist
