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

Then(/^I see an? (\w+) attribute "([^\"]+)" with value (.*)$/) do |kind, path, value|
  values = all("div#attributes-#{kind} tr"). # all table rows inside div with id=attributes-`kind`
    select { |row| row.find('td[1]').text == path }. # select rows where first cell's text is `path`
    map { |row| row.find('td[2]').text }             # make array of such rows' second cell's texts

  assert { values.length == 1 }    # there should be only one such row, no more and no less
  assert { values.first == value } # and its value should be as specified
end
