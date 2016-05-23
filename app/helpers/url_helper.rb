module UrlHelper

  extend ActiveSupport::Concern

  included do
    cattr_accessor :controller_path_class
    self.controller_path_class = {}
  end

  def url_for options = {}
    return super unless options.is_a? Hash
    # for action mailer
    return super unless respond_to? :params and respond_to? :controller_path

    # Keep profile parameter when not using a custom domain:
    # this is necessary as :profile parameter is optional in config/routes.rb;
    # delete it if using a custom domain
    # This overides the default Rails' behaviour that always recall
    # the request params (see #url_options below)
    host = options[:host]
    if host.blank? or host == environment.default_hostname
      path = options[:controller].to_s.gsub %r{^/}, '' if options[:controller]
      path ||= self.controller_path
      controller = self.controller_path_class[path] ||= "#{path}_controller".camelize.constantize
      profile_needed = controller.profile_needed if controller.respond_to? :profile_needed, true
      if profile_needed and options[:profile].blank? and params[:profile].present?
        options[:profile] = params[:profile]
      end
    else
      options.delete :profile
    end

    super options
  end

  def default_url_options options={}
    options[:protocol] ||= '//'

    options[:override_user] = params[:override_user] if params[:override_user].present?

    # Only use profile's custom domains for the profiles and the account controllers.
    # This avoids redirects and multiple URLs for one specific resource
    if controller_path = options[:controller] || self.class.controller_path
      controller = (self.class.controller_path_class[controller_path] ||= "#{controller_path}_controller".camelize.constantize rescue nil)
      profile_needed = controller.profile_needed rescue false
      if controller and not profile_needed and not controller == AccountController
        options.merge! :host => environment.default_hostname, :only_path => false
      end
    end

    options
  end

  # the url_for above put or delete the :profile parameter as needed
  # :profile in _path_segments would always add it
  def url_options
    @_url_options_without_profile ||= begin
      # fix rails exception
      opts = super rescue {}
      opts[:_recall].delete :profile if opts[:_recall]
      opts
    end
  end

  def back_url
    'javascript:history.back()'
  end

end
