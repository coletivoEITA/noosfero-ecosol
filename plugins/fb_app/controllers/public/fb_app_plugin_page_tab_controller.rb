class FbAppPluginPageTabController < FbAppPluginController

  no_design_blocks

  before_filter :change_theme
  before_filter :disable_cache

  helper FbAppPlugin::FbAppDisplayHelper

  def index
    return unless load_page_tabs

    if params[:tabs_added]
      @page_ids = FbAppPlugin::Profile.page_ids_from_tabs_added params[:tabs_added]
      session[:notice] = t('fb_app_plugin.views.page_tab.added_notice')
      render action: 'tabs_added', layout: false
    elsif params[:signed_request] or params[:page_id]
      if @page_tab
        if @page_tab.blank?
          render action: 'first_load'
        elsif product_id = params[:product_id]
          @product = environment.products.find product_id
          @profile = @product.profile
          @inputs = @product.inputs
          @allowed_user = false
          load_catalog

          render action: 'product'
        elsif @page_tab.profiles.present? and @page_tab.profiles.size == 1
          @profile = @page_tab.profiles.first
          load_catalog

          render action: 'catalog'
        else
          # fake profile for catalog controller
          @profile = environment.enterprise_template
          @query = if @page_tab.profiles.present? then @page_tab.profiles.map(&:identifier).join(' OR ') else @page_tab.query end
          @scope = @environment.products.enabled.public
          load_catalog scope: @scope, base_query: @query

          render action: 'catalog'
        end
      else
        render action: 'first_load'
      end
    else
      # render template
      render action: 'index'
    end
  end

  def admin
    return unless load_page_tabs

    if request.put? and @page_id.present?
      create_page_tabs if @page_tab.nil?

      case params[:page_tab][:config_type]
        when 'profile'
          @page_tab.profile = Profile.where(id: Array(params[:page_tab][:profile_ids])).first
        when 'profiles'
          @page_tab.profiles = Profile.where(id: Array(params[:page_tab][:profile_ids]))
        when 'query'
          @page_tab.query = params[:page_tab][:query].to_s
      end
      @page_tab.name = params[:page_tab][:name]
      @page_tab.save!

      respond_to{ |format| format.js{ render action: 'admin', layout: false } }
    end
  end

  def destroy
    @page_tab = FbAppPlugin::PageTab.find params[:id]
    return unless user.is_admin?(environment) or user.is_admin? @page_tab.profile
    @page_tab.destroy
    render nothing: true
  end

  def uninstall
    render text: params.to_yaml
  end

  def enterprise_search
    scope = environment.enterprises.enabled.public
    @query = params[:query]
    @profiles = scope.limit(10).order('name ASC').
      where(['name ILIKE ? OR name ILIKE ? OR identifier LIKE ?', "#{@query}%", "% #{@query}%", "#{@query}%"])
    render partial: 'open_graph_plugin_myprofile/profile_search', locals: {profiles: @profiles}
  end

  # unfortunetely, this needs to be public
  def profile
    @profile
  end

  protected

  def default_url_options options={}
    options[:profile] = @profile.identifier if @profile
    super
  end

  def load_page_tabs
    @signed_requests = read_param params[:signed_request]
    if @signed_requests.present?
      @datas = []
      @page_ids = @signed_requests.map do |signed_request|
        @data = FbAppPlugin::Auth.parse_signed_request signed_request
        @datas << @data
        page_id = @data[:page][:id] rescue nil
        if page_id.blank?
          render_access_denied
          return false
        end
        page_id
      end
    else
      @page_ids = read_param params[:page_id]
    end

    @page_tabs = FbAppPlugin::PageTab.where page_id: @page_ids

    @signed_request = @signed_requests.first
    @page_id = @page_ids.first
    @page_tab = @page_tabs.first
    @new_request = true if @page_tab.blank?

    true
  end

  def create_page_tabs
    @page_tabs = FbAppPlugin::PageTab.create_from_page_ids @page_ids
    @page_tab ||= @page_tabs.first
  end

  def change_theme
    @current_theme = 'ees' unless theme_responsive?
    @without_pure_chat = true
  end

  def disable_cache
    @disable_cache_theme_navigation = true
  end

  def load_catalog options = {}
    extend CatalogHelper
    catalog_load_index options
    @use_show_more = true
  end

  def read_param param
    if param.is_a? Hash
      param.values
    else
      Array(param).select{ |p| p.present? }
    end
  end

end
