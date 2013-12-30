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
  And I log in as "admin" with password "admin"
  Then I am at "/nodes"
  And I can see "Logged in as admin"

Scenario: Wrong password
  When I visit "/login"
  And I log in as "admin" with password "123"
  Then I am at "/login"
  And I can see "Wrong username or password, try again"

Scenario: Wrong username
  When I visit "/login"
  And I log in as "not-admin" with password "admin"
  Then I am at "/login"
  And I can see "Wrong username or password, try again"

Scenario: Logging out
  When I visit "/nodes"
  And I log in as "admin" with password "admin"
  And I log out
	Then I am at "/login"
