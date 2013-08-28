Given /^I visit the main page$/ do
  visit 'http://localhost:9292'
end

Then /^I should see '("Hello world!")'$/ do |text|
  body.should match(/#{text}/m)
end
