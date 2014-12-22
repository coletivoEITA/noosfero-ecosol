require 'omniauth/strategies/oauth2'

module OmniAuth
  module Strategies
    class Noosfero < OmniAuth::Strategies::OAuth2

      DefaultScope = "userinfo.email,userinfo.identifier,userinfo.name"

      # just a reference name, the name varies with the identifier (see below)
      option :name, 'noosfero'

      option :client_options, {
        :site          => nil, # set dinamically
        :authorize_url => "#{OauthPlugin.path_prefix}/provider/authorize",
        :token_url     => "#{OauthPlugin.path_prefix}/provider/token",
        :userinfo_url  => "#{OauthPlugin.path_prefix}/api/userinfo",
      }
      option :provider_ignores_state, true

      uid do
        raw_info['userinfo']['email']
      end
      info do
        {
          :email => raw_info['userinfo']['email'],
          :identifier => raw_info['userinfo']['identifier'],
          :name => raw_info['userinfo']['name'],
        }
      end

      def callback_path
        "#{path_prefix}/callback/#{name}"
      end

      def name
        return options.name unless request.path.starts_with? ::OauthPlugin::path_prefix
        provider.identifier rescue options.name
      end

      def domain
        @domain ||= Domain.find_by_name request.host
      end

      def environment
        @environment ||= domain.environment rescue Environment.default
      end

      def provider
        return @provider if @provider

        identifier = request.path.split('/').last
        @provider = environment.oauth_providers.find_by_identifier identifier
        @provider = nil if @provider.strategy_class != self.class
        @provider
      end

      def client_with_dynamic_site
        options[:client_options][:site] = provider.site
        client_without_dynamic_site
      end
      alias_method_chain :client, :dynamic_site

      def authorize_params
        super.tap do |params|
          scope_list = (params[:scope] || DefaultScope).split ','
          params[:scope] = scope_list.join ' '

          session['omniauth.state'] = params[:state] if params[:state]
        end
      end

      def raw_info
        @raw_info ||= self.access_token.get(options[:client_options][:userinfo_url]).parsed
      end

    end
  end
end
