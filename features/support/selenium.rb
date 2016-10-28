require 'selenium/webdriver'

Capybara.default_driver = :selenium
Capybara.register_driver :selenium do |app|
  case ENV['SELENIUM_DRIVER']
  when 'chrome'
    Capybara::Selenium::Driver.new app, browser: :chrome
  else
    Capybara::Selenium::Driver.new app, browser: :firefox
  end
end

Before('@ignore-hidden-elements') do
  Capybara.ignore_hidden_elements = true
end

Capybara.default_wait_time = 30
Capybara.server_host = "localhost"

World(Capybara)
