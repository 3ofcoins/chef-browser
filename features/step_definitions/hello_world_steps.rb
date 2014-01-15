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

When(/^I provide (.*?) key$/) do |key|
  if key == "a bad"
    page.fill_in 'key', with: "123"
    page.find('button[id="submit-key"]').click
  elsif key == "no"
     page.fill_in 'key', with: ""
     page.find('button[id="submit-key"]').click
  elsif key == "a good"
     page.fill_in 'key', with: "RqAsBDGXSzuQkjmmmk3sQG7QJexiM6n3Oy09R2usdlh1sAUDJBuX8TjKSfc4FKG/+4QMfMp2YUQHzNEX1Vwg4sWd9WAkMWQ3QDHVHm8OphV2Vb95wSINPoEoJzC4Y6aTig/Hne1TBSvLV7LGN4588UTOLR5OBPMeVM8+e+Modiq5eRM2w/aZaf7ctl633PgW7VCBWZC06D8r+OyPvOHVfgD6K3rb0FvDMQlBUVixpqoaVGrufUbebZ8HQ5SEjfN3uBZMd7HHM8IsBi81tnex5LRuTHxMQ73Opn6DY7fffF1iQu+9VhI3VsYYn71S30+K8lQG2iD3tYQCoAJKVbxFXvPeEZBLiLLU2PGXXJLytIRJ0lMp4HgeLMStrf0dN9SpcieBrMCDOY9oa/Ft9xGkeiizn2XxSKwVip/6e3WCg3DRWkT5ru3SJMQOL5MNjc8P6RHnGzYFjOBnor+hyMEJK6rXcSfMdU8Sn1+8m/51abAJ87vtUjZl8uDxbUSpEV7NvQfLi5ySWZhNCEuZ1TQQooe3Vo6uE9tiB6vkbQgoyM01kKDubYUtTTR5qZwMUMZU4/jouBigUbpOhmBMY3OjBX6Rzg7W/AqvipMCJROWG7KvZFUdP7dvdwIReAA5ZPjtHSC/3sG/Ps4vpzUZXoOtzVLa5p777ICIHAosb+VnNQE="
     page.find('button[id="submit-key"]').click
   end
end
