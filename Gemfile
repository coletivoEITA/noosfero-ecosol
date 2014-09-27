source "https://rubygems.org"
gem 'rails', '~> 3.2'
gem 'fast_gettext'
gem 'acts-as-taggable-on'
gem 'prototype-rails'
gem 'prototype_legacy_helper', '0.0.0', :path => 'vendor/prototype_legacy_helper'
gem 'rails_autolink'
gem 'pg'
gem 'rmagick'
gem 'RedCloth'
gem 'will_paginate'
gem 'ruby-feedparser'
gem 'daemons'
gem 'thin'
gem 'hpricot'
gem 'nokogiri'
gem 'rake', :require => false
gem 'rest-client'
gem 'exception_notification'
gem 'locale', '2.0.9' # 2.1.0 has a problem with memoizable
gem 'gettext', '< 3.0', require: false, group: :development

gem 'premailer-rails'

# FIXME list here all actual dependencies (i.e. the ones in debian/control),
# with their GEM names (not the Debian package names)

group :assets do
  gem 'therubyracer', :platforms => :ruby
  gem 'uglifier', '>= 1.0.3'

  gem 'sass-rails'
end

group :production do
  gem 'dalli'
end

group :test do
  gem 'rspec'
  gem 'rspec-rails'
  gem 'mocha', :require => false
end

group :cucumber do
  gem 'cucumber-rails', :require => false
  gem 'capybara'
  gem 'cucumber'
  gem 'database_cleaner'
  gem 'selenium-webdriver'
end

# include plugin gemfiles
Dir.glob(File.join('config', 'plugins', '*')).each do |plugin|
  plugin_gemfile = File.join(plugin, 'Gemfile')
  eval File.read(plugin_gemfile) if File.exists?(plugin_gemfile)
end
