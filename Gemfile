source "https://rubygems.org"

gem 'fastercsv'
gem 'unicode'
gem 'sass'

gem 'rake', '0.8.7'
gem 'rails', '2.3.15'
gem 'gettext', '2.1.0'
gem 'gettext_rails', '2.1.0'
gem 'rmagick', '2.13.1'
gem 'RedCloth', '4.2.2'
gem 'will_paginate', '2.3.12'
gem 'ruby-feedparser', '0.7'
gem 'hpricot', '0.8.2'
gem 'i18n'
gem 'daemons', '1.0.10'
gem 'rubyzip', '< 1.0.0'
gem 'memcache-client'

#Indirect, matching debian squeeze versions
gem 'builder', '2.1.2'
gem 'cmdparse', '2.0.2'
gem 'gem_plugin', '0.2.3'
gem 'eventmachine', '0.12.10'
gem 'log4r', '1.0.6'
gem 'mmap', '0.2.6'
gem 'mocha', '0.9.8'
gem 'nokogiri', '~> 1.4'
gem 'rest-client', '1.6.0'
gem 'ruby-breakpoint', '0.5.1'
gem 'mime-types', '< 2.0'
gem 'locale', '2.0.9'

group :production do
  gem 'thin', '1.2.4'
  gem 'exception_notification', '1.0.20090728'
  gem 'system_timer'
end

group :development do
  gem 'rdoc'
  gem 'mongrel', '1.1.5'
  gem 'mongrel_cluster', '1.0.5'
end

group :databases do
  gem 'sqlite3-ruby', '1.2.4'
  gem 'pg'
end

group :test do
  gem 'tidy'
  gem 'rcov'
  gem 'system_timer'
  gem 'rspec', '1.2.9'
  gem 'rspec-rails', '1.2.9'
end

group :cucumber do
  gem 'capybara', '1.1.1'
  gem 'cucumber', '1.1.0'
  gem 'cucumber-rails', '0.3.2'
  gem 'database_cleaner'
end

def program(name)
  unless system("which #{name} > /dev/null")
    puts "W: Program #{name} is needed, but was not found in your PATH"
  end
end

program 'java'
program 'firefox'
