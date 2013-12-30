@loggedin
Feature: Main page
Scenario: Visible greeting
  When I visit the "Main page"
  Then I am at "/nodes"
  And I can see "Nodes"
