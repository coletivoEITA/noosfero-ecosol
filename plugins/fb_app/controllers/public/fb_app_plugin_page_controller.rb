class FbAppPluginPageController < FbAppPluginController

  no_design_blocks

  before_filter :change_theme

  helper FbAppPlugin::FbAppDisplayHelper

  def index
    load_configs

    if params[:tabs_added]
      @page_ids = params[:tabs_added].map{ |id, value| id }
      render action: 'tabs_added', layout: false
    elsif params[:signed_request] or params[:page_id]
      if @config
        if @config.blank?
          render action: 'first_load'
        elsif product_id = params[:product_id]
          @product = environment.products.find product_id
          @profile = @product.profile
          @inputs = @product.inputs
          @allowed_user = false

          render action: 'product'
        elsif @config.profiles.present? and @config.profiles.size == 1
          @profile = @config.profiles.first
          extend CatalogHelper
          catalog_load_index

          render action: 'catalog'
        else
          @query = if @config.profiles.present? then @config.profiles.map(&:identifier).join(' OR ') else @config.query end
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
    load_configs
    @profiles = @config.profiles rescue []
    @query = @config.query rescue ''

    if request.post?
      create_configs if @config.nil?

      case params[:fb_integration_type]
        when 'profiles'
          @config.profile_ids = Array(params[:profile_ids])
        when 'query'
          @config.query = params[:fb_keyword].to_s
      end
      @config.save!

      respond_to{ |format| format.js{ render action: 'admin', layout: false } }
    else
      respond_to{ |format| format.html }
    end
  end

  def uninstall
    render text: params.to_yaml
  end

  def search
    @query = params[:query]
    @profiles = environment.enterprises.enabled.public.all limit: 12, order: 'name ASC',
      conditions: ['name ILIKE ? OR name ILIKE ? OR identifier LIKE ?', "#{@query}%", "% #{@query}%", "#{@query}%"]
    render json: (@profiles.map do |profile|
      {name: profile.name, id: profile.id, identifier: profile.identifier}
    end)
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

  def load_configs
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

    @configs = FbAppPlugin::PageTabConfig.where page_id: @page_ids
    @config = @configs.first
    @new_request = true if @config.blank?
    @configs
  end

  def create_configs
    @page_ids.each do |page_id|
      @configs << FbAppPlugin::PageTabConfig.create!(page_id: page_id)
    end
    @config ||= @configs.first
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
