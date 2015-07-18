require 'noosfero/multi_tenancy'

class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :setup_multitenancy
  before_filter :detect_stuff_by_domain
  before_filter :init_noosfero_plugins
  before_filter :allow_cross_domain_access

  before_filter :login_from_cookie
  before_filter :login_required, :if => :private_environment?

  before_filter :verify_members_whitelist, :if => [:private_environment?, :user]
  before_filter :authorize_profiler if defined? Rack::MiniProfiler
  around_filter :set_time_zone

  def verify_members_whitelist
    render_access_denied unless user.is_admin? || environment.in_whitelist?(user)
  end

  after_filter :set_csrf_cookie

  def set_csrf_cookie
    cookies['_noosfero_.XSRF-TOKEN'] = form_authenticity_token if protect_against_forgery? && logged_in?
  end

  protected

  def set_time_zone
    return yield unless (utc_offset = cookies['browser.tzoffset']).present?
    utc_offset = utc_offset.to_i
    gmt_offset = if utc_offset == 0 then nil elsif utc_offset > 0 then -utc_offset else "+#{-utc_offset}" end
    Time.use_zone("Etc/GMT#{gmt_offset}"){ yield }
  rescue ArgumentError
    yield
  end

  def allow_cross_domain_access
    origin = request.headers['Origin']
    return if origin.blank?
    if environment.access_control_allow_origin.include? origin
      response.headers["Access-Control-Allow-Origin"] = origin
      unless environment.access_control_allow_methods.blank?
        response.headers["Access-Control-Allow-Methods"] = environment.access_control_allow_methods
      end
      response.headers["Access-Control-Allow-Credentials"] = 'true'
    elsif environment.restrict_to_access_control_origins
      render_access_denied _('Origin not in allowed.')
    end
  end

  include ApplicationHelper

  layout :get_layout
  def get_layout
    return nil if request.format == :js or request.xhr?

    theme_layout = theme_option(:layout)
    if theme_layout
      (theme_view_file('layouts/'+theme_layout) || theme_layout).to_s
    else
     'application'
    end
  end

  def log_processing
    super
    return unless Rails.env == 'production'
    if logger && logger.info?
      logger.info("  HTTP Referer: #{request.referer}")
      logger.info("  User Agent: #{request.user_agent}")
      logger.info("  Accept-Language: #{request.headers['HTTP_ACCEPT_LANGUAGE']}")
    end
  end

  helper :document
  helper :language

  include DesignHelper

  # Be sure to include AuthenticationSystem in Application Controller instead
  include AuthenticatedSystem
  include PermissionCheck

  before_filter :set_locale
  def set_locale
    FastGettext.available_locales = environment.available_locales
    FastGettext.default_locale = environment.default_locale
    FastGettext.locale = (params[:lang] || session[:lang] || environment.default_locale || request.env['HTTP_ACCEPT_LANGUAGE'] || 'en')
    I18n.locale = FastGettext.locale.to_s.gsub '_', '-'
    I18n.default_locale = FastGettext.default_locale.to_s.gsub '_', '-'
    if params[:lang]
      session[:lang] = params[:lang]
    end
  end

  include NeedsProfile

  attr_reader :environment

  # declares that the given <tt>actions</tt> cannot be accessed by other HTTP
  # method besides POST.
  def self.post_only(actions, redirect = { :action => 'index'})
    before_filter(:only => actions) do |controller|
      if !controller.request.post?
        controller.redirect_to redirect
      end
    end
  end

  helper_method :current_person, :current_person

  protected

  def verified_request?
    super || form_authenticity_token == request.headers['X-XSRF-TOKEN']
  end

  def setup_multitenancy
    Noosfero::MultiTenancy.setup!(request.host)
  end

  def boxes_editor?
    false
  end

  def content_editor?
    false
  end

  def user
    current_user.person if logged_in?
  end

  alias :current_person :user

  # TODO: move this logic somewhere else (Domain class?)
  def detect_stuff_by_domain
    # Sets text domain based on request host for custom internationalization
    FastGettext.text_domain = Domain.custom_locale(request.host)

    @domain = Domain.find_by_name(request.host)
    if @domain.nil?
      @environment = Environment.default
      if @environment.nil? && Rails.env.development?
        # This should only happen in development ...
        @environment = Environment.new
        @environment.name = "Noosfero"
        @environment.is_default = true
        @environment.save!
      end
    else
      @environment = @domain.environment
      # do this conditionally to allow organizations to show theirs users inside their domains
      @profile = @domain.profile if params[:profile].blank?

      # do no redirect to as facebook applications that can only have one domain
      return

      # Check if the requested profile belongs to another domain
      if @domain.profile and params[:profile].present? and params[:profile] != @domain.profile.identifier
        @profile = @environment.profiles.find_by_identifier params[:profile]
        return render_not_found if @profile.blank?
        redirect_to params.merge(:host => @profile.default_hostname, :protocol => @profile.default_protocol)
      end
    end
  end

  include Noosfero::Plugin::HotSpot

  # FIXME this filter just loads @plugins to children controllers and helpers
  def init_noosfero_plugins
    plugins
  end

  def render_not_found(path = nil)
    @no_design_blocks = true
    @path ||= request.path
    render :template => 'shared/not_found.html.erb', :status => 404, :layout => get_layout
  end
  alias :render_404 :render_not_found

  def render_access_denied(message = nil, title = nil)
    @no_design_blocks = true
    @message = message
    @title = title
    render :template => 'shared/access_denied.html.erb', :status => 403
  end

  def load_category
    unless params[:category_path].blank?
      path = params[:category_path]
      @category = environment.categories.find_by_path(path)
      if @category.nil?
        render_not_found(path)
      end
    end
  end

  def authorize_profiler
    Rack::MiniProfiler.authorize_request if user and user.is_admin?
  end

  include SearchTermHelper

  private

  def autocomplete asset, scope, query, paginate_options={:page => 1}, options={:field => 'name'}
    plugins.dispatch_first(:autocomplete, asset, scope, query, paginate_options, options) ||
    fallback_autocomplete(asset, scope, query, paginate_options, options)
  end

  def fallback_autocomplete asset, scope, query, paginate_options, options
    field = options[:field]
    query = query.downcase
    scope.where([
      "LOWER(#{field}) ILIKE ? OR #{field}) ILIKE ?", "#{query}%", "% #{query}%"
    ])
    {:results => scope.paginate(paginate_options)}
  end

  def find_by_contents(asset, context, scope, query, paginate_options={:page => 1}, options={})
    search = plugins.dispatch_first(:find_by_contents, asset, scope, query, paginate_options, options)
    register_search_term(query, scope.count, search[:results].count, context, asset)
    search
  end

  def find_suggestions(query, context, asset, options={})
    plugins.dispatch_first(:find_suggestions, query, context, asset, options)
  end

  def private_environment?
    @environment.enabled?(:restrict_to_members)
  end
end
