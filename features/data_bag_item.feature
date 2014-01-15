Feature: Data bags page

Background:
  Given a Chef server populated with following data:
    """json
      {
        "data": {
          "some-data-bag": {
            "secret-data-bag-item": {
              "id": "secret-data-bag-item",
              "login": {
                "cipher": "aes-256-cbc",
                "encrypted_data": "k/cjNY+0ORupMS0Ml0CA7hVaw64YdUeZfDjulKjwT7E=",
                "iv": "WeC/BubdLPQ7R6YIovtFDQ==",
                "version": "1"
              },
              "password": {
                "cipher": "aes-256-cbc",
                "encrypted_data": "HpG5sXDexINdS75rysOayJ122f84amKeTgX6g3EgeFE=",
                "iv": "Oi7Y6mSpJyXiN7rgjNx0Ow==",
                "version": "1"
              }
            }
          },
          "another-data-bag": {
            "another-data-bag-item": {
              "name": "another-data-bag-item",
              "actions": ["add", "remove"]
            }
          }
        }
      }
      """

Scenario: Decrypting data bag item attributes
  When I visit "/data_bag/some-data-bag/secret-data-bag-item"
  Then I can see "This bag is encrypted."
  When I provide a good key
  Then I am at "/data_bag/some-data-bag/secret-data-bag-item"
  And I can see "You are viewing encrypted data."
  And I see an attribute "$.login" with value "admin"

Scenario: Decrypting data bag item attributes with wrong key
  When I visit "/data_bag/some-data-bag/secret-data-bag-item"
  Then I can see "This bag is encrypted."
  When I provide a bad key
  Then I am at "/data_bag/some-data-bag/secret-data-bag-item"
  Then I can see "Wrong key."
  
Scenario: No key given
  When I visit "/data_bag/some-data-bag/secret-data-bag-item"
  Then I can see "This bag is encrypted."
  When I provide no key
  Then I am at "/data_bag/some-data-bag/secret-data-bag-item"
  Then I can see "This bag is encrypted"
  
Scenario: Data bag item attributes
  When I visit "/data_bag/another-data-bag/another-data-bag-item"
  Then I see an attribute "$.name" with value "another-data-bag-item"
  And I see an attribute "$.actions[0]" with value "add"

Scenario: Visiting a non-existing data bag item returns a 404 error
  When I visit "/data_bag/some-data-bag/some-data-bag-itemm"
  Then this page doesn't exist
