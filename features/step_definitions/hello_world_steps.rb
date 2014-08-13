PAGES = {
  'main page' => '/'
}

When(/^I visit (?:the )?"(.*?)"$/) do |page_url|
  # Find address from dictionary of named pages, unless we actually got
  # an URL path.
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

Then(/^"(.*?)" precedes "(.*?)"$/) do |first,second|
  assert { page.text.index(first) < page.text.index(second) }
end

When(/^I click on "(.*?)"$/) do |text|
  click_on(text)
end

Then(/^I am at "(.*?)"$/) do |path|
  path = "#{$rack_script_path}#{path}" if $rack_script_path
  assert { current_path == path }
end

Then(/^I see an? (\w+) attribute "([^\"]+)" with value (.*)$/) do |kind, path, value|
  values = all("div#attributes-#{kind} tr"). # all table rows inside div with id=attributes-`kind`
    select { |row| row.find('td[1]').text == path }. # select rows where first cell's text is `path`
    map { |row| row.find('td[2]').text }             # make array of such rows' second cell's texts

  assert { values.length == 1 }    # there should be only one such row, no more and no less
  assert { values.first == value } # and its value should be as specified
end

Then(/^I see an attribute "(.*?)" with value (.*?)$/) do |path, value|
  values = all("table.table tr").                    # all table rows inside table with class="table"
    select { |row| row.find('td[1]').text == path }. # select rows where first cell's text is `path`
    map { |row| row.find('td[2]').text }             # make an array of such rows' second cell texts

  assert { values.length == 1 }
  assert { values.first == value }
end

When(/^I search for "(.*?)"$/) do |search_query|
  page.fill_in 'q', with: "#{search_query}"
  page.find('.navbar-form button[type="submit"]').click
end

Then(/^this page doesn't exist$/) do
  assert { page.status_code == 404 }
end

