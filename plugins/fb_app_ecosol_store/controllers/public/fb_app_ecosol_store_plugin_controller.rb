class FbAppEcosolStorePluginController < PublicController

  no_design_blocks

  def index
    load_config

    if params[:tabs_added]
      @signed_requests = {}; params[:tabs_added].each_with_index{ |(id, value), i| @signed_requests[i] = id }
      render :action => 'tabs_added'
    elsif @config
      @current_theme = 'template'

      if @config.profiles.present? and @profiles.size == 1
        extend CatalogHelper
        catalog_load_index

        render :template => 'catalog/index'
      else
        @query = if @config.profiles.present? then @config.profiles.map(&:identifier).join(' OR ') else @config.query end
      end
    else
      redirect_to :action => 'admin'
    end
  end

  def admin
    load_config || create_config
    @current_theme = 'template'
    @profiles = @config.profiles
    if request.post?
      @config.update_attributes! params[:config]
    end
  end

  def uninstall
    render :text => params.to_yaml
  end

  def search
    @profiles = Profile.find_by_contents(params[:query][:term])[:results]
    render :json => (@profiles.map do |profile|
      {:name => profile.name, :id => profile.id}
    end)
  end

  protected

  def load_config
    @config = FbAppEcosolStorePlugin::SignedRequestConfig.where(:signed_request => params[:signed_request]).first
    @new_request = true if @config.blank?
    @config
  end

  def create_config
    @config ||= FbAppEcosolStorePlugin::SignedRequestConfig.create! :signed_request => params[:signed_request]
  end

  def profile
    @profile
  end

end
