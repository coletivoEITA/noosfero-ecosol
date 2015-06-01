module Noosfero
  module ActionMailer
    module UrlHelper

      # Set default host automatically if environment is set
      def url_for options = {}
        return super unless options.is_a? Hash
        if (environment rescue nil)
          options[:host] ||= environment.default_hostname
          # overwrite app/helpers/url_helper.rb
          options[:protocol] = environment.default_protocol
        end
        super options
      end

    end
  end
end

class ActionMailer::Base

  attr_accessor :environment

  helper Noosfero::ActionMailer::UrlHelper

end
