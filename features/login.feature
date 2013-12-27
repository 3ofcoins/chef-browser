Feature: Login

Background:
  Given a Chef server populated with following data:
    """json
      {
        "users": {
          "admin": {
            "chef_type": "user",
            "id": "admin",
            "name": "admin",
            "admin": true,
            "public_key": "***",
            "private_key": false,
            "password": "admin"
          }
        }
      }
    """

Scenario: Visible login page
  When I visit the "Main page"
  Then I am at "/login"
  And I can see "Username"
  And I can see "Password"

Scenario: Site not visible when not logged in
  When I visit "/nodes"
  Then I am at "/login"

Scenario: Logging in
  When I visit "/login"
  And I login as "admin" with password "admin"
  Then I am at "/nodes"
  And I can see "Chef Browser version 1.0.1 connected to Chef server at http://127.0.0.1:4001 as stub"

Scenario: Wrong password
  When I visit "/login"
  And I login as "admin" with password "123"
  Then I am at "/login"
  And I can see "Wrong username or password, try again"

Scenario: Wrong username
  When I visit "/login"
  And I login as "not-admin" with password "admin"
  Then I am at "/login"
  And I can see "Wrong username or password, try again"

Scenario: Logging out
  When I visit "/login"
  And I login as "admin" with password "admin"
  And I log out
  Then I am at "/login"
