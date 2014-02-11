Feature: Main page
Scenario: Visible node list
  When I visit the "Main page"
  Then I am at "/nodes"
  And I can see "Nodes"
