module Songkick
  module OAuth2
    class Provider
      EXPIRY_TIME = 3600

      autoload :Authorization, ROOT + '/oauth2/provider/authorization'
      autoload :Exchange,      ROOT + '/oauth2/provider/exchange'
      autoload :AccessToken,   ROOT + '/oauth2/provider/access_token'
      autoload :Error,         ROOT + '/oauth2/provider/error'

      class << self
        attr_accessor :realm, :enforce_ssl
      end

      def self.clear_assertion_handlers!
        @password_handler   = nil
        @assertion_handlers = {}
        @assertion_filters  = []
      end

      clear_assertion_handlers!

      def self.handle_passwords(&block)
        @password_handler = block
      end

      def self.handle_password(client, username, password, scopes)
        return nil unless @password_handler
        @password_handler.call(client, username, password, scopes)
      end

      def self.filter_assertions(&filter)
        @assertion_filters.push(filter)
      end

      def self.handle_assertions(assertion_type, &handler)
        @assertion_handlers[assertion_type] = handler
      end

      def self.handle_assertion(client, assertion, scopes)
        return nil unless @assertion_filters.all? { |f| f.call(client) }
        handler = @assertion_handlers[assertion.type]
        handler ? handler.call(client, assertion.value, scopes) : nil
      end

      def self.parse(*args)
        Router.parse(*args)
      end

      def self.access_token(*args)
        Router.access_token(*args)
      end

      def self.access_token_from_request(*args)
        Router.access_token_from_request(*args)
      end
    end

  end
end

