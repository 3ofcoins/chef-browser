Feature: Configurable title

Background:
  Given a settings.rb configuration:
    """ruby
      title "Test application"
    """

Scenario: Title visibility: nodes
  When I visit "/nodes"
  Then I can see "Test application"

Scenario: Title visibility: roles
  When I visit "/roles"
  Then I can see "Test application"

Scenario: Title visibility: environments
  When I visit "/environments"
  Then I can see "Test application"

Scenario: Title visibility: data bags
  When I visit "/data_bags"
  Then I can see "Test application"

