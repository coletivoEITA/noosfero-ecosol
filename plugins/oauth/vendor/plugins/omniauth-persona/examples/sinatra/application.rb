$:.push File.dirname(__FILE__) + '/../lib'

require 'rubygems'
require 'bundler'
Bundler.setup :default, :development, :example, ENV['RACK_ENV']

require 'sinatra'
require 'omniauth-persona'
require 'pry'

use Rack::Session::Cookie
use OmniAuth::Strategies::Persona

get '/' do
  "<a href='/auth/persona'>Auth with Persona</a>"
end

post '/auth/persona/callback' do
  content_type 'text/plain'
  request.env['omniauth.auth'].to_hash.inspect
end
