PAGES = {
  'main page' => '/'
}

When(/^I visit (?:the )?"(.*?)"$/) do |page|
  # Find address from dictionary of named pages, unless we actually got
  # an URL path.
  page = PAGES[page.downcase] unless page =~ /^\//
  visit(page)
end

Then(/^I can see "(.*?)"$/) do |text|
  # We normally expect the request to succeed, put the assertion here
  # to avoid too verbose feature files.
  assert { (200..399).include?(page.status_code) }
  assert { page.has_content?(text) }
end

When(/^I click on "(.*?)"$/) do |text|
  click_on(text)
end

Then(/^I am at "(.*?)"$/) do |path|
  assert { current_path == path }
end
