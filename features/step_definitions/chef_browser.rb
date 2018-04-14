# frozen_string_literal: true

Given(/a settings.rb configuration:/) do |settings|
  @chef_browser_settings = ChefBrowser::App.settings.rb

  new_settings = ChefBrowser::Settings.load
  new_settings.configure(settings)
  ChefBrowser::App.set :rb, new_settings
end

After do
  if @chef_browser_settings
    ChefBrowser::App.set :rb, @chef_browser_settings
    @chef_browser_settings = nil
  end
end
