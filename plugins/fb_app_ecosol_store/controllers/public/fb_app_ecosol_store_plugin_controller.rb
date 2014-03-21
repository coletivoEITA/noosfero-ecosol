class FbAppEcosolStorePluginController < PublicController

  no_design_blocks

  before_filter :change_theme

  def index
    load_configs

    if params[:tabs_added]
      @signed_requests = {}; params[:tabs_added].each_with_index{ |(id, value), i| @signed_requests[i] = id }
      @signed_requests = {:signed_request => @signed_requests}
      render :action => 'tabs_added', :layout => false
    elsif @config
      if @config.profiles.present? and @config.profiles.size == 1
        @profile = @config.profiles.first
        extend CatalogHelper
        catalog_load_index

        render :template => 'catalog/index'
      else
        @query = if @config.profiles.present? then @config.profiles.map(&:identifier).join(' OR ') else @config.query end
      end
    else
      # render template
    end
  end

  def admin
    create_configs if load_configs.blank?
    @profiles = @config.profiles
    @query = @config.query
    @signed_request = params[:signed_request]
    if request.post?
      case params[:integration_type]
        when 'profiles'
          @config.profile_ids = params[:profile_ids]
        when 'query'
          @config.query = params[:keyword]
      end
      @config.save
      render :json => '', :status => :ok
    end
  end

  def uninstall
    render :text => params.to_yaml
  end

  def search
    @profiles = Profile.find_by_contents(params[:query])[:results]
    render :json => (@profiles.map do |profile|
      {:name => profile.name, :id => profile.id, :identifier => profile.identifier}
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
    @signed_requests = if params[:signed_requests].is_a? Hash then params[:signed_request].values else params[:signed_request].to_a end
    @configs = FbAppEcosolStorePlugin::SignedRequestConfig.where(:signed_request => @signed_requests)
    @config = @configs.first
    @new_request = true if @config.blank?
    @configs
  end

  def create_configs
    @signed_requests.each do |signed_request|
      @configs << FbAppEcosolStorePlugin::SignedRequestConfig.create!(:signed_request => signed_request)
    end
    @config ||= @configs.first
  end

  def change_theme
    @current_theme = 'template'
  end

end
