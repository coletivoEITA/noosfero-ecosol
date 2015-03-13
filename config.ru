# This file is used by Rack-based servers to start the application.

require ::File.expand_path('../config/environment',  __FILE__)

if RUBY_ENGINE == 'ruby' and RUBY_VERSION >= '2.1.0' and RUBY_VERSION < '2.2.0'
  require 'gctools/oobgc'
  if defined? Unicorn::HttpRequest
    use GC::OOB::UnicornMiddleware
  end
end

run Noosfero::Application
