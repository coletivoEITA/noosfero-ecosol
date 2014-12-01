module Noosfero
  module ActionMailer
    module UrlHelper

      # Set default host automatically if environment is set
      def url_for options = {}
        options[:host] ||= environment.default_hostname if environment
        super options
      end
    end
  end
end

class ActionMailer::Base

  attr_accessor :environment

  helper Noosfero::ActionMailer::UrlHelper

end
