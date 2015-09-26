class AnalyticsPlugin::StatsController < MyProfileController

  no_design_blocks

  protect 'edit_profile', :profile
  before_filter :skip_page_view

  def index
  end

  def edit
    params[:analytics_settings][:enabled] = params[:analytics_settings][:enabled] == 'true'
    params[:analytics_settings][:anonymous] = params[:analytics_settings][:anonymous] == 'true'
    @settings = profile.analytics_settings params[:analytics_settings] || {}
    @settings.save!
    render nothing: true
  end

  protected

  # inherit routes from core skipping use_relative_controller!
  def url_for options
    options[:controller] = "/#{options[:controller]}" if options.is_a? Hash and options[:controller] and not options[:controller].to_s.starts_with? '/'
    super options
  end
  helper_method :url_for

  def skip_page_view
    @analytics_skip_page_view = true
  end

end
