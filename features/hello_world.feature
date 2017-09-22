Feature: Main page
Scenario: Visible node list
  When I visit the "Main page"
  Then I am at "/dashboard"
  And I can see "Last successful Chef run"
