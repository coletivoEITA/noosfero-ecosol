# -*- encoding: utf-8 -*-
require File.expand_path('../lib/omniauth/persona/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Michael Bleigh", "Patrick Klingemann"]
  gem.email         = ["patrick.klingemann@gmail.com"]
  gem.description   = %q{An OmniAuth strategy for implementing Persona}
  gem.summary       = %q{An OmniAuth strategy for implementing Persona}
  gem.homepage      = "https://github.com/pklingem/omniauth-persona"

  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.name          = "omniauth-persona"
  gem.require_paths = ["lib"]
  gem.version       = OmniAuth::Persona::VERSION

  gem.add_dependency "omniauth", "~> 1.0"
  gem.add_dependency "faraday"
  gem.add_dependency "multi_json"

  gem.add_development_dependency "rake"
  gem.add_development_dependency "rspec", "~> 2.7"
  gem.add_development_dependency "rack-test"
end
