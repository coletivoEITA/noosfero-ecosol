module UrlHelper

  mattr_accessor :controller_path_class
  self.controller_path_class = {}

  def url_for options = {}
    return super unless options.is_a? Hash
    # for action mailer
    return super unless respond_to? :params and respond_to? :controller_path

    options[:protocol] ||= '//'

    # Keep profile parameter when not using a custom domain:
    # this is necessary as :profile parameter is optional in config/routes.rb
    # Delete it if using a custom domain
    host = options[:host]
    profile = options[:profile]
    if host.blank? or host == environment.default_hostname
      controller = (options[:controller] || self.controller_path).to_s
      controller = UrlHelper.controller_path_class[controller_path] ||= "#{controller_path}_controller".camelize.constantize rescue nil
      profile_needed = controller.profile_needed rescue false
      if profile_needed and profile.blank? and params[:profile].present?
        options[:profile] = params[:profile]
      end
    else
      options.delete :profile
    end

    super options
  end

  # the url_for above put or delete the :profile parameter as needed
  # :profile in _path_segments would always add it
  def url_options
    @_url_options_without_profile ||= begin
      opts = super
      # FIXME: rails4 changes this to _recall
      opts[:_path_segments].delete :profile
      opts
    end
  end

end
