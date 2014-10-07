PAGES = {
  'main page' => '/'
}

When(/^I visit (?:the )?"(.*?)"$/) do |page_url|
  page_url = PAGES[page_url.downcase] unless page_url =~ /^\//
  page_url = "#{$rack_script_path}#{page_url}" if $rack_script_path
  visit(page_url)
end

Then(/^I can see "(.*?)"$/) do |text|
  # We normally expect the request to succeed, put the assertion here
  # to avoid too verbose feature files.
  assert { (200..399).include?(page.status_code) }
  assert { page.has_content?(text) }
end

Then(/^I can't see "(.*?)"$/) do |text|
  # We normally expect the request to succeed, put the assertion here
  # to avoid too verbose feature files.
  assert { (200..399).include?(page.status_code) }
  assert { page.has_content?(text) == false }
end

When(/^I click on "(.*?)"$/) do |text|
  click_on(text)
end

Then(/^I am at "(.*?)"$/) do |path|
  path = "#{$rack_script_path}#{path}" if $rack_script_path
  assert { current_path == path }
end

Then(/^I see an? (\w+) attribute "([^\"]+)" with value (.*)$/) do |kind, path, value|
  values = all("div#attributes-#{kind} tr")
    .select { |row| row.find('td[1]').text == path }
    .map { |row| row.find('td[2]').text }

  assert { values.length == 1 }
  assert { values.first == value }
end

Then(/^I see an attribute "(.*?)" with value (.*?)$/) do |path, value|
  values = all("table.table tr")
    .select { |row| row.find('td[1]').text == path }
    .map { |row| row.find('td[2]').text }

  assert { values.length == 1 }
  assert { values.first == value }
end

When(/^I search for "(.*?)"$/) do |search_query|
  page.fill_in 'q', with: "#{search_query}"
  page.find('button[id="search-submit"]').click
end

Then(/^this page doesn't exist$/) do
  assert { page.status_code == 404 }
end

When(/^I log in as "(.*?)" with password "(.*?)"$/) do |user, password|
  page.fill_in 'username', with: "#{user}"
  page.fill_in 'password', with: "#{password}"
  page.find('button[type="submit"]').click
end

When(/^I log out/) do
  page.find('button[id="logout"]').click
end
