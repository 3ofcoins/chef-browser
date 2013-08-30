PAGES = {
  'main page' => '/'
}

When(/^I visit (?:the )?"(.*?)"$/) do |page|
  # Find address from dictionary of named pages, unless we actually got
  # an URL path.
  page = PAGES[page.downcase] unless page =~ /^\//
  get(page)
end

Then(/^I should see "(.*?)"$/) do |text|
  assert { last_response.body.include?(text) }
end
