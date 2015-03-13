require_dependency "#{File.dirname __FILE__}/ext/songkick/oauth2/model/client"

class OauthPlugin < Noosfero::Plugin

  def self.plugin_name
    _('OAuth')
  end

  def self.plugin_description
    _('OAuth authentication to other noosfero networks and other OAuth providers')
  end

  NoosferoScopes = {
    'userinfo.name' => 'Name',
    'userinfo.identifier' => 'Identifier',
    'userinfo.email' => 'Email',
  }

  StrategiesDefs = {
    'noosfero' => {
      name: 'Noosfero Network',
      key_needed: true,
    },
    'browser_id' => {
      identifier: 'browser_id',
      name: 'Mozilla Persona',
      key_needed: false,
    },
    'twitter' => {
      identifier: 'twitter',
      name: 'Twitter',
      key_needed: true,
    },
    'google_oauth2' => {
      identifier: 'google',
      name: 'Google',
      key_needed: true,
    },
    'facebook' => {
      identifier: 'facebook',
      name: 'Facebook',
      key_needed: true,
    },
  }

  def self.path_prefix
    '/plugin/oauth'
  end

  def stylesheet?
    true
  end

  def js_files
    ['oauth'].map{ |j| "javascripts/#{j}" }
  end

  def login_extra_contents
    lambda do
      render 'oauth/signin'
    end
  end

  SetupProc = lambda do |env|
    request = Rack::Request.new env

    strategy = env['omniauth.strategy']
    return if strategy.blank?
    defs = StrategiesDefs[strategy.options.name]

    domain = Domain.find_by_name request.host
    environment = domain.environment rescue Environment.default
    identifier = request.path.split('/').last
    provider = environment.oauth_providers.find_by_identifier identifier
    return if provider.blank?

    strategy.options[:name] = provider.identifier

    strategy.options[:consumer_key] = provider.key
    strategy.options[:consumer_secret] = provider.secret
    strategy.options[:client_id] = provider.key
    strategy.options[:client_secret] = provider.secret

    strategy.options[:scope] = provider.scope || defs[:default_scope]

    strategy.options[:callback_path] = "#{strategy.path_prefix}/callback/#{provider.identifier}"
  end

end


# (development env). don' let middlewares to be added again after code reload
unless $oauth_plugin_middlewares_loaded
  $oauth_plugin_middlewares_loaded = true

  Noosfero::Application.middleware.use OmniAuth::Builder do
    require_dependency "#{File.dirname __FILE__}/omni_auth/strategies/noosfero"

    configure do |config|
      config.path_prefix = "#{OauthPlugin.path_prefix}/auth"
    end

    unless Rails.env.production?
      provider :developer, path_prefix: "#{OauthPlugin.path_prefix}/auth", callback_path: "#{OauthPlugin.path_prefix}/auth/callback/developer"
    end

    OauthPlugin::StrategiesDefs.each do |name, defs|
      provider name, setup: OauthPlugin::SetupProc, path_prefix: "#{OauthPlugin.path_prefix}/auth",
        callback_path: "#{OauthPlugin.path_prefix}/auth/callback/#{defs[:identifier]}"
    end
  end
end
