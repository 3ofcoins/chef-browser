require 'minitest/autorun'
require 'watir-webdriver'

SITE = "http://localhost:9292"
BROWSER = Watir::Browser.start(SITE, :firefox)
PAGES = {
  "Main page" => "http://localhost:9292"
}

Given (/^I visit the (Main page)$/) do |page|
  BROWSER.goto(PAGES[page])
end

Then /^I should see (Hello world!)$/ do |text|
  body.should match(/#{text}/m)
end
