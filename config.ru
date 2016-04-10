# This file is used by Rack-based servers to start the application.

require ::File.expand_path('../config/environment',  __FILE__)

if RUBY_ENGINE == 'ruby' and RUBY_VERSION >= '2.1.0' and RUBY_VERSION < '2.2.0'
  require 'gctools/oobgc'
  if defined? Unicorn::HttpRequest
    use GC::OOB::UnicornMiddleware
  end
end

use Rack::Cors do
  allow do
    origins '*'
    resource '/api/*', :headers => :any, :methods => [:get, :post]
  end
end

rails_app = Rack::Builder.new do
  if ENV['RAILS_RELATIVE_URL_ROOT']
    map ENV['RAILS_RELATIVE_URL_ROOT'] do
      run Noosfero::Application
    end
  else
    run Noosfero::Application
  end
end

run Rack::Cascade.new([
  Noosfero::API::API,
  rails_app
])
