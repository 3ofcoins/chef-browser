Feature: Cookbook details

Background:
  Given an nginx-1.0.0 cookbook uploaded to server

Scenario: Basic cookbook details
  When I visit "/cookbook/nginx-1.0.0"
  Then I can see "Installs and configures nginx"
  And I can see "ubuntu"

Scenario: Data divided into tabs
  When I visit "/cookbook/zlib-1.0.0"
  Then I can see "Recommendations"
  And I can see "Providing"
  And I can see "Recipes"
  And I can see "Metadata"

Scenario: List of recipes with descriptions
  When I visit "/cookbook/nginx-1.0.0"
  And I click on "Recipes"
  Then I can see "default.rb: Installs nginx package and sets up configuration"
  And I can see "upload_progress_module.rb"

Scenario: Recipe code and line numbers
  When I visit "/cookbook/nginx-1.0.0"
  And I click on "Recipes"
  And I click on "default.rb"
  Then I am at "/cookbook/nginx-1.0.0/default.rb"
  And I can see "nginx::default.rb"
  And I can see "case node['nginx']['install_method']"
  And I can see "43"

Scenario: Metadata
  When I visit "/cookbook/nginx-1.0.0"
  And I click on "Metadata"
  Then I can see ""version": "1.1.0""
  And I can see ""name": "nginx""

Scenario: Visible file list
  When I visit "/cookbook/nginx-1.0.0"
  And I click on "Files"
  Then I can see "Templates"
  And I can see "Root_files"
  And I can see "modules/http_realip.conf.erb"
