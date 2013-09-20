PAGES = {
  'main page' => '/'
}

When(/^I visit (?:the )?"(.*?)"$/) do |page|
  # Find address from dictionary of named pages, unless we actually got
  # an URL path.
  page = PAGES[page.downcase] unless page =~ /^\//
  get(page)
end

Then(/^I can see "(.*?)"$/) do |text|
  # We normally expect the request to succeed, put the assertion here
  # to avoid too verbose feature files.
  assert { last_response.ok? }
  assert { last_response.body.include?(text) }
end
