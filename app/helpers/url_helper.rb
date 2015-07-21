module UrlHelper

  # FIXME move to a monkey patch in all controllers' init
  mattr_accessor :controller_path_class
  self.controller_path_class = {}

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
      controller_path = (options[:controller] || self.controller_path).to_s
      controller = UrlHelper.controller_path_class[controller_path] ||= "#{controller_path}_controller".camelize.constantize
      profile_needed = controller.profile_needed if controller.respond_to? :profile_needed, true
      if profile_needed and options[:profile].blank? and params[:profile].present?
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
      # fix rails exception
      opts = super rescue {}
      opts[:_recall].delete :profile if opts[:_recall]
      opts
    end
  end

  def default_url_options
    {protocol: '//'}
  end

end
