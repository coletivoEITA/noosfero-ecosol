class FbAppPluginPageTabController < FbAppPluginController

  no_design_blocks

  before_filter :change_theme

  helper FbAppPlugin::FbAppDisplayHelper

  def index
    load_page_tabs

    if params[:tabs_added]
      @page_ids = FbAppPlugin::Profile.page_ids_from_tabs_added params[:tabs_added]
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

          render action: 'product'
        elsif @page_tab.profiles.present? and @page_tab.profiles.size == 1
          @profile = @page_tab.profile
          extend CatalogHelper
          catalog_load_index

          render action: 'catalog'
        else
          @query = if @page_tab.profiles.present? then @page_tab.profiles.map(&:identifier).join(' OR ') else @page_tab.query end
          @empty_query = @category.nil? && @query.blank?

          page = (params[:page] || '1').to_i
          @asset = :products
          @order ||= [@asset]
          @names = {}
          @scope = @environment.products.enabled.public
          @searches ||= {}
          @searches[@asset] = @scope.find_by_contents @query, {page: page, per_page: 20}

          render action: 'search'
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
    load_page_tabs

    if request.post? and @page_id.present?
      create_page_tabs if @page_tab.nil?

      case params[:config_type]
        when 'profile'
          @page_tab.profile = Profile.where(id: Array(params[:profile_ids])).first
        when 'profiles'
          @page_tab.profiles = Profile.where(id: Array(params[:profile_ids]))
        when 'query'
          @page_tab.query = params[:fb_keyword].to_s
      end
      @page_tab.save!

      respond_to{ |format| format.js{ render action: 'admin', layout: false } }
    else
      respond_to{ |format| format.html }
    end
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
    @signed_requests = if params[:signed_request].is_a? Hash then params[:signed_request].values else Array(params[:signed_request]) end

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
      @page_ids = if params[:page_id].is_a? Hash then params[:page_id].values else Array(params[:page_id]) end
    end

    @page_tabs = FbAppPlugin::PageTab.where page_id: @page_ids

    @signed_request = @signed_requests.first
    @page_id = @page_ids.first
    @page_tab = @page_tabs.first
    @new_request = true if @page_tab.blank?

    @page_tabs
  end

  def create_page_tabs
    @page_tabs = FbAppPlugin::PageTab.create_from_page_ids @page_ids
    @page_tab ||= @page_tabs.first
  end

  def change_theme
    @current_theme = 'embed_810'
    @without_pure_chat = true
  end

  def get_layout
    return if request.xhr?
    super
  end

end
