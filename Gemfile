source "https://rubygems.org"
gem 'rails',                    '~> 4.2.3'
gem 'fast_gettext',             '~> 0.6.8'
gem 'acts-as-taggable-on',      '~> 3.4.2'
gem 'rails_autolink',           '~> 1.1.5'
gem 'RedCloth',                 '~> 4.2.9'
gem 'ruby-feedparser',          '~> 0.7'
gem 'daemons',                  '~> 1.1.5'
gem 'nokogiri',                 '~> 1.6.0'
gem 'will_paginate'
gem 'pothoven-attachment_fu'
gem 'delayed_job'
gem 'delayed_job_active_record'
gem 'rake', :require => false
gem 'rest-client',              '~> 1.6.7'
gem 'exception_notification',   '~> 4.0.1'
gem 'gettext',                  '~> 2.2.1', :require => false
gem 'locale',                   '~> 2.0.5'
gem 'whenever', :require => false
gem 'eita-jrails', '~> 0.10.0', require: 'jrails'
gem 'will-paginate-i18n'
gem 'utf8-cleaner'
gem 'premailer-rails'
gem 'slim'

gem 'message_bus'

platform :ruby do
  gem 'pg',                       '~> 0.18.1'
  gem 'rmagick',                '~> 2.13.1'
  gem 'thin',                   '~> 1.3.1'

  gem 'unicode'

  group :performance do
    # FIXME: stack level too deep
    #gem 'oj'
    #gem 'oj_mimic_json'
    
    gem 'fast_blank'
    gem 'gctools' if RUBY_VERSION >= '2.1.0' and RUBY_VERSION < '2.2.0'
    # DON'T IMPROVE
    #gem 'escape_utils'
    
    #gem 'rack-cache'
    #gem 'redis-rack-cache'
  end

  group :production do
    gem 'unicorn'
    #gem 'rainbows'
    gem 'unicorn-worker-killer'
  end
end
platform :jruby do
  gem 'activerecord-jdbcpostgresql-adapter'
  gem 'rmagick4j'
end

group :performance do
  gem 'stackprof', platform: :mri
  gem 'flamegraph', platform: :mri
  #gem 'rack-mini-profiler'
end

group :assets do
  gem 'assets_live_compile'
  gem 'uglifier', '>= 1.0.3'
  #gem 'coffee-rails'
  gem 'sass'
  gem 'sass-rails'
end

# gems to enable rails3 behaviour
gem 'protected_attributes'
gem 'rails-observers'
gem 'actionpack-page_caching'
gem 'actionpack-action_caching'
gem 'activerecord-session_store'
gem 'activerecord-deprecated_finders', require: 'active_record/deprecated_finders'


# FIXME list here all actual dependencies (i.e. the ones in debian/control),
# with their GEM names (not the Debian package names)

group :production do
  gem 'newrelic_rpm'
  gem 'redis-rails'
  gem 'rack-cache'
end

group :test do
  gem 'spring'
  gem 'spring-commands-testunit'
  gem 'rspec',                  '~> 2.14.0'
  gem 'rspec-rails',            '~> 2.14.1'
  gem 'mocha',                  '~> 1.1.0', :require => false
  gem 'test-unit' if RUBY_VERSION >= '2.2.0'
  gem 'minitest'
  gem 'minitest-reporters'
end

group :cucumber do
  gem 'capybara',               '~> 2.1.0'
  gem 'launchy'
  gem 'cucumber',               '~> 1.3.20'
  gem 'cucumber-rails',         '~> 1.4.2', :require => false
  gem 'database_cleaner',       '~> 1.2.0'
  # FIXME: conflicts with axlsx version 2, that requires rubyzip 1.0.0 and selenium-webdriver requires rubyzip 1.1.6
  #gem 'selenium-webdriver',     '~> 2.39.0'
end

group :development do
  gem 'wirble'
  gem 'byebug', platform: :mri
  gem 'html2haml', require: false
  gem 'haml2slim', require: false
end

# Requires custom dependencies
eval(File.read('config/Gemfile'), binding) rescue nil

vendor = Dir.glob('vendor/{,plugins/}*') - ['vendor/plugins']
vendor.each do |dir|
  plugin = File.basename dir
  version = if Dir.glob("#{dir}/*.gemspec").length > 0 then '> 0.0.0' else '0.0.0' end

  gem plugin, version, path: dir
end

# include gemfiles from enabled plugins
# plugins in baseplugins/ are not included on purpose. They should not have any
# dependencies.
Dir.glob('config/plugins/*/Gemfile').each do |gemfile|
  eval File.read(gemfile)
end
