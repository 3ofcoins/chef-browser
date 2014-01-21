Feature: Log in

Background:
  Given a settings.rb configuration:
    """ruby
      login true
    """
  And a Chef server populated with following data:
    """json
      {
        "users": {
          "admin": {
            "chef_type": "user",
            "id": "admin",
            "name": "admin",
            "admin": true,
            "password": "admin"
          }
        },
        "nodes": {
          "some-node-name": {
            "automatic": {
              "fqdn": "some-node-name.example.com",
              "ipaddress": "1.2.3.4",
              "records": ["Manufacturer", "Version"]
            }
          }
        }
      }
    """

Scenario: Visible login page
  When I visit the "Main page"
  Then I am at "/login"
  And I can see "Username"
  And I can see "Password"

Scenario: Data not visible when not logged in
  When I visit "/node/some-node-name"
  Then I am at "/login"
  And I can't see "some-node-name"

Scenario: Logging in
  When I visit "/login"
  And I log in as "admin" with password "admin"
  Then I am at "/nodes"
  And I can see "Logged in as admin"

Scenario: Wrong password
  When I visit "/login"
  And I log in as "admin" with password "123"
  Then I am at "/login"
  And I can see "Wrong password or username"

Scenario: Wrong username
  When I visit "/login"
  And I log in as "not-admin" with password "admin"
  Then I am at "/login"
  And I can see "Wrong password or username"

Scenario: Logging out
  When I visit "/nodes"
  And I log in as "admin" with password "admin"
  And I log out
  Then I am at "/login"
