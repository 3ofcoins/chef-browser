Feature: Browse cookbooks

Background:
  Given an nginx-1.0.0 cookbook uploaded to server

Scenario: Wrong resource list url returns a 404 error
  When I visit "/cookbookss"
  Then this page doesn't exist

Scenario: List cookbooks
  When I visit "/cookbooks"
  Then I can see "nginx-1.0.0"

Scenario: Selecting a cookbook
  When I visit "/cookbooks"
  And I click on "nginx-1.0.0"
  Then I am at "/cookbook/nginx-1.0.0"
  And I can see "Installs and configures nginx"

Scenario: Visiting a non-existing cookbook returns a 404 error
  When I visit "/cookbook/nginx-0.0.0"
  Then this page doesn't exist
