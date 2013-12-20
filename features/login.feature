Feature: Login
Scenario: Visible login page
  When I visit the "Main page"
  Then I am at "/login"
  And I can see "Log in"

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
  And I can see "Wrong username or password"

Scenario: Wrong username
  When I visit "/login"
  And I login as "not-admin" with password "admin"
  Then I am at "/login"
  And I can see "Wrong username or password"
